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
