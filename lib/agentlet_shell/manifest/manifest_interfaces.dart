import 'package:wshell/agentlet_shell/manifest/manifest_exports.dart';

abstract class IManifestMini {
  String get manifestVersion;
  String get name;
  String get version;
  String get tagName;
  String get groupId;
  String get artifactId;

  String get componentId {
    final normalizedGroupId = groupId.replaceAll('.', '-');
    final normalizedArtifactId = artifactId.replaceAll('.', '-');
    final normalizedTagName = tagName;
    final normalizedVersion = version.replaceAll('.', '-');
    return '$normalizedGroupId-$normalizedArtifactId-$normalizedTagName-$normalizedVersion';
  }
  // ignore: non_constant_identifier_names
  ManifestV1_1_Mini? get v1_1_mini => this is ManifestV1_1_Mini ? this as ManifestV1_1_Mini : null;
  ManifestV1? get v1 => this is ManifestV1 ? this as ManifestV1 : null;
  ManifestV1_1? get v1_1 => this is ManifestV1_1 ? this as ManifestV1_1 : null;
}

abstract class IManifest extends IManifestMini {
  String get description;
  List<Tool> get tools;
  ManifestV1? get v1 => this is ManifestV1 ? this as ManifestV1 : null;
  ManifestV1_1? get v1_1 => this is ManifestV1_1 ? this as ManifestV1_1 : null;
}
