/// Utilities for operating on byte data.
library;

import 'dart:typed_data';

import 'misc.dart';

export 'src/mem_equals32.dart' if (dart.library.io) 'src/mem_equals64.dart';

/// Provides extension methods for operating on lists of bytes.
extension BytesExtension on List<int> {
  /// Converts a `List<int>` to a [Uint8List].
  ///
  /// Attempts to cast to a [Uint8List] first to avoid creating an unnecessary
  /// copy.
  Uint8List asUint8List() => tryAs<Uint8List>() ?? Uint8List.fromList(this);

  /// Returns a [List] of the hexadecimal strings of each element.
  ///
  /// Each hexadecimal string will be converted to uppercase and will be
  /// optionally prefixed with [prefix].
  List<String> toHex({String prefix = '0x'}) => [
        for (var byte in this) '$prefix${byte.toRadixString(16).toUpperCase()}',
      ];
}
