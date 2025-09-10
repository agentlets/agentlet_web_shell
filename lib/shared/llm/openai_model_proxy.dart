
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wshell/model/chat_message.dart';
import 'package:wshell/shared/app_error.dart';
import 'package:wshell/shared/llm/llm_model.dart';
import 'package:wshell/shared/llm/llm_model_error.dart';
import 'package:wshell/shared/logger.dart';

class OpenAIPModelProxy extends LlmModel {
  static final chatUri =
      Uri.parse('https://api.openai.com/v1/chat/completions');

  final logger = WebLogger.createLogger(name: 'OpenAIModel');

  // Use package:http client for web compatibility
  final http.Client httpClient = http.Client();

  OpenAIPModelProxy(): super(id: 'gpt-4o', name: 'GPT-4o', provider: 'OpenAI');

  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }

  Map<String, dynamic> _buildBody(
    LLMPromptBase prompt,
    List<LLMPromptBase> previousMessages, {
    List<Map<String, dynamic>>? functions,
    dynamic functionCall,
  }) {
    final List<Map<String, String>> openAIMessages = previousMessages.map((m) {
      final Map<String, String> mappedMessage = {
        'role': m.role.name
      };
      if (m is TextLLMPrompt) {
         mappedMessage['content'] = m.prompt;
      }
      if (m is FunctionCallResponseLLMPrompt) {
        final FunctionCallResponseLLMPrompt msg = m;
        mappedMessage['name'] = msg.functionCallRequest.functionName;
        mappedMessage['content'] = jsonEncode(msg.response);
      }
      return mappedMessage;
    }).toList();

    if (prompt is FunctionCallResponseLLMPrompt) {
      final FunctionCallResponseLLMPrompt fnCallResponsePrompt = prompt;
      openAIMessages.add({
        'role': 'function',
        'name': fnCallResponsePrompt.functionCallRequest.functionName,
        'content': jsonEncode(fnCallResponsePrompt.response)
      });
    
    } else if (prompt is TextLLMPrompt) {
      openAIMessages.add({'role': 'user', 'content': prompt.prompt});
    
    } else {
      throw ApplicationError(message: 'Unable to build request body. Unknow prompt type: ${prompt.runtimeType.toString()}');
    }

    final body = {
      'model': id,
      'messages': openAIMessages,
    };
    if (functions != null && functions.isNotEmpty) {
      body['functions'] = functions;

      if (functionCall != null) {
        body['function_call'] = functionCall;
      }
    }

    return body;
  }

  List<LLMPromptBase> _mapPreviousMessages(List<LLMPromptBase> previousMessages,
      TextLLMPrompt? behaviourPromptMessage) {
    final List<LLMPromptBase> mappedPreviousMessages =
        List.from(previousMessages);
    if (behaviourPromptMessage != null) {
      mappedPreviousMessages.insert(0, behaviourPromptMessage);
    }
    return mappedPreviousMessages;
  }

  Future<http.Response> _performApiRequest(
    LLMPromptBase prompt,
    List<LLMPromptBase> mappedPreviousMessages,
    List<Map<String, dynamic>>? functions,
    dynamic functionCall,
  ) {
    final body = _buildBody(
      prompt,
      mappedPreviousMessages,
      functions: functions,
      functionCall: functionCall,
    );
    logger.debug('>>> request body to send: $body');

    return httpClient
        .post(
      chatUri,
      headers: _buildHeaders(),
      body: jsonEncode(body),
    )
        .then((r) {
          final dynamic mappedResponse = {
            'status': r.statusCode,
            'body': r.body
          };
          logger.debug('<<< response from model: $mappedResponse');
          return r;
        });
  }

  LLMResponse _handleApiResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final messageData = data['choices'][0]['message'];

      // Return FunctionCallLLMResponse if function call is present
      if (messageData.containsKey('function_call')) {
        return _buildFunctionCallResponse(messageData['function_call']);
      }

      final message = messageData['content'];
      return TextLLMResponse(response: message);
    } else {
      throw LlmModelError(
          'Failed to get response from OpenAI: ${response.body}', this, null);
    }
  }

  @override
  Future<LLMResponse> sendPrompt({
    required LLMPromptBase prompt,
    TextLLMPrompt? behaviourPromptMessage,
    required List<LLMPromptBase> previousMessages,
    List<Map<String, dynamic>>? functions,
    dynamic functionCall,
  }) async {
    try {
      final mappedPreviousMessages =
          _mapPreviousMessages(previousMessages, behaviourPromptMessage);
      final response = await _performApiRequest(
          prompt, mappedPreviousMessages, functions, functionCall);
      return _handleApiResponse(response);
    } catch (error) {
      if (error is LlmModelError) {
        rethrow;
      } else {
        throw LlmModelError(
          'Unexpected error during prompt processing',
          this,
          error is Error ? error : StateError(error.toString()),
        );
      }
    }
  }
}

FunctionCallLLMResponse _buildFunctionCallResponse(
    Map<String, dynamic> functionCallData) {
  final functionName = functionCallData['name'];
  final argumentsJson = functionCallData['arguments'];
  final arguments = jsonDecode(argumentsJson) as Map<String, dynamic>;
  return FunctionCallLLMResponse(
    response: FunctionCallRequest(
      functionName: functionName,
      arguments: arguments,
    ),
  );
}
