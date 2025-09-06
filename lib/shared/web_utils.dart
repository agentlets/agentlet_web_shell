import 'package:web/web.dart' as web;

  String get appURL {
    final location = web.window.location;
    return location.href;
  }