import 'package:wshell/agentlet_shell/manifest/tool_v1.dart';
import 'package:wshell/agentlet_shell/manifest/manifest_interfaces.dart';
import 'package:wshell/agentlet_shell/manifest/tool.dart';

class ManifestV1 extends IManifest {
  @override
  final String manifestVersion;
  @override
  final String name;
  @override
  final String version;
  @override
  final String tagName;
  @override
  final String artifactId;
  @override
  final String groupId;
  @override
  final String description;
  @override
  final List<Tool> tools;

  ManifestV1({
    required this.manifestVersion,
    required this.name,
    required this.version,
    required this.tagName,
    required this.description,
    required this.tools,
    required this.groupId,
    required this.artifactId
  });

  factory ManifestV1.fromJs(Map<String, dynamic> jsObject) {
    final toolsList = (jsObject['tools'] as List<dynamic>).map((toolJson) {
      return ToolV1.fromJs(toolJson as Map<String, dynamic>);
    }).toList();

    return ManifestV1(
      manifestVersion: jsObject['manifestVersion'] ?? '',
      name: jsObject['name'] ?? '',
      version: jsObject['version'] ?? '',
      tagName: jsObject['tagName'] ?? '',
      groupId: jsObject['groupId'] ?? '',
      artifactId: jsObject['artifactId'] ?? '',
      description: jsObject['description'] ?? '',
      tools: toolsList,
    );
  }

  @override
  String toString() {
    return 'ManifestV1(manifestVersion: $manifestVersion, name: $name, version: $version, tagName: $tagName, groupId: $groupId, artifactId: $artifactId, description: $description, tools: $tools)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is ManifestV1) {
      return other.manifestVersion == manifestVersion &&
          other.name == name &&
          other.version == version &&
          other.tagName == tagName &&
          other.artifactId == artifactId &&
          other.groupId == groupId &&
          other.description == description &&
          _listEquals(other.tools, tools);
    }

    if (other is IManifestMini) {
      return other.manifestVersion == manifestVersion &&
          other.name == name &&
          other.version == version &&
          other.tagName == tagName &&
          other.artifactId == artifactId &&
          other.groupId == groupId;
    }

    return false;
  }

  @override
  int get hashCode {
    return Object.hash(
      manifestVersion,
      name,
      version,
      tagName,
      groupId,
      artifactId,
      description,
      Object.hashAll(tools),
    );
  }

  bool _listEquals(List<Tool> a, List<Tool> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
