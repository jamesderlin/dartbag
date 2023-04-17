/// Miscellaneous utilities.
library;

import 'dart:async';

import 'misc.dart' as misc;

/// Provides a [tryAs] extension method on all objects.
extension TryAsExtension on Object? {
  /// An extension version of [misc.tryAs].
  ///
  /// Note that extension methods cannot work on `dynamic` types, so the
  /// freestanding [misc.tryAs] function should be preferred for those cases.
  T? tryAs<T>() => misc.tryAs<T>(this);
}

/// Attempts to cast [object] to `T`, returning `null` on failure.
///
/// This is a workaround until `as?` is implemented:
/// <https://github.com/dart-lang/language/issues/399>
T? tryAs<T>(dynamic object) => (object is T) ? object : null;

/// Provides a [chainIf] extension method on all objects.
extension ChainIf<T> on T {
  /// Allows conditional method chaining based on a condition.
  ///
  /// Returns this object if [shouldChain] is true, `null` otherwise.
  ///
  /// This is intended to be used with the conditional-member-access operator
  /// (`?.`).
  ///
  /// Example:
  /// ```dart
  /// var items = Set<int>.of([1, 2, 3]..chainIf(shouldShuffle)?.shuffle());
  /// ```
  // ignore: avoid_positional_boolean_parameters, https://github.com/dart-lang/linter/issues/1638
  T? chainIf(bool shouldChain) => shouldChain ? this : null;
}

/// Returns `true` if `Subtype` is a subtype of `Supertype`.
///
/// Note that `Subtype` and `Supertype` must be known statically (that is, at
/// compilation-time)
///
// See <https://github.com/dart-lang/language/issues/1312#issuecomment-727284104>
bool isSubtype<Subtype, Supertype>() => <Subtype>[] is List<Supertype>;

/// Identity function for a [Type].
///
/// This can be used in situations where a type literal is syntactically
/// invalid.
///
/// Example:
/// ```dart
/// x.runtimeType == int?; // Compile-time error due to invalid syntax.
/// x.runtimeType == identityType<int?>();
/// ```
Type identityType<T>() => T;

/// Returns `true` if `T` is a nullable type.
///
// See <https://stackoverflow.com/a/66249380/>.
bool isNullable<T>() => null is T;

/// A basic wrapper around another type.
class Boxed<T> {
  /// The wrapped value.
  T value;

  // ignore: public_member_api_docs
  Boxed(this.value);
}

/// An output parameter.
///
/// Example:
/// ```dart
/// void divmod(
///   int dividend,
///   int divisor, {
///   required OutputParameter<int> quotient,
///   required OutputParameter<int> remainder,
/// }) {
///   assert(divisor != 0);
///   quotient.value = dividend ~/ divisor;
///   remainder.value = dividend.remainder(divisor);
/// }
///
/// void main() {
///   var quotient = OutputParameter<int>(0);
///   var remainder = OutputParameter<int>(0);
///   divmod(13, 5, quotient: quotient, remainder: remainder);
///   print('13 / 5 = ${quotient.value}R${remainder.value}');
/// }
/// ```
typedef OutputParameter<T> = Boxed<T>;

/// Provides a [padLeft] extension method on [int].
extension PadLeftExtension on int {
  /// Returns a string representation of this [int], left-padded with zeroes if
  /// necessary to have the specified minimum number of characters.
  ///
  /// If this [int] is negative, the negative sign is included in the number of
  /// characters.
  ///
  /// Examples:
  /// ```dart
  /// 7.padLeft(3);    // '007'
  /// (-7).padLeft(3); // '-07'
  /// 1234.padLeft(3); // '1234'
  /// ```
  String padLeft(int minimumWidth) {
    if (this < 0) {
      var padded = (-this).padLeft(minimumWidth - 1);
      return '-$padded';
    }
    return toString().padLeft(minimumWidth, '0');
  }
}

