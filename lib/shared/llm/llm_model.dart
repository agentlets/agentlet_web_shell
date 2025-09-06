

import 'package:wshell/model/llm/llm_answer.dart';
import 'package:wshell/model/llm/llm_prompt.dart';

export 'package:wshell/model/llm/llm_answer.dart';
export 'package:wshell/model/llm/llm_prompt.dart';

abstract class LlmModel {
  final String id;
  final String name;
  final String provider;

  LlmModel({required this.id, required this.name, required this.provider});

  Future<LLMResponse> sendPrompt({
    required LLMPromptBase prompt,
    TextLLMPrompt? behaviourPromptMessage,
    required List<LLMPromptBase> previousMessages,
    List<Map<String, dynamic>>? functions,
    dynamic functionCall,
  }) {
    throw ('sendPrompt must be implemented by subclasess,');
  }
}

class ModelFunctionCallRequest {
  final String functionName;
  final Map<String, dynamic> arguments;

  ModelFunctionCallRequest({
    required this.functionName,
    required this.arguments,
  });

  @override
  String toString() {
    return 'ModelFunctionCallRequest(functionName: $functionName, arguments: $arguments)';
  }
}
