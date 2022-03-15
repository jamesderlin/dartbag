import 'dart:async';
import 'dart:collection';
import 'dart:html' as html;

import 'package:logging/logging.dart' as log;

/// Function callback type for [ExitHandler.register].
typedef VoidCallback = void Function();

/// Manages callbacks to execute when unloading the web page.
///
/// Callbacks will be executed in reverse order of registration.
class ExitHandler {
  // ignore: prefer_collection_literals
  final _cleanupCallbacks = LinkedHashMap<Object, VoidCallback>();

  ExitHandler._() {
    addSubscription(html.window.onUnload.listen(_onUnload));
  }

  void _onUnload(html.Event _) {
    log.Logger.root.info(
      () =>
          '_ExitHandler: Firing ${_cleanupCallbacks.length} onUnload callbacks',
    );
    for (var callback in _cleanupCallbacks.values.toList().reversed) {
      try {
        callback();

        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        log.Logger.root.warning('_ExitHandler: Cleanup callback failed: $e');
      }
    }
    _cleanupCallbacks.clear();
  }

  /// Registers a callback to invoke automatically when leaving the web page.
  ///
  /// Returns a token that can be passed to [unregister].
  Object register(VoidCallback callback) {
    var key = Object();
    _cleanupCallbacks[key] = callback;
    return key;
  }

  /// Unregisters an exit callback.
  ///
  /// [token] must be the result of a prior call to [register].
  ///
  /// Returns the unregistered callback.  Returns `null` if [token] was not
  /// valid.
  VoidCallback? unregister(Object token) => _cleanupCallbacks.remove(token);

  /// Registers automatic cancellation of a [StreamSubscription].
  Object addSubscription(StreamSubscription<Object?> subscription) =>
      register(subscription.cancel);
}

/// Singleton instance for [ExitHandler].
final ExitHandler exitHandler = ExitHandler._();
