
import 'package:wshell/shared/llm/llm_model.dart';

class NoModel extends LlmModel {
  NoModel() : super(id: '??', name: 'no-model-selected', provider: 'OpenAI');

  @override
  Future<LLMResponse> sendPrompt({
    required LLMPromptBase prompt,
    TextLLMPrompt? behaviourPromptMessage,
    required List<LLMPromptBase> previousMessages,
    List<Map<String, dynamic>>? functions,
    dynamic functionCall}) async {
    return TextLLMResponse(
        response: 'No LLM models detected. Please configure');
  }
}
