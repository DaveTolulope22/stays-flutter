/// The brief's "no literal in a widget" and "no tenant in code" rules, as pure
/// functions over source text, so a fixture can prove each one fails.
library;

class Violation {
  const Violation(this.line, this.rule, this.snippet);

  final int line;
  final String rule;
  final String snippet;
}

/// Colours, dimensions and copy. Run it on widget code only.
List<Violation> literalViolations(String source) {
  final withStrings = stripComments(source);
  final code = stripComments(source, blankStrings: true);
  final found = _Collector(source);

  for (final m in _colourApi.allMatches(code)) {
    found.add(m.start, 'colour');
  }
  for (final m in _hexNumber.allMatches(code)) {
    found.add(m.start, 'colour');
  }
  for (final m in _hexString.allMatches(withStrings)) {
    found.add(m.start, 'colour');
  }

  for (final call in _dimensionCalls.allMatches(code)) {
    final open = call.end - 1;
    final args = code.substring(open, _closingParen(code, open));
    for (final n in _number.allMatches(args)) {
      found.add(open + n.start, 'dimension');
    }
  }
  for (final m in _sizeArgument.allMatches(code)) {
    found.add(m.start, 'dimension');
  }

  for (final m in _textLiteral.allMatches(code)) {
    found.add(m.start, 'copy');
  }
  for (final m in _labelArgument.allMatches(code)) {
    found.add(m.start, 'copy');
  }

  return found.sorted();
}

/// A tenant slug or a hard-coded currency anywhere in non-comment code.
///
/// [slugs] come from the build, never from this file, so this file names no
/// tenant either.
List<Violation> tenantViolations(String source, Set<String> slugs) {
  final code = stripComments(source);
  final found = _Collector(source);

  if (slugs.isNotEmpty) {
    final slug = RegExp(
      '\\b(?:${slugs.map(RegExp.escape).join('|')})\\b',
      caseSensitive: false,
    );
    for (final m in slug.allMatches(code)) {
      found.add(m.start, 'tenant');
    }
  }
  for (final m in _currency.allMatches(code)) {
    found.add(m.start, 'currency');
  }
  return found.sorted();
}

/// The product flavor names declared in a `build.gradle.kts`.
Set<String> flavorSlugs(String gradle) {
  final start = RegExp(r'productFlavors\s*\{').firstMatch(gradle);
  if (start == null) return {};
  var depth = 1;
  var i = start.end;
  while (i < gradle.length && depth > 0) {
    if (gradle[i] == '{') depth++;
    if (gradle[i] == '}') depth--;
    i++;
  }
  final block = gradle.substring(start.end, i);
  return RegExp(r'create\("([^"]+)"\)')
      .allMatches(block)
      .map((m) => m.group(1)!)
      .toSet();
}

