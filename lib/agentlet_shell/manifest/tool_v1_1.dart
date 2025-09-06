
import 'package:wshell/agentlet_shell/manifest/tool.dart';

class ToolV1_1 implements Tool {
  @override
  final String name;
  @override
  final String description;
  final Map<String, dynamic> parameters;
  //final List<String> required;

  ToolV1_1({
    required this.name,
    required this.description,
    required this.parameters,
    //required this.required,
  });

  factory ToolV1_1.fromJs(Map<String, dynamic> jsObject) {
    final name = jsObject['name'] ?? '';
    final description = jsObject['description'] ?? '';
    final paramsJs = jsObject['parameters'] as Map<String, dynamic>? ?? {};

    return ToolV1_1(
      name: name,
      description: description,
      parameters: paramsJs
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'parameters': parameters,
     // 'required': required,
    };
  }

  @override
  String toString() {
    return 'ToolV1_1(name: $name, description: $description, parameters: $parameters)';
  }
}
