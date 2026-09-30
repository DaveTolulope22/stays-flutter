import 'dart:io';

/// The hand-written Dart files under [dir], as paths with forward slashes.
///
/// Generated code is not ours to police. [excludeUnder] are folders relative to
/// [dir] that are skipped, used for the design-system token and theme source.
List<File> dartSources(Directory dir, {List<String> excludeUnder = const []}) {
  if (!dir.existsSync()) return [];
  final base = _normal(dir.path);
  return [
    for (final file in dir.listSync(recursive: true).whereType<File>())
      if (_isHandWritten(_normal(file.path), base, excludeUnder)) file,
  ];
}

String displayPath(File file) => _normal(file.path);

String _normal(String path) => path.replaceAll('\\', '/');

bool _isHandWritten(String path, String base, List<String> excludeUnder) {
  if (!path.endsWith('.dart')) return false;
  if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) return false;
  if (path.contains('/lib/src/generated/')) return false;
  final relative = path.substring(base.length + 1);
  return !excludeUnder.any(relative.startsWith);
}
