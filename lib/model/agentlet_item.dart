import 'package:wshell/shared/app_error.dart';

enum AgentletType {
  builtin,
  installed
}

enum LicenseType {
  openSource,
  commercial
}

abstract class Agentlet {
  final String id;
  final String name;
  final String? iconPath;
  String? iconUrl;
  final AgentletType type;
  String? agentletBaseUrl;
  final LicenseType licenseType;
  final String? sourceCodeURL;

  Agentlet({
    required this.id,
    required this.name, 
    this.iconPath, 
    this.iconUrl,
    this.type = AgentletType.builtin,
    this.agentletBaseUrl,
    required this.licenseType,
    this.sourceCodeURL,
    }) {
      if (licenseType == LicenseType.commercial && sourceCodeURL != null) {
        throw ArgumentError('A commercial agentlet cannot define sourceCodeURL.');
      }
    }

  Map<String, dynamic> toJson() => toMap();

  Map<String, dynamic> toMap() {
    throw ApplicationError(message: 'toMap must be implemented in subclases');
  }

  @override
  String toString() {
    final typeStr = type.toString().split('.').last;
    final licenseStr = licenseType.toString().split('.').last;
    return 'Agentlet(id: $id, name: $name, iconPath: $iconPath, iconUrl: $iconUrl, type: $typeStr, agentletBaseUrl: $agentletBaseUrl, licenseType: $licenseStr, sourceCodeURL: $sourceCodeURL)';
  }
}

class BuiltinAgentlet extends Agentlet {
  BuiltinAgentlet({
    required super.id,
    required super.name,
    super.iconPath,
    super.iconUrl,
    super.agentletBaseUrl,
    required super.licenseType,
    super.sourceCodeURL,
  }) : super(
        type: AgentletType.builtin,
      );
  @override
  String toString() {
    final typeStr = type.toString().split('.').last;
    final licenseStr = licenseType.toString().split('.').last;
    return 'BuiltinAgentlet(id: $id, name: $name, iconPath: $iconPath, iconUrl: $iconUrl, type: $typeStr, agentletBaseUrl: $agentletBaseUrl, licenseType: $licenseStr, sourceCodeURL: $sourceCodeURL)';
  }
}

class InstalledAgentlet extends Agentlet {
  InstalledAgentlet({
    required super.id,
    required super.name,
    super.iconPath,
    super.iconUrl,
    super.agentletBaseUrl,
    required super.licenseType,
    super.sourceCodeURL,
  }) : super(
          type: AgentletType.installed,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'iconUrl': iconUrl,
      'agentletBaseUrl': agentletBaseUrl,
      'licenseType': licenseType.toString().split('.').last,
      'sourceCodeURL': sourceCodeURL,
      'type': type.toString().split('.').last,
    };
  }

  @override
  Map<String, dynamic> toJson() => toMap();

  factory InstalledAgentlet.fromMap(Map<String, dynamic> map) {
    // Allow both camelCase and snake_case, and tolerate case differences in values
    String? getStringProperty(String a, String b) => (map[a] ?? map[b]) as String?;
    final id = getStringProperty('id', 'id');
    final name = getStringProperty('name', 'name');
    if (id == null || name == null) {
      throw ArgumentError('Missing required fields: id and/or name');
    }

    final licenseRaw = (map['licenseType'] ?? map['license_type'])?.toString();
    if (licenseRaw == null) {
      throw ArgumentError('Missing required field: licenseType');
    }
    final license = LicenseType.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == licenseRaw.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid licenseType: $licenseRaw'),
    );

    return InstalledAgentlet(
      id: id,
      name: name,
      iconPath: getStringProperty('iconPath', 'icon_path'),
      iconUrl: getStringProperty('iconUrl', 'icon_url'),
      agentletBaseUrl: getStringProperty('agentletBaseUrl', 'agentlet_base_url'),
      licenseType: license,
      sourceCodeURL: getStringProperty('sourceCodeURL', 'source_code_url'),
    );
  }

  factory InstalledAgentlet.fromJson(Map<String, dynamic> json) => InstalledAgentlet.fromMap(json);

  @override
  String toString() {
    final typeStr = type.toString().split('.').last;
    final licenseStr = licenseType.toString().split('.').last;
    return 'InstalledAgentlet(id: $id, name: $name, iconPath: $iconPath, iconUrl: $iconUrl, type: $typeStr, agentletBaseUrl: $agentletBaseUrl, licenseType: $licenseStr, sourceCodeURL: $sourceCodeURL)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InstalledAgentlet &&
        other.id == id &&
        other.name == name &&
        other.iconPath == iconPath &&
        other.iconUrl == iconUrl &&
        other.agentletBaseUrl == agentletBaseUrl &&
        other.licenseType == licenseType &&
        other.sourceCodeURL == sourceCodeURL &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        iconPath,
        iconUrl,
        agentletBaseUrl,
        licenseType,
        sourceCodeURL,
        type,
      );
}