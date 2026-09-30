import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/literal_rules.dart';
import 'support/source_files.dart';
import 'support/workspace.dart';

/// Rules that must flag [bad] and leave [good] alone. Tenant slugs here are
/// made up: no real tenant name may appear in the repo's Dart code (ADR 005).
List<String> _rules(String source) => [
  for (final v in literalViolations(source)) v.rule,
];

void main() {
  group('colour rules (fixtures)', () {
    test('Colors, Color(...), 0x literals and hex strings are flagged', () {
      expect(_rules('final a = Colors.red;'), ['colour']);
      expect(_rules('final a = Color(0xFF112233);'), ['colour', 'colour']);
      expect(_rules('final a = Color.fromARGB(1, 2, 3, 4);'), ['colour']);
      expect(_rules("final a = '#ff00aa';"), ['colour']);
    });

    test('theme-driven colours pass', () {
      expect(_rules('final a = AppColors.of(context).textMuted;'), isEmpty);
      expect(
        _rules('final a = Theme.of(context).colorScheme.primary;'),
        isEmpty,
      );
    });
  });

  group('dimension rules (fixtures)', () {
    test('a number inside insets, boxes and radii is flagged', () {
      expect(_rules('EdgeInsets.all(8)'), ['dimension']);
      expect(_rules('EdgeInsets.symmetric(horizontal: 16, vertical: 4)'), [
        'dimension',
        'dimension',
      ]);
      expect(_rules('const SizedBox(height: 12)'), ['dimension', 'dimension']);
      expect(_rules('BorderRadius.circular(8.5)'), ['dimension']);
      expect(_rules('Radius.circular(4)'), ['dimension']);
    });

    test('a multiplied token is still a raw number', () {
      expect(_rules('EdgeInsets.all(AppSpacing.md * 2)'), ['dimension']);
    });

    test('size arguments with a number are flagged', () {
      expect(_rules('Icon(Icons.add, size: 24)'), ['dimension']);
      expect(_rules('Container(width: 100)'), ['dimension']);
    });

    test('tokens pass, including names that end in a digit', () {
      expect(_rules('EdgeInsets.all(AppSpacing.md)'), isEmpty);
      expect(_rules('EdgeInsets.all(AppSpacing.x2)'), isEmpty);
      expect(_rules('const SizedBox(height: AppSpacing.lg)'), isEmpty);
      expect(_rules('BorderRadius.circular(AppRadius.md)'), isEmpty);
      expect(_rules('Icon(Icons.add, size: AppSizes.icon)'), isEmpty);
      expect(_rules('const SizedBox.shrink()'), isEmpty);
    });

    test('a call that spans lines is read to its closing bracket', () {
      const source = '''
EdgeInsets.symmetric(
  horizontal: AppSpacing.md,
  vertical: 6,
)''';
      final v = literalViolations(source);
      expect(v.single.line, 3);
    });
  });

  group('copy rules (fixtures)', () {
    test('a string literal as text or as a label is flagged', () {
      expect(_rules("Text('Sign in')"), ['copy']);
      expect(_rules('const Text("Sign in")'), ['copy']);
      expect(_rules("tooltip: 'Close'"), ['copy']);
      expect(_rules("Semantics(label: 'Close')"), ['copy']);
      expect(_rules("InputDecoration(labelText: 'Email')"), ['copy']);
    });

    test('a literal on the next line is found and reported on its line', () {
      final v = literalViolations("Text(\n  'Sign in',\n)");
      expect(v.single.rule, 'copy');
      expect(v.single.line, 1);
    });

    test('translated and data text passes', () {
      expect(_rules('Text(l10n.signIn)'), isEmpty);
      expect(_rules('Text(listing.title)'), isEmpty);
      expect(_rules('Text(l10n.count(3))'), isEmpty);
      expect(_rules('tooltip: l10n.close'), isEmpty);
    });
  });

  group('what is not code (fixtures)', () {
    test('comments are ignored, with line numbers intact', () {
      const source = '''
// Colors.red and Text('x') are only discussed here
/// EdgeInsets.all(8)
/* Color(0xFF000000)
   still a comment */
final bad = Colors.red;''';
      final v = literalViolations(source);
      expect(v.single.line, 5);
      expect(v.single.snippet, 'final bad = Colors.red;');
    });

    test('a URL in a string is not a comment', () {
      const source = "final a = 'https://x.test/a'; final b = Colors.red;";
      expect(_rules(source), ['colour']);
    });

    test('rule words inside a string are not code', () {
      expect(_rules("final a = 'Colors.red and EdgeInsets.all(8)';"), isEmpty);
      expect(_rules(r"final a = 'Hello ${name}';"), isEmpty);
    });

    test('code inside an interpolation is still code', () {
      expect(_rules(r"final a = 'x ${Colors.red}';"), ['colour']);
    });
  });

  group('tenant and currency rules (fixtures)', () {
    const slugs = {'tenanta', 'tenantb'};
    List<String> run(String s) => [
      for (final v in tenantViolations(s, slugs)) v.rule,
    ];

    test('a slug is flagged as a whole word, in any case', () {
      expect(run("final t = 'tenanta';"), ['tenant']);
      expect(run('final t = TenantB;'), ['tenant']);
      expect(run('final tenantA2 = 1;'), isEmpty);
    });

    test('a hard-coded currency is flagged', () {
      expect(run("final c = 'EUR';"), ['currency']);
      expect(run("final c = 'CHF ';"), ['currency']);
      expect(run("final c = '€';"), ['currency']);
    });

    test('comments and generic code pass', () {
      expect(run('// tenanta and CHF are fine in a comment'), isEmpty);
      expect(run('final c = listing.currency;'), isEmpty);
    });

    test('flavor names are read from the Gradle productFlavors block', () {
      const gradle = '''
android {
    signingConfigs { create("release") { } }
    productFlavors {
        create("tenanta") { dimension = "tenant" }
        create("tenantb") { applicationIdSuffix = ".b" }
    }
    buildTypes { release { } }
}''';
      expect(flavorSlugs(gradle), {'tenanta', 'tenantb'});
      expect(flavorSlugs('android { }'), isEmpty);
    });
  });

  group('the real code', () {
    final packages = workspacePackages();
    final root = findWorkspaceRoot();

    // Widget code: the shell, the domain package, every feature and the
    // design system, which skips only its token and theme source (decision D).
    final widgetRoots = <String, ({Directory lib, List<String> skip})>{
      for (final p in packages)
        if (p.name == 'stays_app' ||
            p.name == 'listings' ||
            p.name.startsWith('feature_'))
          p.name: (lib: Directory('${p.directory.path}/lib'), skip: const []),
      for (final p in packages)
        if (p.name == 'design_system')
          p.name: (
            lib: Directory('${p.directory.path}/lib'),
            skip: const ['src/tokens/', 'src/theme/'],
          ),
    };

    test('every widget root was found', () {
      expect(widgetRoots.length, greaterThanOrEqualTo(7));
      expect(
        widgetRoots.keys,
        containsAll(['stays_app', 'listings', 'design_system']),
      );
    });

    for (final MapEntry(key: name, value: r) in widgetRoots.entries) {
      test('$name has no colour, dimension or copy literals', () {
        final files = dartSources(r.lib, excludeUnder: r.skip);
        expect(files, isNotEmpty, reason: 'scanned nothing in ${r.lib.path}');

        final hits = <String>[];
        for (final file in files) {
          for (final v in literalViolations(file.readAsStringSync())) {
            hits.add('${displayPath(file)}:${v.line}  ${v.rule}  ${v.snippet}');
          }
        }
        expect(hits, isEmpty, reason: '\n${hits.join('\n')}');
      });
    }

    test('design_system widgets are scanned, its tokens and theme are not', () {
      final ds = widgetRoots['design_system']!;
      final scanned = dartSources(
        ds.lib,
        excludeUnder: ds.skip,
      ).map(displayPath).toList();
      expect(scanned, anyElement(endsWith('widgets/month_calendar.dart')));
      expect(scanned, everyElement(isNot(contains('/src/tokens/'))));
      expect(scanned, everyElement(isNot(contains('/src/theme/'))));
    });

    test('no tenant name or currency in any package', () {
      final gradle = File(
        '${root.path}/apps/stays_app/android/app/build.gradle.kts',
      ).readAsStringSync();
      final slugs = flavorSlugs(gradle);
      expect(slugs, isNotEmpty, reason: 'no flavors found in build.gradle.kts');

      final hits = <String>[];
      var scanned = 0;
      for (final p in packages) {
        for (final file in dartSources(Directory('${p.directory.path}/lib'))) {
          scanned++;
          for (final v in tenantViolations(file.readAsStringSync(), slugs)) {
            hits.add('${displayPath(file)}:${v.line}  ${v.rule}  ${v.snippet}');
          }
        }
      }
      expect(scanned, greaterThan(100));
      expect(hits, isEmpty, reason: '\n${hits.join('\n')}');
    });
  });
}
