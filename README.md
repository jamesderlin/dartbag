# dartbag

A grab-bag of miscellaneous, lightweight utility code for Dart.  Functionality
includes (but is not limited to):

## [byte_data]

* `List<int>.asUint8List` converts a `List<int>` to a `Uint8List` without
  copying, if possible.

## [collection]

* `List.reverse` reverses a `List` in place.

* `List.rotateLeft` rotates a `List` in place.

* `List.sortWithKey` sorts a `List` by computing and caching sort keys, which
  can be significantly faster if comparisons are expensive.

* `List.sortWithAsyncKey`, a version of `sortWithKey` that allows the sort key
  to be computed asynchronously.

* `compareIterables` compares two `Iterable`s in a manner similar to string
  comparison.

* `LinkedHashMap.sort`.

## [debug]

* `assertsEnabled` returns whether `assert` is enabled.

* `currentDartPackagePath` returns the path to the current Dart library for
  Dart VM builds.

* `staticType` returns the static type of an object.

## [matcher]

* `toStringMatches` verifies that a tested value has a matching type and string
  representation.

## [misc]

* `chainIf` allows conditional method chaining based on a condition.

* `tryAs` casts an object and returns `null` on failure instead of throwing a
  `TypeError`.

* `OutputParameter` allows specifying output parameters from functions as a
  crude mechanism to return multiple values.

* `int.padDigits` converts an `int` to a `String`, left-padded with zeroes to
  have a minimum number of digits.

* `int.multipleOf` rounds a non-negative integer to the nearest multiple of
  another number.

* `Uri.updateQueryParameters` adds or replaces query parameters in a `Uri`.

* `Rectangle.center` returns the center of a `Rectangle`.

* `bool.implies` returns whether one `bool` logically implies another.

* `Future.cast` casts a `Future<T>` to a `Future<R>`.

* `hoursOnly`, `minutesOnly`, `secondsOnly`, `millisecondsOnly`, and
  `microsecondsOnly` retrieve specific components of a `Duration`.

## [parse]

* `tryParseBool` parses a `bool` from a `String?`.

* `tryParseInt` and `tryParseDouble` are wrappers around `int.tryParse` and
  `double.tryParse` that accept `null` arguments.

* `List<Enum>.tryParse` parses an `Enum` value from a `String?`.

## [random]

* `randMaxInt` returns the maximum value allowed by `Random.nextInt` portably.

* `Random.nextIntFrom` returns a random integer in a specified range.

* `lazyShuffler` shuffles a `List` lazily.

* `RepeatableRandom` wraps an existing pseudo-random number generator and allows
  a random sequence to be easily restarted and that allows the seed to be
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
[debug]: https://pub.dev/documentation/dartbag/latest/debug/debug-library.html
[matcher]: https://pub.dev/documentation/dartbag/latest/matcher/matcher-library.html
[misc]: https://pub.dev/documentation/dartbag/latest/misc/misc-library.html
[`package:args`]: https://pub.dev/packages/args
[parse]: https://pub.dev/documentation/dartbag/latest/parse/parse-library.html
[random]: https://pub.dev/documentation/dartbag/latest/random/random-library.html
[readable_numbers]: https://pub.dev/documentation/dartbag/latest/readable_numbers/readable_numbers-library.html
[timer]: https://pub.dev/documentation/dartbag/latest/timer/timer-library.html
[tty]: https://pub.dev/documentation/dartbag/latest/tty/tty-library.html
