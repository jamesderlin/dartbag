import 'dart:typed_data';

/// Compares two [Uint8List]s by comparing multiple bytes at a time.
///
/// This should be faster than a naive, byte-by-byte comparison.
///
/// For builds using the Dart VM, compares 8 bytes at a time.  When compiled to
/// JavaScript, compares 4 bytes at a time.
// See <https://stackoverflow.com/questions/70749634/>.
bool memEquals(Uint8List bytes1, Uint8List bytes2) {
  if (identical(bytes1, bytes2)) {
    return true;
  }

  if (bytes1.lengthInBytes != bytes2.lengthInBytes) {
    return false;
  }

  // Treat the original byte lists as lists of 4-byte words.
  var numWords = bytes1.lengthInBytes ~/ 4;
  var words1 = bytes1.buffer.asUint32List(0, numWords);
  var words2 = bytes2.buffer.asUint32List(0, numWords);

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
