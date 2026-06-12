import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Compresses [bytes] to JPEG.
/// - Resizes so the longest edge is at most [maxDimension] pixels.
/// - Encodes at [quality] (1–100, lower = smaller file).
/// Returns original bytes unchanged if decoding fails.
Future<Uint8List> compressImageBytes(
  Uint8List bytes, {
  int maxDimension = 1024,
  int quality = 78,
}) async {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  img.Image resized = decoded;
  final w = decoded.width;
  final h = decoded.height;

  if (w > maxDimension || h > maxDimension) {
    if (w >= h) {
      resized = img.copyResize(decoded, width: maxDimension);
    } else {
      resized = img.copyResize(decoded, height: maxDimension);
    }
  }

  return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
}
