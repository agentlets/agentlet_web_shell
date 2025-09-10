import 'package:flutter/material.dart';
import 'package:wshell/shared/llm/llm_models.dart';
import 'package:wshell/shared/appwrite_service.dart';
import 'package:wshell/widgets/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Appwrite service with default Environment values
  await AppwriteService.instance.init(selfSigned: true);

  LlmModels().subscribeToEvents();

  runApp(const App());
}
