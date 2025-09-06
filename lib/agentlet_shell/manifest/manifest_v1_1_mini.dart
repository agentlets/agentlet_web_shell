import 'package:wshell/agentlet_shell/manifest/manifest_interfaces.dart';

// ignore: camel_case_types
class ManifestV1_1_Mini extends IManifestMini {
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
 
  ManifestV1_1_Mini({
    required this.manifestVersion,
    required this.name,
    required this.version,
    required this.tagName,
    required this.groupId,
    required this.artifactId
  });

  factory ManifestV1_1_Mini.fromJs(Map<String, dynamic> jsObject) {
   
    return ManifestV1_1_Mini(
      manifestVersion: jsObject['manifestVersion'] ?? '',
      name: jsObject['name'] ?? '',
      version: jsObject['version'] ?? '',
      tagName: jsObject['tagName'] ?? '',
      groupId: jsObject['groupId'] ?? '',
      artifactId: jsObject['artifactId'] ?? '',
    );
  }

  @override
  String toString() {
    return 'ManifestV1_1_Mini(manifestVersion: $manifestVersion, name: $name, version: $version, tagName: $tagName, groupId: $groupId, artifactId: $artifactId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

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
      artifactId
    );
  }
}