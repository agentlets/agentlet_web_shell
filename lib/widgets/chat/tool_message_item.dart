

import 'package:flutter/material.dart';
import 'package:wshell/model/chat_message.dart';
import 'package:wshell/shared/colors.dart';
import 'package:wshell/widgets/chat/tool_bubble.dart';

class ToolMessageItem extends StatelessWidget {
  final FunctionCallResponseMessage message;

  const ToolMessageItem({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
   
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ExpansionTile(
        title: Text(
          'Respuesta de herramienta',
          style: TextStyle(
              color: AppColors().toolResponse,
              fontSize: 12.0,
              fontFamily: 'RobotoMono'
            ),
        ),
        children: [
          ToolMessageBubble(
            message: message,
          ),
        ],
      ),
    );
  }
}