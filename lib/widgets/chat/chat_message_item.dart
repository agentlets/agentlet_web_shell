

import 'package:flutter/material.dart';
import 'package:wshell/model/chat_message.dart';
import 'package:wshell/widgets/chat/message_bubble.dart';


class TextChatMessageItem extends StatelessWidget {
  final TextChatMessage message;

  const TextChatMessageItem({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextMessageBubble(
        message: message,
        isUser: isUser,
      ),
    );
  }
}