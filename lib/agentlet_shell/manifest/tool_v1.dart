
import 'package:wshell/agentlet_shell/manifest/tool.dart';
import 'argument.dart';

class ToolV1 implements Tool {
  @override
  final String name;
  @override
  final String description;
  final List<Argument> arguments;

  ToolV1({
    required this.name,
    required this.description,
    required this.arguments,
  });

  factory ToolV1.fromJs(Map<String, dynamic> jsObject) {
    final argumentsJson = jsObject['arguments'] as List<dynamic>? ?? [];
    final argsList = argumentsJson
        .map((arg) => Argument.fromJs(arg as Map<String, dynamic>))
        .toList();

    return ToolV1(
      name: jsObject['name'] ?? '',
      description: jsObject['description'] ?? '',
      arguments: argsList,
    );
  }

  @override
  String toString() {
    return 'ToolV1(name: $name, description: $description, arguments: $arguments)';
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'arguments': arguments.map((arg) => arg.toMap()).toList(),
    };
  }
}