/// Provides a [partialSplit] extension method on [String].
extension PartialSplit on String {
  /// A version of [String.split] that limits splitting to return a [List] of
  /// at most [count] items.
  ///
  /// [count] must be non-negative.  If [count] is 0, returns an empty
  /// [List].
  ///
  /// If splitting this [String] would result in more than [count] items, the
  /// final element will contain the unsplit remainder of this [String].
  ///
  /// If splitting this [String] would result in fewer than [count] items,
  /// returns a [List] with only the split substrings.
  ///
  // Based on <https://stackoverflow.com/a/76039017/>.
  List<String> partialSplit(Pattern pattern, int count) {
    assert(count >= 0);

    var result = <String>[];

    if (count == 0) {
      return result;
    }

    var offset = 0;
    var matches = pattern.allMatches(this);
    for (var match in matches) {
      if (result.length + 1 == count) {
        break;
      }

      if (match.end - match.start == 0 && match.start == offset) {
        continue;
      }

      result.add(substring(offset, match.start));
      offset = match.end;
    }
    result.add(substring(offset));

    return result;
  }
}

/// Miscellaneous utility methods for [Uri].
extension UriUtils on Uri {
  /// Adds or replaces query parameters.
  ///
  /// The values in the [queryParameters] [Map] must be [String]s or
  /// [Iterable<String>]s.  See [Uri.new] for details.
  Uri updateQueryParameters(Map<String, dynamic> queryParameters) {
    return replace(
      queryParameters: {
        ...this.queryParameters,
        ...queryParameters,
      },
    );
  }
}

/// Provides an [implies] extension method on [bool].
extension ImpliesExtension on bool {
  /// Returns whether this [bool] [logically implies][1] [consequence].
  ///
  /// Given two boolean expressions *p* and *q*, the results of "*p* implies
  /// *q*" (denoted as *p &rarr; q*) are shown by the following truth table:
  ///
  /// |  p  |  q  | p &rarr; q |
  /// |:---:|:---:|:----------:|
  /// |  T  |  T  | T          |
  /// |  T  |  F  | F          |
  /// |  F  |  T  | T          |
  /// |  F  |  F  | F          |
  ///
  /// <style>table, th, td { border: 1px solid; border-collapse: collapse; padding: 1ex; }</style>
  ///
  /// [1]: https://simple.wikipedia.org/wiki/Implication_(logic)
  // ignore: avoid_positional_boolean_parameters, https://github.com/dart-lang/linter/issues/1638
  bool implies(bool consequence) => !this || consequence;
}

/// Provides a [cast] extension method on [Future].
extension FutureCast<T> on Future<T> {
  /// Casts a `Future<T>` to a `Future<R>`.
  ///
  // Motivated by: <https://stackoverflow.com/q/72576065/>
  Future<R> cast<R>() async => (await this) as R;
}

/// An implementation of [Future] that allows synchronously retrieving the
/// value if it has already been completed.
///
/// A [PollableFuture] wraps an existing [Future].  Unless the [PollableFuture]
/// is initialized with a non-[Future] value, it cannot be  marked as completed
/// until execution returns to the event loop after the underlying [Future]
/// has completed.  Consequently, a [PollableFuture] cannot be used to
/// implement a spinlock that synchronously blocks while waiting for a [Future]
/// to complete.
///
// Motivated by <https://www.reddit.com/r/dartlang/comments/112kaap/futuret_and_getting_value_synchronously/>.
class PollableFuture<T> implements Future<T> {
  FutureOr<T> _futureOrValue;

  /// Constructor.
  ///
  /// If [futureOrValue] is not a [Future], then the [PollableFuture] will be
  /// constructed in the completed state with that value.
  ///
  /// If [futureOrValue] is a [Future], regardless of whether that [Future] is
  /// already completed or not, then the [PollableFuture] will mark itself
  /// completed only after that [Future] executes its [Future.then] callbacks.
  ///
  /// Alternatively use the [PollableFutureExtension.toPollable] extension
  /// method on an existing [Future].
  PollableFuture(FutureOr<T> futureOrValue) : _futureOrValue = futureOrValue {
    final futureOrValue = _futureOrValue;
    if (futureOrValue is Future<T>) {
      unawaited(
        futureOrValue.then((value) {
          _futureOrValue = value;
        }),
      );
    }
  }

