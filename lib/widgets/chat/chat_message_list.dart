import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wshell/model/chat_message.dart';
import 'package:wshell/model/conversation.dart';
import 'package:wshell/shared/chat_controller.dart';
import 'package:wshell/shared/event_bus.dart';
import 'package:wshell/shared/logger.dart';
import 'package:wshell/widgets/chat/chat_message_item.dart';
import 'package:wshell/widgets/chat/tool_message_item.dart';

class ChatMessageList extends StatefulWidget {
  final ChatController chatController;

  // ignore: prefer_const_constructors_in_immutables
  ChatMessageList({
    super.key,
    required this.chatController,
  });

  @override
  _ChatMessageListState createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  late Conversation _conversation;
  StreamSubscription? _messageSentSub;
  StreamSubscription? _messageResponseSentSub;
  StreamSubscription? _chatClearedSub;

  final logger = WebLogger.createLogger(name: 'ChatMessageList');

  @override
  void initState() {;
    super.initState();
    _conversation = widget.chatController.conversation;
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    _messageSentSub = GlobalEventBus.instance.on<MessageSent>().listen((event) {
      logger.debug('mensaje recibido: ${event}');
      setState(() {
        _conversation = widget.chatController.conversation;
      });
    });

     _chatClearedSub = GlobalEventBus.instance.on<ChatCleared>().listen((event) {
      logger.debug('mensaje recibido: ${event}');
      setState(() {
        _conversation = widget.chatController.conversation;
      });
    });

    _messageResponseSentSub = GlobalEventBus.instance.on<MessageResponseSent>().listen((event) {
      logger.debug('respuesta recibido: ${event}');
      setState(() {
        _conversation.appendMessage(event.message);
       _conversation = widget.chatController.conversation;
      });
    });
  }

  @override
  void dispose() {
    _messageSentSub?.cancel();
    _messageResponseSentSub?.cancel();
    _chatClearedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = _conversation.messages;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        
        if (message is TextChatMessage) {
          return TextChatMessageItem(message: message);
        
        } else if (message is FunctionCallResponseMessage) {
          return ToolMessageItem(message: message);
          
        } else {
          return Text('Error: unknow message type: ${message.runtimeType.toString()}');
        }
        
      },
    );
  }
}