

import 'package:wshell/shared/llm/llm_model.dart';

class LlmModelError extends Error {
  final String message;
  final LlmModel model;
  final Error? cause;

  LlmModelError(
    this.message,
    this.model,
    this.cause,
  );

  @override
  String toString() {
    return 'LlmModelError: $message\nModel: ${model.name} (${model.id})\nCaused by: $cause';
  }
}