  /// Returns `true` if the [PollableFuture] has completed, `false` otherwise.
  bool get isCompleted => _futureOrValue is T;

  /// Returns the completed value.
  ///
  /// Throws a [StateError] if the [PollableFuture] has not yet completed.
  /// Callers should check [isCompleted] first.
  T get value {
    final futureOrValue = _futureOrValue;
    if (futureOrValue is T) {
      return futureOrValue;
    }
    throw StateError('Future not yet completed');
  }

  /// Unconditionally returns [_futureOrValue] as a [Future], creating a new,
  /// already-completed [Future] if necessary.
  Future<T> get _asFuture {
    final futureOrValue = _futureOrValue;
    return futureOrValue is Future<T>
        ? futureOrValue
        : Future.value(futureOrValue);
  }

  @override
  Stream<T> asStream() => _asFuture.asStream();

  @override
  Future<T> catchError(Function onError, {bool Function(Object)? test}) =>
      _asFuture.catchError(onError, test: test);

  @override
  Future<R> then<R>(FutureOr<R> Function(T) onValue, {Function? onError}) =>
      _asFuture.then(onValue, onError: onError);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      _asFuture.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _asFuture.whenComplete(action);
}

/// Provides a [toPollable] extension method on [Future].
extension PollableFutureExtension<T> on Future<T> {
  /// Wraps this [Future] with a [PollableFuture].
  PollableFuture<T> toPollable() => PollableFuture<T>(this);
}

/// Provides miscellaneous extension methods on [Duration].
extension DurationUtils on Duration {
  /// Returns the hours component of the [Duration].
  ///
  /// Example:
  /// ```dart
  /// Duration(days: 1, hours: 2).hoursOnly; // 2
  /// ```
  int get hoursOnly => inHours.remainder(24);

  /// Returns the minutes component of the [Duration].
  ///
  /// Example:
  /// ```dart
  /// Duration(hours: 2, minutes: 3).minutesOnly; // 3
  /// ```
  int get minutesOnly => inMinutes.remainder(60);

  /// Returns the seconds component of the [Duration].
  ///
  /// Example:
  /// ```dart
  /// Duration(minutes: 3, seconds: 4).secondsOnly; // 4
  /// ```
  int get secondsOnly => inSeconds.remainder(60);

  /// Returns the milliseconds component of the [Duration].
  ///
  /// Example:
  /// ```dart
  /// Duration(seconds: 4, milliseconds: 5).millisecondsOnly; // 5
  /// ```
  int get millisecondsOnly => inMilliseconds.remainder(1000);

  /// Returns the microseconds component of the [Duration].
  ///
  /// The returned number of microseconds does not include any milliseconds.
  ///
  /// Example:
  /// ```dart
  /// Duration(milliseconds: 5, microseconds: 6).microsecondsOnly; // 6
  /// ```
  int get microsecondsOnly => inMicroseconds.remainder(1000);
}

/// TODO: Document
extension DateTimeStringWithOffset on DateTime {
  /// Internal helper function to append a timezone offset to the specified
  /// date-time string.
  String _appendOffset(String baseString) {
    var prefix = '+';
    var offset = timeZoneOffset;
    if (timeZoneOffset.isNegative) {
      prefix = '-';
      offset = -timeZoneOffset;
    }

    // Strip off the trailing 'Z' for UTC [DateTime]s.
    if (isUtc) {
      assert(baseString.endsWith('Z'));
      baseString = baseString.substring(0, baseString.length - 1);
    }

    var offsetHours = offset.inHours.padLeft(2);
    var offsetMinutes = offset.minutesOnly.padLeft(2);
    return '$baseString$prefix$offsetHours:$offsetMinutes';
  }

  /// A version of [DateTime.toString] that includes the timezone offset.
  String toStringWithOffset() => _appendOffset(toString());

  /// A version of [DateTime.toIso8601String] that includes the timezone
  /// offset.
  String toIso8601StringWithOffset() => _appendOffset(toIso8601String());
}
