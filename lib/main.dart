import 'package:flutter/material.dart';
import 'package:wshell/shared/llm/llm_models.dart';
import 'package:wshell/widgets/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  LlmModels().subscribeToEvents();

  runApp(const App());
}
