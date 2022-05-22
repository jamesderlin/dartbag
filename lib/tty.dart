import 'dart:io' as io;

import 'misc.dart';
import 'parse.dart';

/// Tries to get the size of the terminal.
///
/// Mimics the logic `shutil.get_terminal_size` from Python:
/// * Returns the values of the `COLUMNS` and `LINES` environment variables if
///   available. (However, these variables usually are unexported shell
///   variables and therefore typically are *not* available.)
/// * Otherwise queries the connected TTY.
/// * Otherwise falls back to default values (80 columns by 24 lines).
void getTerminalSize({
  OutputParameter<int>? width,
  OutputParameter<int>? height,
}) {
  width?.value = tryParseInt(io.Platform.environment['COLUMNS']) ??
      (io.stdout.hasTerminal ? io.stdout.terminalColumns : 80);
  height?.value = tryParseInt(io.Platform.environment['LINES']) ??
      (io.stdout.hasTerminal ? io.stdout.terminalLines : 24);
}

/// Word wraps a string to a maximum line length.
///
/// Existing newlines in the original string will be preserved.  Lines longer
/// than the maximum line length will be split at whitespace nearest to but
/// not beyond the maximum line length.  If there is no preceding whitespace in
/// the line, then the line will be split at the maximum line length.
///
/// [maxLineLength] must be positive.
///
/// [hangingIndent] specifies how many spaces to indent all but the first line.
/// It must be non-negative and strictly less than [maxLineLength].
String wordWrap(
  String s,
  int maxLineLength, {
  int hangingIndent = 0,
}) {
  assert(maxLineLength > 0);
  assert(hangingIndent >= 0);
  assert(hangingIndent < maxLineLength);

  var lines = s.split('\n');
  var result = <String>[];

  var wordBreakRegExp = RegExp(r'\s');
  var hangingIndentString = ' ' * hangingIndent;

  var i = 0;
  var indentString = '';
  var j = 0;
  while (i < lines.length && j < 20) {
    j += 1;
    var line = '$indentString${lines[i]}';
    indentString = hangingIndentString;

    if (line.length <= maxLineLength) {
      result.add(line);
      i += 1;
      continue;
    }

    var breakIndex = line.lastIndexOf(wordBreakRegExp, maxLineLength);
    if (breakIndex < hangingIndent) {
      breakIndex = maxLineLength;
    }
    result.add(line.substring(0, breakIndex).trimRight());
    lines[i] = line.substring(breakIndex).trimLeft();
  }

  return result.join('\n');
}
