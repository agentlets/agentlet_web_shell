import 'package:flutter/material.dart';
import 'event_bus.dart';

abstract class AppColorPalette {
  String get palleteName;
  Color get title;
  Color get icons;
  Color get shadowText;
  Color get userMessageBubble;
  Color get assistantMessageBubble;
  Color get userMessageText;
  Color get assistantMessageText;
  Color get toolResponse;
  Color get prompt;
  // Add other color definitions here
}

class DarkAppColorPalette implements AppColorPalette {
  @override
  Color get title => Color.lerp(Colors.black, Colors.white, 0.75)!;
  
  @override
  Color get icons => Color.lerp(Colors.black, Colors.white, 0.75)!;
  
  @override
  Color get shadowText => Color.lerp(Colors.black, Colors.white, 0.50)!;
  
  @override
  String get palleteName => 'dark';
  
  @override
  Color get assistantMessageBubble => Colors.transparent;
  
  @override
  Color get userMessageBubble => Colors.grey.shade800;
  
  @override
  
  Color get assistantMessageText => Color.lerp(Colors.black, Colors.white, 0.75)!;
  
  @override
  Color get toolResponse => Color.lerp(Colors.black, Colors.white, 0.65)!;
  

  @override
  
  Color get userMessageText => Color.lerp(Colors.black, Colors.white, 0.75)!;
  
  @override
  Color get prompt => Color(0xFF33FF33); // un verde neón con un toque suave;// Color.lerp(Colors.black, Colors.white, 0.55)!;
}

class AppColors implements AppColorPalette {
  static final AppColors _instance = AppColors._internal();

  factory AppColors() {
    return _instance;
  }

  AppColors._internal();

  AppColorPalette _palette = DarkAppColorPalette();

  AppColorPalette get palette => _palette;

  set palette(AppColorPalette newPalette) {
    _palette = newPalette;
    final event = ColorPalleteChanged(palleteName: _palette.palleteName);
    GlobalEventBus.instance.fire(event);
  }

  @override
  Color get title => _palette.title;

  @override
  Color get icons => _palette.icons;

  @override
  Color get shadowText => _palette.shadowText;

    @override
  String get palleteName => _palette.palleteName;
  
  @override
  Color get assistantMessageBubble => _palette.assistantMessageBubble;
  
  @override
  Color get userMessageBubble => _palette.userMessageBubble;
  
  @override
  Color get assistantMessageText => _palette.assistantMessageText;

  @override
  Color get toolResponse => _palette.toolResponse;
  
  
  @override
  Color get prompt => _palette.prompt;
  
  @override
  Color get userMessageText => _palette.userMessageText;
}
