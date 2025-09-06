import 'package:flutter/material.dart';
import 'package:wshell/shared/chat_controller.dart';
import 'package:wshell/shared/logger.dart';
import 'package:wshell/widgets/chat/chat_input_bar.dart';
import 'package:wshell/widgets/chat/chat_message_list.dart';


class ChatArea extends StatelessWidget {
  final ChatController chatController;

  ChatArea({Key? key, required this.chatController}) : super(key: key);

  final logger = WebLogger.createLogger(name: 'ChatArea');

  void _handleSend(String text) {
    logger.debug('sending message: ${text}');
    chatController.sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 80, top: 8, bottom: 20),
          child: Column(
            children: [
              Expanded(
                child: ChatMessageList(
                  chatController: chatController,
                ),
              ),
              ChatInputBar(
                onSend: _handleSend,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 25,
          right: 20,
          child: FloatingActionButton(
            
            onPressed: () {
              chatController.saveConversation();
            },
            tooltip: 'Guardar conversación',
            child: Icon(Icons.save),
          ),
        ),
      ],
    );
  }
}
