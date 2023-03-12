/// Utilities to make debugging easier.
library;

import 'dart:async';
import 'package:stack_trace/stack_trace.dart' as stacktrace;

/// Returns the path to the caller's `.dart` file.
///
/// If [packageRelative] is true, returns a path relative to the package root.
///
/// If [packageRelative] is false, returns an absolute path.
///
/// This does not work for Dart for the Web.
///
/// Note that [Platform.script] does not work for `import`ed files and
/// consequently does not work with the Dart test runner.
///
/// [Platform.script]: https://api.dart.dev/stable/dart-io/Platform/script.html
String currentDartFilePath({bool packageRelative = false}) {
  var caller = stacktrace.Frame.caller(1);
  return packageRelative ? caller.library : caller.uri.toFilePath();
}

/// Provides a [staticType] getter on all non-`dynamic` objects.
extension StaticTypeExtension<T> on T {
  /// Returns the static type of this object.
  ///
  /// This can be used to report the static type of an object (which might not
  /// always be obvious due to inference or when dealing with generics), which
  /// might be different from [Object.runtimeType].
  Type get staticType => T;
}

/// Returns true if `assert` is enabled.
bool get assertsEnabled {
  var result = false;
  assert(
    () {
      result = true;
      return true;
    }(),
  );
  return result;
}

/// Times the specified synchronous operation.
Duration timeOperation(void Function() operation) {
  var stopwatch = Stopwatch()..start();
  operation();
  return stopwatch.elapsed;
}

/// Times the specified asynchronous operation.
Future<Duration> timeAsyncOperation(Future<void> Function() operation) async {
  var stopwatch = Stopwatch()..start();
  await operation();
  return stopwatch.elapsed;
}
