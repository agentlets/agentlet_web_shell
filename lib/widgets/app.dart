import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wshell/shared/event_bus.dart';
import 'package:wshell/shared/logger.dart';
import 'package:wshell/widgets/home.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String appTitle = 'WebShell';
  StreamSubscription? _updateAppTitleSub;
  final logger = WebLogger.createLogger(name: 'HomePage');

  void _changeTitle(String newTitle) async {
    setState(() {
      appTitle = newTitle;
    });
  }

  @override
  void initState() {
    super.initState();
    _subscribeToEvents();
  }

  void _subscribeToEvents() async {
    _updateAppTitleSub = GlobalEventBus.instance
        .on<ApplicationTitleUpdated>()
        .listen((event) async {
      logger.debug('Evento recibido: ${event}');
      _changeTitle(event.appTitle);
    });
  }

  @override
  void dispose() {
    _updateAppTitleSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      home: HomePage(),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D2D2D),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );
  }
}
