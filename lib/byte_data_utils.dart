import 'dart:typed_data';

import 'dart_utils.dart';

// ignore: public_member_api_docs
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

/// Compares two [Uint8List]s by comparing 8 bytes at a time.
///
/// This should be faster than a naive, byte-by-byte comparison.
// See <https://stackoverflow.com/questions/70749634/>.
bool memEquals(Uint8List bytes1, Uint8List bytes2) {
  if (identical(bytes1, bytes2)) {
    return true;
  }

  if (bytes1.lengthInBytes != bytes2.lengthInBytes) {
    return false;
  }

  // Treat the original byte lists as lists of 8-byte words.
  var numWords = bytes1.lengthInBytes ~/ 8;
  var words1 = bytes1.buffer.asUint64List(0, numWords);
  var words2 = bytes2.buffer.asUint64List(0, numWords);

  for (var i = 0; i < words1.length; i += 1) {
    if (words1[i] != words2[i]) {
      return false;
    }
  }

  // Compare any remaining bytes.
  for (var i = words1.lengthInBytes; i < bytes1.lengthInBytes; i += 1) {
    if (bytes1[i] != bytes2[i]) {
      return false;
    }
  }

  return true;
}
