/// The package dependency rules of ADR 001, as data and pure functions, so a
/// fixture can prove each rule fails without touching the real workspace.
library;

const appPackage = 'stays_app';
const corePackage = 'core';
const _featurePrefix = 'feature_';

/// Packages each kind of package may depend on. A package that matches none of
/// these is itself a violation: a new package needs a rule before it ships.
Set<String>? allowedDependencies(String package) {
  switch (package) {
    case corePackage:
      return {};
    case 'design_system':
    case 'l10n':
      return {corePackage};
    case 'listings':
      return {corePackage, 'design_system', 'l10n'};
    case appPackage:
      return null; // null = anything in the workspace
  }
  if (package.startsWith(_featurePrefix)) {
    return {corePackage, 'design_system', 'l10n', 'listings'};
  }
  throw ArgumentError.value(package, 'package', 'no dependency rule');
}

bool hasRule(String package) {
  try {
    allowedDependencies(package);
    return true;
  } on ArgumentError {
    return false;
  }
}

/// [internalDeps] maps each workspace package to the workspace packages it
/// declares. Returns one readable line per broken rule.
List<String> dependencyViolations(Map<String, Set<String>> internalDeps) {
  final violations = <String>[];
  for (final MapEntry(key: package, value: deps) in internalDeps.entries) {
    if (!hasRule(package)) {
      violations.add(
        '$package has no dependency rule, classify it in '
        'dependency_rules.dart',
      );
      continue;
    }
    final allowed = allowedDependencies(package);
    if (allowed == null) continue;
    for (final dep in deps.where((d) => !allowed.contains(d))) {
      violations.add(
        '$package must not depend on $dep'
        '${_isFeature(package) && _isFeature(dep) ? ' (a feature never '
                  'depends on another feature)' : ''}',
      );
    }
  }
  return violations;
}

/// One line per import that reaches a workspace package it did not declare, or
/// that reaches into another package's `lib/src/`.
///
/// Pub workspaces share one package config, so the compiler would accept both;
/// only this check stops them.
List<String> importViolations({
  required String package,
  required String path,
  required String source,
  required Set<String> declaredInternal,
  required Set<String> allInternal,
}) {
  final violations = <String>[];
  final lines = source.split('\n');
  final pattern = RegExp(
    r'''^\s*(?:import|export)\s+['"]package:(\w+)/([^'"]*)''',
  );
  for (var i = 0; i < lines.length; i++) {
    final match = pattern.firstMatch(lines[i]);
    if (match == null) continue;
    final target = match.group(1)!;
    if (target == package || !allInternal.contains(target)) continue;
    if (!declaredInternal.contains(target)) {
      violations.add('$path:${i + 1}  imports $target without declaring it');
    }
    if (match.group(2)!.startsWith('src/')) {
      violations.add('$path:${i + 1}  imports $target/src, use its barrel');
    }
  }
  return violations;
}

bool _isFeature(String package) => package.startsWith(_featurePrefix);
