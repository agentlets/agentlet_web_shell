import 'package:event_bus/event_bus.dart';
import 'package:wshell/agentlet_shell/manifest/manifest_v1_1.dart';
import 'package:wshell/model/chat_message.dart';
import 'package:wshell/model/conversation.dart';

class GlobalEventBus {
  static final EventBus _eventBus = EventBus();

  static EventBus get instance => _eventBus;
}

class ApplicationTitleUpdated {
  final String appTitle;

  ApplicationTitleUpdated({required this.appTitle});

  @override
  String toString() => 'ApplicationTitleUpdated(menuId: $appTitle)';
}

//-----------------

class SaveConversationEnd {
  final Conversation conversation;
  final bool hasErrors;

  SaveConversationEnd({required this.conversation, this.hasErrors = false});

  @override
  String toString() => 'SaveConversationEnd(conversation: $conversation, hasErrors: $hasErrors)';
}

class SaveConversationBegin {
  final Conversation conversation;

  SaveConversationBegin({required this.conversation});

  @override
  String toString() => 'SaveConversationBegin(conversation: $conversation)';
}

class SaveConversationStarted {
  final Conversation conversation;

  SaveConversationStarted({required this.conversation});

  @override
  String toString() => 'SaveConversationStarted(conversation: $conversation)';
}

class LLMModelConfigurationDone {
  @override
  String toString() => 'LLMModelConfigurationDone()';
}

class LLMModelConfigurationError {
  final String message;
  final bool isWarning;

  LLMModelConfigurationError({required this.message, required this.isWarning});

  @override
  String toString() => 'LLMModelConfigurationError(message: $message, isWarning: $isWarning)';
}

class MenuOptionSelected {
  final String menuId;

  MenuOptionSelected({required this.menuId});

  @override
  String toString() => 'MenuOptionSelected(menuId: $menuId)';
}

class MessageResponseSent {
  final ChatMessageBase originalMessage;
  final ChatMessageBase message;
  final bool hasErrors;

  MessageResponseSent(
      {required this.originalMessage,
      required this.message,
      this.hasErrors = false});

  @override
  String toString() => 'MessageResponseSent(originalMessage: $originalMessage, message: $message, hasErrors: $hasErrors)';
}

class InvokeFunctionResponseSent {
  final FunctionCallRequest functionCallRequest;

  InvokeFunctionResponseSent(
      {required this.functionCallRequest});

  @override
  String toString() => 'InvokeFunctionResponseSent(functionCallRequest: $functionCallRequest)';
}

class FunctionCallResponseSent {
  final FunctionCallRequest functionCallRequest;
  final dynamic response;

  FunctionCallResponseSent(
      {required this.functionCallRequest, required this.response});

  @override
  String toString() => 'FunctionCallResponseSent(functionCallRequest: $functionCallRequest, response: $response)';
}

class MessageSent {
  final ChatMessageBase message;
  final List<ChatMessageBase> previousMessages;
  final TextChatMessage? behaviourPromptMessage;
  final  List<Map<String, dynamic>>? functions;
  
  MessageSent({required this.message, 
  required this.previousMessages,
  this.behaviourPromptMessage,
  this.functions
  });

  @override
  String toString() {
    final fnNames = functions?.map((m) => m['name']).toList() ?? ['no-functions'];
    return 'MessageSent(message: $message, previousMessages count: ${previousMessages.length}, behaviourPromptMessage size: ${behaviourPromptMessage?.text.length ?? 0}, functions: $fnNames)';
  }
}

class AgentletMessageSent {
  final String message;
  AgentletMessageSent({required this.message});

  @override
  String toString() => 'AgentletMessageSent(message: $message)';
}

class ChatCleared {
  @override
  String toString() => 'ChatCleared()';
}

class ColorPalleteChanged {
  final String palleteName;

  ColorPalleteChanged({required this.palleteName});

  @override
  String toString() => 'ColorPalleteChanged(palleteName: $palleteName)';
}

class HashtagListChanged {
  final List<String> hashtag;

  HashtagListChanged({required this.hashtag});

  @override
  String toString() => 'HashtagListChanged(hashtag: $hashtag)';
}

class ConversationListChanged {
  final Future<List<Conversation>> conversations;

  ConversationListChanged({required this.conversations});

  @override
  String toString() => 'ConversationListChanged(conversations: $conversations)';
}

class ApplicationEvent {
  final String method;
  final dynamic params;

  ApplicationEvent({
    required this.method,
    required this.params,
  });

  @override
  String toString() {
    return 'ApplicationEvent(method: $method, params: $params)';
  }
}

class AgentletImportPreviewResults {
  String githubUrl;
  List<ManifestV1_1> manifests;

  AgentletImportPreviewResults({
    required this.githubUrl,
    required this.manifests
  });

  @override
  String toString() {
    return 'AgentletImportPreviewResults(githubUrl: $githubUrl, manifestCount: ${manifests.length})';
  }
}

class AgentletImported {
@override
  String toString() => 'AgentletImported()';
}
