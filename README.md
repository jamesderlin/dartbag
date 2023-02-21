# dartbag

A grab-bag of miscellaneous, lightweight utility code for Dart.  Functionality
includes (but is not limited to):

## [byte_data]

* `List<int>.asUint8List` converts a `List<int>` to a `Uint8List` without
  copying, if possible.

## [collection]

* `flattenDeep` recursively flattens nested `Iterable`s into a single
  `Iterable` sequence.

* `List.reverse` reverses a `List` in place.

* `List.rotateLeft` rotates a `List` in place.

* `List.sortWithKey` sorts a `List` by computing and caching sort keys, which
  can be significantly faster if comparisons are expensive.

* `List.sortWithAsyncKey` is a version of `sortWithKey` that allows the sort
  key to be computed asynchronously.

* `LinkedHashMap.sort`.

* `mergeMaps`s combines an `Iterable` of `Map`s into a single `Map`.

## [comparable]

* `clamp` clamps a `Comparable` object to be within a specified range.

* `compareIterables` compares two `Iterable`s in a manner similar to string
  comparison.

* `ComparableWrapper` wraps a value in a `Comparable` interface with a
  specified comparison function.

## [debug]

* `assertsEnabled` returns whether `assert` is enabled.

* `currentDartPackagePath` returns the path to the current Dart library for
  Dart VM builds.

* `staticType` returns the static type of an object.

## [matcher]

* `toStringMatches` verifies that a tested value has a matching type and string
  representation.

## [math]

* `lcm` computes the least-common-multiple of two integers.

* `int.floorToMultipleOf`, `int.ceilToMultipleOf`, and `int.roundToMultipleOf`
  provide different ways of rounding a non-negative integer to the nearest
  multiple of another.

* `Rectangle.center` returns the center of a `Rectangle`.

## [misc]

* `chainIf` allows conditional method chaining based on a condition.

* `tryAs` casts an object and returns `null` on failure instead of throwing a
  `TypeError`.

* `OutputParameter` allows specifying output parameters from functions as a
  crude mechanism to return multiple values.

* `int.padLeft` converts an `int` to a `String`, left-padded with zeroes to
  have a minimum number of digits.

* `Uri.updateQueryParameters` adds or replaces query parameters in a `Uri`.

* `bool.implies` returns whether one `bool` logically implies another.

* `Future.cast` casts a `Future<T>` to a `Future<R>`.

* `PollableFuture` is an implementation of `Future` that allows synchronously
  retrieving the value if it has already been completed.

* `hoursOnly`, `minutesOnly`, `secondsOnly`, `millisecondsOnly`, and
  `microsecondsOnly` retrieve specific components of a `Duration`.

## [parse]

* `tryParseBool` parses a `bool` from a `String?`.

* `tryParseInt` and `tryParseDouble` are wrappers around `int.tryParse` and
  `double.tryParse` that accept `null` arguments.

* `List<Enum>.tryParse` parses an `Enum` value from a `String?`.

* `tryParseDuration` parses a `Duration` from a `String?`.

## [random]

* `randMaxInt` portably returns the maximum value allowed by `Random.nextInt`.

* `Random.nextIntFrom` returns a random integer in a specified range.

* `lazyShuffler` shuffles a `List` lazily.

* `RepeatableRandom` wraps an existing pseudo-random number generator to allow
  a random sequence to be easily restarted and to allow the seed to be
  retrieved.

## [readable_numbers]

* `readableDuration` returns a `Duration` as a human-readable string.

* `readableNumber` returns a number as a human-readable string with SI prefixes
  and units.

## [timer]

* `ExpiringPeriodicTimer` is a periodic `Timer` that automatically stops after a
  time limit.

## [tty]

* `getTerminalSize` attempts to get the number of columns and lines of a
  terminal.

* `wordWrap` wraps a string to a maximum line length.

* `ArgResults.parseOptionValue` reduces some boilerplate when parsing option
  values from [`package:args`].
  
[byte_data]: https://pub.dev/documentation/dartbag/latest/byte_data/byte_data-library.html
[collection]: https://pub.dev/documentation/dartbag/latest/collection/collection-library.html
[comparable]: https://pub.dev/documentation/dartbag/latest/comparable/comparable-library.html
[debug]: https://pub.dev/documentation/dartbag/latest/debug/debug-library.html
[matcher]: https://pub.dev/documentation/dartbag/latest/matcher/matcher-library.html
[math]: https://pub.dev/documentation/dartbag/latest/math/math-library.html
[misc]: https://pub.dev/documentation/dartbag/latest/misc/misc-library.html
[`package:args`]: https://pub.dev/packages/args
[parse]: https://pub.dev/documentation/dartbag/latest/parse/parse-library.html
[random]: https://pub.dev/documentation/dartbag/latest/random/random-library.html
[readable_numbers]: https://pub.dev/documentation/dartbag/latest/readable_numbers/readable_numbers-library.html
[timer]: https://pub.dev/documentation/dartbag/latest/timer/timer-library.html
[tty]: https://pub.dev/documentation/dartbag/latest/tty/tty-library.html
