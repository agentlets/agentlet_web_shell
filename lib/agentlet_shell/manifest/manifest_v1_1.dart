import 'package:wshell/agentlet_shell/manifest/manifest_interfaces.dart';
import 'package:wshell/agentlet_shell/manifest/tool.dart';
import 'package:wshell/agentlet_shell/manifest/tool_v1_1.dart';

// ignore: camel_case_types
class ManifestV1_1 extends IManifest {
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
  final String behaviorPrompt;
  final String iconURL;

  ManifestV1_1({
    required this.manifestVersion,
    required this.name,
    required this.version,
    required this.tagName,
    required this.description,
    required this.groupId,
    required this.artifactId,
    required this.tools,
    required this.behaviorPrompt,
    required this.iconURL
  });

  factory ManifestV1_1.fromJs(Map<String, dynamic> jsObject) {
    final toolsList = (jsObject['tools'] as List<dynamic>).map((toolJson) {
      return ToolV1_1.fromJs(toolJson as Map<String, dynamic>);
    }).toList();

    final promptList = (jsObject['behavior_prompt'] as List<dynamic>).cast<String>();

    return ManifestV1_1(
      manifestVersion: jsObject['manifestVersion'] ?? '',
      name: jsObject['name'] ?? '',
      version: jsObject['version'] ?? '',
      tagName: jsObject['tagName'] ?? '',
      description: jsObject['description'] ?? '',
      groupId: jsObject['groupId'] ?? '',
      artifactId: jsObject['artifactId'] ?? '',
      tools: toolsList,
      behaviorPrompt: promptList.join('\n'),
      iconURL: jsObject['iconURL'] ?? '',
    );
  }

  @override
  String toString() {
    return 'ManifestV1_1(manifestVersion: $manifestVersion, name: $name, version: $version, tagName: $tagName, groupId: $groupId, artifactId: $artifactId, description: $description, tools: $tools, iconURL: $iconURL, behaviorPrompt: $behaviorPrompt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is ManifestV1_1) {
      return other.manifestVersion == manifestVersion &&
          other.name == name &&
          other.version == version &&
          other.tagName == tagName &&
          other.artifactId == artifactId &&
          other.groupId == groupId &&
          other.description == description &&
          other.behaviorPrompt == behaviorPrompt &&
          other.iconURL == iconURL &&
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
      behaviorPrompt,
      iconURL,
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