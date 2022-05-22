import 'package:stack_trace/stack_trace.dart' as stacktrace;

/// Returns the path to the current Dart library, relative to the package root.
///
/// This doesn't work for Dart for the Web.
String currentDartPackagePath() => stacktrace.Frame.caller(1).library;

// ignore: public_member_api_docs
extension StaticTypeExtension<T> on T {
  /// Returns the static type of this object.
  Type get staticType => T;
}

/// Returns true if [assert] is enabled.
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
