

import 'package:wshell/shared/app_error.dart';

enum MessageSender { user, assistant, system, function }

abstract class ChatMessageBase {
  final String id;
  final MessageSender sender;
  final DateTime timestamp;
  int sequence = -1;

  ChatMessageBase({
    required this.id,
    required this.sender,
    required this.timestamp,
    this.sequence = -1
  });

  Map<String, dynamic> toMap() {
    throw ApplicationError(message: 'toMap must be overrided');
  }

  static ChatMessageBase fromMap(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'text':
        return TextChatMessage.fromMap(map);
      case 'function':
        return FunctionCallResponseMessage.fromMap(map);
      default:
        throw ApplicationError(message: 'Unsupported type in fromMap: ${map['type']}');
    }
  }
}

class TextChatMessage extends ChatMessageBase {
  final String text;

  TextChatMessage(
      {required super.id,
      required this.text,
      required super.sender,
      required super.timestamp,
      super.sequence
      });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'text',
      'id': id,
      'text': text,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'sequence': sequence
    };
  }

  static TextChatMessage fromMap(Map<String, dynamic> map) {
    return TextChatMessage(
      id: map['id'],
      text: map['text'],
      sender: MessageSender.values.firstWhere((e) => e.name == map['sender']),
      timestamp: DateTime.parse(map['timestamp']),
      sequence: map['sequence']
    );
  }

  @override
  String toString() {
    return 'TextChatMessage(id: $id, text: $text, sender: $sender, timestamp: $timestamp, sequence: $sequence)';
  }
}

class FunctionCallResponseMessage extends ChatMessageBase {
  final FunctionCallRequest functionCallRequest;
  final dynamic response;

  FunctionCallResponseMessage(
      {required super.id,
      required this.functionCallRequest,
      required this.response,
      required super.timestamp,
      super.sequence })
      : super(sender: MessageSender.function);

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'function',
      'id': id,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'sequence': sequence,
      'functionCallRequest': {
        'functionName': functionCallRequest.functionName,
        'arguments': functionCallRequest.arguments,
      },
      'response': response,
    };
  }

  static FunctionCallResponseMessage fromMap(Map<String, dynamic> map) {
    return FunctionCallResponseMessage(
      id: map['id'],
      functionCallRequest: FunctionCallRequest(
        callId: map['functionCallRequest']['call_id'],
        functionName: map['functionCallRequest']['functionName'],
        arguments: Map<String, dynamic>.from(map['functionCallRequest']['arguments']),
      ),
      response: map['response'],
      timestamp: DateTime.parse(map['timestamp']),
      sequence: map['sequence']
    );
  }

  @override
  String toString() {
    return 'FunctionCallResponseMessage(id: $id, functionCallRequest: $functionCallRequest, response: $response, sender: $sender, timestamp: $timestamp, sequence: $sequence)';
  }
}

class FunctionCallRequest {
  final String callId;
  final String functionName;
  final Map<String, dynamic> arguments;

  FunctionCallRequest({
    required this.callId,
    required this.functionName,
    required this.arguments,
  });

  @override
  String toString() {
    return 'FunctionCallRequest(functionName: $functionName, arguments: $arguments)';
  }
}
