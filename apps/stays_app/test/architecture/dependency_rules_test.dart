import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/dependency_rules.dart';
import 'support/workspace.dart';

void main() {
  group('rules catch violations (fixtures)', () {
    test('a feature depending on another feature fails', () {
      final v = dependencyViolations({
        'feature_host': {'core', 'feature_browse'},
      });
      expect(v, hasLength(1));
      expect(
        v.single,
        contains('feature_host must not depend on feature_browse'),
      );
    });

    test('core depending on anything internal fails', () {
      final v = dependencyViolations({
        'core': {'design_system'},
      });
      expect(v.single, contains('core must not depend on design_system'));
    });

    test('design_system and l10n may only use core', () {
      final v = dependencyViolations({
        'design_system': {'core', 'l10n'},
        'l10n': {'core'},
      });
      expect(v.single, contains('design_system must not depend on l10n'));
    });

    test('a shared package may not depend on a feature', () {
      final v = dependencyViolations({
        'listings': {'core', 'feature_auth'},
      });
      expect(v.single, contains('listings must not depend on feature_auth'));
    });

    test('an unclassified package fails', () {
      final v = dependencyViolations({'utils': <String>{}});
      expect(v.single, contains('utils has no dependency rule'));
    });

    test('the legal shape passes', () {
      expect(
        dependencyViolations({
          'core': <String>{},
          'design_system': {'core'},
          'l10n': {'core'},
          'listings': {'core', 'design_system', 'l10n'},
          'feature_host': {'core', 'design_system', 'l10n', 'listings'},
          'stays_app': {'core', 'feature_host', 'feature_auth'},
        }),
        isEmpty,
      );
    });

    const all = {'core', 'feature_host', 'feature_browse'};

    test('an undeclared workspace import fails', () {
      final v = importViolations(
        package: 'feature_host',
        path: 'a.dart',
        source: "import 'package:feature_browse/feature_browse.dart';",
        declaredInternal: {'core'},
        allInternal: all,
      );
      expect(
        v.single,
        contains('a.dart:1  imports feature_browse without declaring'),
      );
    });

    test('reaching into another package src fails', () {
      final v = importViolations(
        package: 'feature_host',
        path: 'a.dart',
        source: "\nimport 'package:core/src/x.dart';",
        declaredInternal: {'core'},
        allInternal: all,
      );
      expect(v.single, contains('a.dart:2  imports core/src'));
    });

    test('own src, declared barrel and third-party imports pass', () {
      final v = importViolations(
        package: 'feature_host',
        path: 'a.dart',
        source:
            "import 'package:feature_host/src/a.dart';\n"
            "import 'package:core/core.dart';\n"
            "import 'package:dio/dio.dart';",
        declaredInternal: {'core'},
        allInternal: all,
      );
      expect(v, isEmpty);
    });
  });

  group('the real workspace', () {
    final packages = workspacePackages();
    final names = packages.map((p) => p.name).toSet();

    test('all nine members were found', () {
      // Guards against a wrong working directory scanning nothing and passing.
      expect(names, hasLength(9));
      expect(names, containsAll(['stays_app', 'core', 'listings']));
    });

    test('package dependencies follow ADR 001', () {
      final internal = {
        for (final p in packages) p.name: p.dependencies.intersection(names),
      };
      expect(dependencyViolations(internal), isEmpty);
    });

    test('imports respect declarations and barrels', () {
      final violations = <String>[];
      var scanned = 0;
      for (final p in packages) {
        final declared = p.dependencies.intersection(names);
        for (final folder in ['lib', 'test']) {
          final dir = Directory('${p.directory.path}/$folder');
          if (!dir.existsSync()) continue;
          for (final file
              in dir
                  .listSync(recursive: true)
                  .whereType<File>()
                  .where((f) => f.path.endsWith('.dart'))) {
            scanned++;
            violations.addAll(
              importViolations(
                package: p.name,
                path: file.path.replaceAll('\\', '/'),
                source: file.readAsStringSync(),
                declaredInternal: declared,
                allInternal: names,
              ),
            );
          }
        }
      }
      expect(scanned, greaterThan(50));
      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  });
}
