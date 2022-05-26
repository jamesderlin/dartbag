## 0.4.0

* Removed `RestartableTimer`. `package:async` already provides such a class.
* Added a `timeAsyncOperation` function as an asynchronous version of
  `timeOperation`.

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
