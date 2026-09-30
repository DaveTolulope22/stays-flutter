import 'dart:io';

import 'package:yaml/yaml.dart';

/// One workspace member, read from its own `pubspec.yaml`.
class WorkspacePackage {
  const WorkspacePackage({
    required this.name,
    required this.directory,
    required this.dependencies,
  });

  final String name;
  final Directory directory;

  /// Runtime and dev dependencies together: a test-only edge is still an edge.
  final Set<String> dependencies;
}

/// The directory whose `pubspec.yaml` declares the `workspace:` list.
///
/// Walks up from the working directory, so the tests pass whether they are run
/// from the repo root (`melos run test`) or from `apps/stays_app`.
Directory findWorkspaceRoot() {
  var dir = Directory.current.absolute;
  while (true) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    if (pubspec.existsSync()) {
      final yaml = loadYaml(pubspec.readAsStringSync());
      if (yaml is YamlMap && yaml.containsKey('workspace')) return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('No workspace pubspec.yaml above ${Directory.current}');
    }
    dir = parent;
  }
}

/// Every member listed under `workspace:` in the root pubspec.
List<WorkspacePackage> workspacePackages() {
  final root = findWorkspaceRoot();
  final rootYaml =
      loadYaml(File('${root.path}/pubspec.yaml').readAsStringSync()) as YamlMap;
  final members = (rootYaml['workspace'] as YamlList).cast<String>();

  return [
    for (final member in members) _read(Directory('${root.path}/$member')),
  ];
}

WorkspacePackage _read(Directory directory) {
  final yaml = loadYaml(
    File('${directory.path}/pubspec.yaml').readAsStringSync(),
  ) as YamlMap;
  Set<String> keys(String section) {
    final value = yaml[section];
    return value is YamlMap ? value.keys.cast<String>().toSet() : <String>{};
  }

  return WorkspacePackage(
    name: yaml['name'] as String,
    directory: directory,
    dependencies: {...keys('dependencies'), ...keys('dev_dependencies')},
  );
}
