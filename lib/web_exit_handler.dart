import 'dart:async';
import 'dart:html' as html;

class _ExitHandler {
  final _cleanupCallbacks = <void Function()>[];

  _ExitHandler() {
    addSubscription(html.window.onUnload.listen(_onUnload));
  }

  void _onUnload(html.Event _) {
    // print('_ExitHandler: Firing onUnload callbacks');
    for (var callback in _cleanupCallbacks.reversed) {
      try {
        callback();
      } catch (e) {
        print('_ExitHandler: Cleanup callback failed: $e');
      }
    }
    _cleanupCallbacks.clear();
  }

  // TODO: Make it possible to unregister?
  void register(void Function() callback) => _cleanupCallbacks.add(callback);

  void addSubscription(StreamSubscription<Object?> subscription) =>
      register(subscription.cancel);
}

final _ExitHandler exitHandler = _ExitHandler();
