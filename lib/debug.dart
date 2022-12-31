/// Utilities to make debugging easier.
library;

import 'dart:async';
import 'package:stack_trace/stack_trace.dart' as stacktrace;

/// Returns the path to the current Dart library, relative to the package root.
///
/// This does not work for Dart for the Web.
String currentDartPackagePath() => stacktrace.Frame.caller(1).library;

/// Provides a [staticType] getter as an extension on [Duration].
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
