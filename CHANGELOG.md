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