/// [source] with every comment replaced by spaces, and optionally the text of
/// every string too (the quotes stay). Length and line breaks are preserved,
/// so an offset in the result is the same offset in the source.
///
/// A regex alone would flag `Colors.` in a comment, and `//` in a URL string
/// would look like a comment, so strings have to be tracked.
String stripComments(String source, {bool blankStrings = false}) {
  final out = StringBuffer();
  final stack = <_StringFrame>[];
  var i = 0;

  while (i < source.length) {
    final c = source[i];
    final frame = stack.isEmpty ? null : stack.last;

    if (frame != null && frame.braces < 0) {
      if (!frame.raw && c == r'\') {
        final end = i + 2 > source.length ? source.length : i + 2;
        final pair = source.substring(i, end);
        out.write(blankStrings ? _blank(pair) : pair);
        i = end;
      } else if (!frame.raw && c == r'$' && source.startsWith('{', i + 1)) {
        out.write(r'${');
        frame.braces = 0;
        i += 2;
      } else if (source.startsWith(frame.quote, i)) {
        out.write(frame.quote);
        i += frame.quote.length;
        stack.removeLast();
      } else {
        out.write(blankStrings ? _blank(c) : c);
        i++;
      }
      continue;
    }

    if (frame != null) {
      if (c == '{') {
        frame.braces++;
      } else if (c == '}') {
        if (frame.braces == 0) {
          frame.braces = -1;
          out.write(c);
          i++;
          continue;
        }
        frame.braces--;
      }
    }

    if (source.startsWith('//', i)) {
      var end = source.indexOf('\n', i);
      if (end < 0) end = source.length;
      out.write(_blank(source.substring(i, end)));
      i = end;
    } else if (source.startsWith('/*', i)) {
      var depth = 1;
      var j = i + 2;
      while (j < source.length && depth > 0) {
        if (source.startsWith('/*', j)) {
          depth++;
          j += 2;
        } else if (source.startsWith('*/', j)) {
          depth--;
          j += 2;
        } else {
          j++;
        }
      }
      out.write(_blank(source.substring(i, j)));
      i = j;
    } else if (c == "'" || c == '"') {
      final quote = source.startsWith(c * 3, i) ? c * 3 : c;
      final raw =
          i > 0 &&
          source[i - 1] == 'r' &&
          (i < 2 || !_identifierChar.hasMatch(source[i - 2]));
      stack.add(_StringFrame(quote, raw));
      out.write(quote);
      i += quote.length;
    } else {
      out.write(c);
      i++;
    }
  }
  return out.toString();
}

class _StringFrame {
  _StringFrame(this.quote, this.raw);

  final String quote;
  final bool raw;

  /// -1 while in the text of the string, otherwise the brace depth inside a
  /// `${ ... }` interpolation, which is code again.
  int braces = -1;
}

class _Collector {
  _Collector(this._source) : _lines = _source.split('\n');

  final String _source;
  final List<String> _lines;
  final _found = <Violation>[];

  void add(int offset, String rule) {
    final line = '\n'.allMatches(_source.substring(0, offset)).length + 1;
    _found.add(Violation(line, rule, _lines[line - 1].trim()));
  }

  List<Violation> sorted() => _found..sort((a, b) => a.line - b.line);
}

String _blank(String text) => text.replaceAll(RegExp(r'[^\r\n]'), ' ');

int _closingParen(String s, int open) {
  var depth = 0;
  for (var i = open; i < s.length; i++) {
    if (s[i] == '(') depth++;
    if (s[i] == ')' && --depth == 0) return i;
  }
  return s.length;
}

final _identifierChar = RegExp(r'[\w$]');

// `\b` keeps `AppColors.` and `MaterialColor(` out.
final _colourApi = RegExp(r'\bColors\.|\bColor(?:\.from\w+)?\(');
final _hexNumber = RegExp(r'\b0x[0-9a-fA-F]{6,8}\b');
final _hexString = RegExp('''['"]#[0-9a-fA-F]{3,8}['"]''');

final _dimensionCalls = RegExp(
  r'\b(?:EdgeInsets|EdgeInsetsDirectional|BorderRadius|BorderRadiusDirectional'
  r'|Radius|SizedBox)(?:\.\w+)?\(',
);
// Not part of an identifier, so `AppSpacing.x2` passes and `8` or `1.5` fail.
final _number = RegExp(r'(?<![\w$])\d+(?:\.\d+)?');
final _sizeArgument = RegExp(
  r'\b(?:width|height|minWidth|maxWidth|minHeight|maxHeight|size|iconSize'
  r'|fontSize|dimension|spacing|runSpacing|elevation|strokeWidth|thickness)'
  r'\s*:\s*-?\d',
);

final _textLiteral = RegExp(
  '''\\b(?:Text|SelectableText)\\(\\s*(?:const\\s+)?r?['"]''',
);
final _labelArgument = RegExp(
  r'''\b(?:tooltip|label|labelText|hintText|helperText|errorText|semanticLabel'''
  r'''|semanticsLabel|title)\s*:\s*(?:const\s+)?r?['"]''',
);

final _currency = RegExp(
  r'\b(?:EUR|CHF|USD|GBP|JPY|CAD|AUD|SEK|NOK|DKK|PLN|CZK)\b|[€£¥]',
);
