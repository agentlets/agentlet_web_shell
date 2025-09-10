
import 'package:wshell/model/chat_message.dart';
import 'package:wshell/model/conversation.dart';
import 'package:wshell/shared/event_bus.dart';

class ChatController {
  Conversation _conversation = Conversation();
  TextChatMessage? _behaviourPromptMessage;
  List<Map<String, dynamic>>? _functions;
  //List<ChatMessageBase> get messages => _conversation.messages;
  Conversation get conversation => _conversation;
  void set conversation(Conversation value) => _conversation = value;

  void sendMessage(String text) {
    final newMessage = TextChatMessage(
      id: DateTime.now().toIso8601String(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    final event = MessageSent(
        message: newMessage, 
        previousMessages: _conversation.messages,
        behaviourPromptMessage: _behaviourPromptMessage,
        functions: _functions
        );
    GlobalEventBus.instance.fire(event);

    _conversation.appendMessage(newMessage);
  }

  void sendFunctionCallResponse(FunctionCallRequest functionCallRequest, dynamic response) {
    final newMessage = FunctionCallResponseMessage(
      id: DateTime.now().toIso8601String(),
      functionCallRequest: functionCallRequest,
      response: response,
      timestamp: DateTime.now(),
    );

    final event = MessageSent(
        message: newMessage, 
        previousMessages: _conversation.messages,
        behaviourPromptMessage: _behaviourPromptMessage,
        functions: _functions
        );
    GlobalEventBus.instance.fire(event);

    _conversation.appendMessage(newMessage);
  }

  void setBehaviour(String text) {
    _behaviourPromptMessage = TextChatMessage(
      id: DateTime.now().toIso8601String(),
      text: text,
      sender: MessageSender.system,
      timestamp: DateTime.now(),
    );
  }

  set functions(List<Map<String, dynamic>>? value) {
    _functions = value;
  }

  void saveConversation() {
    final event = SaveConversationStarted(conversation: _conversation);
    GlobalEventBus.instance.fire(event);
  }

  void dispose() {}
  
}
