## 0.9.0

* Enabled lints introduced by Dart 3.4.0.

* Replaced the `identityType<T>()` function with an `IdentityType<T>`
  `typedef`.

## 0.8.4

* Added an `Iterable.startsWith` extension method.

## 0.8.3+1

* Minor correction to the `README.md` file.

## 0.8.3

* Added a `String.substringLoose` extension method.
* Fixed `readableNumber` to accept numbers smaller than 10^-24.
* Internal changes to make better use of Dart 3 patterns.

## 0.8.2

* Added a `Map<K, Future<V>>.wait` extension property.

## 0.8.1

* Reimplemented `toStringMatches`.  The new implementation is much simpler,
  although failure messages will be different.

* Added `String.escape` and `Runes.escape` extension methods.

## 0.8.0

* Updated for Dart 3:
  * Require Dart 3.0.0.
  * Enabled new lints.
  * Removed deprecated lints.
  * `getTerminalSize` now returns a `({int width, int height})` record instead
    of using `OutputParameter`s.

## 0.7.1

* Added `identityType<T>` and `isNullable<T>` functions.
* Added a `String.lazySplit` and `String.partialSplit` extension methods.

## 0.7.0+1

* Corrected some documentation.
* Improved test coverage.

## 0.7.0

This version includes multiple breaking changes.

* Moved `flattenDeep` into `collection.dart`.
* Moved `compareIterators` and `ComparableWrapper` to a new `comparable`
  library.
* Added a `Comparable.clamp` extension method.
* Renamed the `int.padDigits` extension method to `int.padLeft` for clarity.
* Split the `IntUtils` extension into separate `IntUtils` and
  `PadLeftExtension`extensions.
* Moved the `int.roundToMultipleOf` `Rectangle.center` extension methods to a
  new `math` library.
* Added `int.floorToMultipleOf` and `int.ceilToMultipleOf` extension methods.
* Added an `lcm` function.
* Replaced `currentDartPackagePath` with a `currentDartFilePath` function.
  The package-relative path can be obtained by calling it with
  `packageRelative: true`.
* Added `DateTime.toStringWithOffset` and `DateTime.toIso8601StringWithOffset`
  extension methods.

## 0.6.2

* Added a freestanding `tryAs` function, which works better for `dynamic`
  types.

## 0.6.1+2

* Corrected broken references in the documentation.

## 0.6.1

* Added a `ComparableWrapper` class.
* Added a `PollableFuture` class.

## 0.6.0

* Added `hoursOnly`, `minutesOnly`, `secondsOnly`, `millisecondsOnly`, and
  `microsecondsOnly` extension getters to `Duration`.
* Added a `tryParseDuration` function.
* Added a `mergeMaps` function.
* Require Dart 2.19.0 and enable new lints.
* Disable the `one_member_abstracts` lint.

## 0.5.0

* Renamed the `iterables` library to `collection`.
* Added a `compareIterables` function.
* Added a `LinkedHashMap.sort` extension method.
* Added an `isSubtype<T1, T2>` generic function.
* Adjusted some timing-based tests to be less flaky by instead checking if they
  pass most of the time.
* Require Dart 2.18.0.

## 0.4.1

* Added a `Future.cast` extension method.
* Added a `List.sortWithAsyncKey` extension method as an asynchronous version of
 `List.sortWithKey`.

## 0.4.0

* Removed `RestartableTimer`. `package:async` already provides such a class.
* Added a `timeAsyncOperation` function as an asynchronous version of
  `timeOperation`.
* Added a `parseOptionValue` extension method on `package:args`'s `ArgResults`.
* Added a `matcher` library with a `toStringMatches` function.

## 0.3.0

* Added a `List.rotateLeft` extension method.
* Allow the `analysis_options.yaml` file to be consumed by other packages.
* Moved `timeOperation` from `misc.dart` to `debug.dart`.
* Fixed `int.padLeft` to work with negative integers.
* Modified `RepeatableRandom` to allow callers to specify the underlying
  pseudo-random-number generator.
* Updated the `README.md` file.

## 0.2.0

* Initial published version.
