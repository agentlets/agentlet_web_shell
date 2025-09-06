
import 'package:wshell/model/chat_message.dart';

enum LLMPromptType { text, functionResponse }

enum LLMRole { 
  user, 
  assistant, 
  system, 
  function;

  static LLMRole fromName(String name) {
    return LLMRole.values.firstWhere(
        (e) => e.name == name,
        orElse: () => user,
      );
  }
}

abstract class LLMPromptBase {
  final LLMPromptType type;
  final LLMRole role;

  LLMPromptBase(
      {required this.type, this.role = LLMRole.user});
}

class TextLLMPrompt extends LLMPromptBase {
  final String prompt;
  TextLLMPrompt({
    required this.prompt,
    super.role = LLMRole.user,
  }) : super(
    type: LLMPromptType.text,
  );

  @override
  String toString() {
    return 'TextLLMPrompt(prompt: $prompt, role: $role, type: $type)';
  }
}

class FunctionCallResponseLLMPrompt extends LLMPromptBase {
  final FunctionCallRequest functionCallRequest;
  final dynamic response;

  FunctionCallResponseLLMPrompt(
      { 
        required this.functionCallRequest, 
        required this.response, 
      }) : super(
        type: LLMPromptType.functionResponse,
        role: LLMRole.function,
      );

}
