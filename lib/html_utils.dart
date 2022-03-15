import 'dart:html' as html;
import 'dart:math';

/// Miscellaneous utility methods for [Rectangle].
extension RectangleUtils<T extends num> on Rectangle<T> {
  /// Returns the center of the [Rectangle].
  Point<num> get center => Point<num>(left + width / 2, top + height / 2);
}

/// Utility methods for [html.Element].
extension ElementUtilsExension on html.Element {
  /// Returns the bounding [Rectangle] of the [Element] relative to the
  /// document.
  Rectangle<num> get documentRect => Rectangle<num>(
        documentOffset.x,
        documentOffset.y,
        clientWidth,
        clientHeight,
      );

  /// Repositions the [Element], setting its top-left corner to the specified
  /// [Point] as pixel coordinates.
  void setTopLeft(Point<num> topLeft) {
    style
      ..left = '${topLeft.x}px'
      ..top = '${topLeft.y}px';
  }
}

/// Tries to parse a [bool] from a [String].
///
/// Returns `true` if the input is "true", "yes", or "1".  Returns `false` if
/// the input is "false", "no", or "0".  In both cases, case and whitespace are
/// ignored.
///
/// Returns `null` if the input is not recognized.
bool? tryParseBool(String value) {
  const trueStrings = {'true', 'yes', '1'};
  const falseStrings = {'false', 'no', '0'};
  value = value.trim().toLowerCase();
  if (trueStrings.contains(value)) {
    return true;
  } else if (falseStrings.contains(value)) {
    return false;
  }
  return null;
}
