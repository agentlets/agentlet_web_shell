import 'package:flutter/material.dart';
import 'package:wshell/model/chat_message.dart';
import 'package:wshell/shared/colors.dart';

class ToolMessageBubble extends StatelessWidget {
  final FunctionCallResponseMessage message;

  const ToolMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: AppColors().assistantMessageBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(6),
            topRight: const Radius.circular(6),
            bottomLeft: const Radius.circular(6),
            bottomRight: const Radius.circular(6),
          ),
          border: Border.all(
            color: AppColors().toolResponse,
            width: 1,
            style: BorderStyle.solid, // Required to define first, then override with dashed
          ),
          shape: BoxShape.rectangle,
          // Add a custom painter later if needed for full dashed effect
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            'Tool ${message.functionCallRequest.functionName} (${message.functionCallRequest.arguments}) \n=> ${message.response}',
            style: TextStyle(
              color: AppColors().toolResponse,
              fontSize: 10.0,
              fontFamily: 'RobotoMono'
            ),
          ),
        ),
      ),
    );
  }
}
