abstract class Tool {
  String get name;
  String get description;
  Map<String, dynamic> toMap();

  @override
  String toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Tool &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(name, description);
}