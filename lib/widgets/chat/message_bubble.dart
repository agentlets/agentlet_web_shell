import 'package:flutter/material.dart';
import 'package:wshell/model/chat_message.dart';
import 'package:wshell/shared/colors.dart';

class TextMessageBubble extends StatelessWidget {
  final TextChatMessage message;
  final bool isUser;

  const TextMessageBubble({
    Key? key,
    required this.message,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors().userMessageBubble
              : AppColors().assistantMessageBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft:
                isUser ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight:
                isUser ? const Radius.circular(0) : const Radius.circular(12),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: Colors.grey.shade700,
                  width: 1,
                ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isUser ? 12.0 : 30.0),
          child: Text(
            message.text,
            style: TextStyle(
                color: isUser
                    ? AppColors().userMessageText
                    : AppColors().assistantMessageText),
          ),
        ),
      ),
    );
  }
}
