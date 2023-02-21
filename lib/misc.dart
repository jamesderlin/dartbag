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
  /// Returns `this` if [shouldChain] is true, `null` otherwise.
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
//
// See <https://github.com/dart-lang/language/issues/1312#issuecomment-727284104>
bool isSubtype<Subtype, Supertype>() => <Subtype>[] is List<Supertype>;

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
  String padLeft(int minimumWidth) {
    if (this < 0) {
      var padded = (-this).padLeft(minimumWidth - 1);
      return '-$padded';
    }
    return toString().padLeft(minimumWidth, '0');
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
  /// *q*"" (denoted as *p &rarr; q*) are shown by the following truth table:
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
  //
  // Motivated by: <https://stackoverflow.com/q/72576065/>
  Future<R> cast<R>() async {
    var result = await this;
    return result as R;
  }
}

/// An implementation of [Future] that allows synchronously retrieving the
/// value if it has already been completed.
//
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
  /// print(Duration(days: 1, hours: 2).hoursOnly); // 2
  /// ```
  int get hoursOnly => inHours.remainder(24);

  /// Returns the minutes component of the [Duration].
  ///
  /// Example:
  /// ```dart
  /// print(Duration(hours: 2, minutes: 3).minutesOnly); // 3
  /// ```
  int get minutesOnly => inMinutes.remainder(60);

  /// Returns the seconds component of the [Duration].
  ///
  /// Example:
  /// ```dart
  /// print(Duration(minutes: 3, seconds: 4).secondsOnly); // 4
  /// ```
  int get secondsOnly => inSeconds.remainder(60);

  /// Returns the milliseconds component of the [Duration].
  ///
  /// Example:
  /// ```dart
  /// print(Duration(seconds: 4, milliseconds: 5).millisecondsOnly); // 5
  /// ```
  int get millisecondsOnly => inMilliseconds.remainder(1000);

  /// Returns the microseconds component of the [Duration].
  ///
  /// The returned number of microseconds does not include any milliseconds.
  ///
  /// Example:
  /// ```dart
  /// print(Duration(milliseconds: 5, microseconds: 6).microsecondsOnly); // 6
  /// ```
  int get microsecondsOnly => inMicroseconds.remainder(1000);
}
