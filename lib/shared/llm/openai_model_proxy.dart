import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wshell/shared/appwrite_service.dart';
import 'package:wshell/model/chat_message.dart';
import 'package:wshell/shared/app_error.dart';
import 'package:wshell/shared/llm/llm_model.dart';
import 'package:wshell/shared/llm/llm_model_error.dart';
import 'package:wshell/shared/logger.dart';

class OpenAIModelProxyClient extends LlmModel {
  static final functionUri =
      Uri.parse('https://68c1a755002a9191729a.fra.appwrite.run/invoke_llm');
  //static final functionUri =
  //    Uri.parse('https://485e6ce3fc0d4af5888d99e3d1f35d1d.api.mockbin.io/');

  final logger = WebLogger.createLogger(name: 'OpenAIModel');

  // Use package:http client for web compatibility
  final http.Client httpClient = http.Client();

  OpenAIModelProxyClient()
      : super(id: 'gpt-4o', name: 'GPT-4o', provider: 'OpenAI');

  Future<Map<String, String>> _buildHeaders() async {
    final jwt = await AppwriteService.instance.getJwtFromAnonymousLogin();
    return {
      'Content-Type': 'application/json',
      'x-appwrite-user-jwt': jwt,
    };
  }

  Map<String, dynamic> _buildBody(
    LLMPromptBase prompt,
    List<LLMPromptBase> previousMessages, {
    List<Map<String, dynamic>>? functions,
    dynamic functionCall,
  }) {
    // Build messages array matching the requested structure
    final List<Map<String, String>> messages = [];

    for (final m in previousMessages) {
      if (m is TextLLMPrompt) {
        messages.add({'role': m.role.name, 'content': m.prompt});
      } else if (m is FunctionCallResponseLLMPrompt) {
        messages.add({
          'role': 'function',
          'content': jsonEncode(m.response),
          'name': m.functionCallRequest.functionName,
        });
      }
    }

    if (prompt is TextLLMPrompt) {
      messages.add({'role': prompt.role.name, 'content': prompt.prompt});
    } else if (prompt is FunctionCallResponseLLMPrompt) {
      messages.add({
        'role': 'function',
        'content': jsonEncode(prompt.response),
        'name': prompt.functionCallRequest.functionName,
      });
    } else {
      throw ApplicationError(
          message:
              'Unable to build request body. Unknow prompt type: ${prompt.runtimeType.toString()}');
    }

    // Build function_call array if provided via parameters
    List<Map<String, dynamic>>? functionCallArray;
    if (functions != null && functions.isNotEmpty) {
      functionCallArray = functions
          .map((f) => {
                'name': f['name'],
                'description': f['description'],
                'parameters': f['parameters'],
              })
          .toList();
    } else if (functionCall != null && functionCall is Map<String, dynamic>) {
      functionCallArray = [
        {
          'name': functionCall['name'],
          'description': functionCall['description'],
          'parameters': functionCall['parameters'],
        }
      ];
    }

    return {
      'messages': messages,
      if (functionCallArray != null) 'function_call': functionCallArray,
    };
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

    return _buildHeaders()
        .then((headers) => httpClient.post(
              functionUri,
              headers: headers,
              body: jsonEncode(body),
            ))
        .then((r) {
      final dynamic mappedResponse = {'status': r.statusCode, 'body': r.body};
      logger.debug('<<< response from model: $mappedResponse');
      return r;
    });
  }

  LLMResponse _handleApiResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw LlmModelError(
          'Failed to get response from function: ${response.body}', this, null);
    }

    final dynamic data = jsonDecode(response.body);

    // Expected shape example:
    // {
    //   "content": {
    //     "raw": {
    //       "output": [
    //         { "type": "function_call", "name": "...", "arguments": "{...}", ... }
    //       ],
    //       "output_text": "..."
    //     }
    //   }
    // }

    if (data is! Map<String, dynamic>) {
      return TextLLMResponse(response: data.toString());
    }

    final content = data['content'];
    if (content is Map<String, dynamic>) {
      final raw = content['raw'];
      if (raw is Map<String, dynamic>) {
        // 1) Prefer explicit output array entries
        final output = raw['output'];
        if (output is List && output.isNotEmpty) {
          final first = output.first;
          if (first is Map<String, dynamic>) {
            final type = first['type'];

            if (type == 'function_call') {
              final Map<String, dynamic> functionCallData = {
                'call_id': first['call_id'],
                'name': first['name'],
                'arguments': first['arguments'], // string JSON per example
              };
              return _buildFunctionCallResponse(functionCallData);
            }

            // If it's a text-like output item, try common fields
            final text = first['text'] ?? first['content'] ?? '';
            if (text is String && text.isNotEmpty) {
              return TextLLMResponse(response: text);
            }
          }
        }

        // 2) Fallback to output_text if present
        final outputText = raw['output_text'];
        if (outputText is String && outputText.isNotEmpty) {
          return TextLLMResponse(response: outputText);
        }
      }
    }

    // Legacy fallbacks
    if (data.containsKey('function_call')) {
      return _buildFunctionCallResponse(data['function_call']);
    }
    final message = data['content'] ?? data.toString();
    return TextLLMResponse(
        response: message is String ? message : message.toString());
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
  final callId = functionCallData['call_id'];
  final functionName = functionCallData['name'];
  final argumentsJson = functionCallData['arguments'];
  final arguments = jsonDecode(argumentsJson) as Map<String, dynamic>;
  return FunctionCallLLMResponse(
    response: FunctionCallRequest(
      callId: callId,
      functionName: functionName,
      arguments: arguments,
    ),
  );
}
