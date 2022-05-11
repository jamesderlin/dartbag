import 'dart:html' as html;
import 'dart:math' as math;

import 'dart_utils.dart';

/// Wrapper around [html.querySelector] that also tries to cast it to the
/// specified [Element] type.
T? querySelectorAs<T extends html.Element>(String selectors) =>
    html.querySelector(selectors).tryAs<T>();

/// Miscellaneous utility methods for [html.Element].
extension ElementUtils on html.Element {
  /// Returns the bounding [Rectangle] of the [Element] relative to the
  /// document.
  math.Rectangle<num> get documentRect => math.Rectangle<num>(
        documentOffset.x,
        documentOffset.y,
        clientWidth,
        clientHeight,
      );

  /// Repositions the [Element], setting its top-left corner to the specified
  /// [Point] as pixel coordinates.
  void setTopLeft(math.Point<num> topLeft) {
    style
      ..left = '${topLeft.x}px'
      ..top = '${topLeft.y}px';
  }

  /// Sets the sole child for this.
  void setChild(html.Element child) {
    children
      ..clear()
      ..add(child);
  }
}

/// Returns a [Future] that should complete after the window has been repainted.
Future<void> get afterWindowRepaint async {
  await html.window.animationFrame;
  return Future.delayed(Duration.zero);
}

/// A class to add and manage CSS rules so that they can be removed later.
class TemporaryCssRule {
  final html.CssStyleSheet _styleSheet;
  final html.CssRule _addedRule;
  final int _expectedIndex;

  TemporaryCssRule._({
    required html.CssStyleSheet styleSheet,
    required html.CssRule addedRule,
    required int expectedIndex,
  })  : _styleSheet = styleSheet,
        _addedRule = addedRule,
        _expectedIndex = expectedIndex;

  /// Adds a CSS rule and returns a [TemporaryCssRule] object that can be
  /// used to remove it later.
  ///
  /// Returns `null` on failure.
  static TemporaryCssRule? add(String rule) {
    var styleSheets = html.document.styleSheets ?? <html.CssStyleSheet>[];
    var styleSheet = styleSheets.isEmpty ? null : styleSheets.last;
    if (styleSheet is! html.CssStyleSheet) {
      return null;
    }

    var index = styleSheet.insertRule(rule, styleSheet.cssRules.length);
    return TemporaryCssRule._(
      styleSheet: styleSheet,
      addedRule: styleSheet.cssRules[index],
      expectedIndex: index,
    );
  }

  /// Removes a CSS rule added by [add].
  ///
  /// The document must have existing style sheets already.
  ///
  /// Returns `true` if the rule was removed, `false` otherwise.
  bool remove() {
    var index = _expectedIndex;
    if (index >= _styleSheet.cssRules.length ||
        _styleSheet.cssRules[index] != _addedRule) {
      index = _styleSheet.cssRules.indexOf(_addedRule);
    }
    if (index == -1) {
      return false;
    }
    _styleSheet.removeRule(index);
    return true;
  }
}
