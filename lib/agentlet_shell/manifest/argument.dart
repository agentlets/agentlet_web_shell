
class Argument {
  final String name;
  final String type;
  final String description;

  Argument({
    required this.name,
    required this.type,
    required this.description,
  });

  factory Argument.fromJs(Map<String, dynamic> jsObject) {
    return Argument(
      name: jsObject['name'] ?? '',
      type: jsObject['type'] ?? '',
      description: jsObject['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Argument(name: $name, type: $type, description: $description)';
  }
}
