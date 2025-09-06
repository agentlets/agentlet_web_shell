
import 'package:wshell/model/chat_message.dart';

enum LLMResponseType { text, functionCall }

abstract class LLMResponse<T> {
  final LLMResponseType type;
  final T response;
  LLMResponse({required this.type, required this.response});
}

class TextLLMResponse extends LLMResponse<String> {

  TextLLMResponse({required super.response}) 
  : super(type: LLMResponseType.text);
}

class FunctionCallLLMResponse extends LLMResponse<FunctionCallRequest> {

  FunctionCallLLMResponse({required super.response}) 
  : super(type: LLMResponseType.functionCall);
}
