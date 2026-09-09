import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'payment_request.dart';

/// Uses the same picker, limits and privacy-preserving conversion for payment
/// proofs and other private image attachments.
Future<Uint8List?> pickPreparedPrivateImage({
  Future<Uint8List?> Function()? pickImage,
}) async {
  Uint8List? bytes;
  if (pickImage != null) {
    bytes = await pickImage();
  } else {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
      withData: false,
      withReadStream: true,
    );
    if (result == null) return null;
    if (result.files.single.size > 12 * 1024 * 1024) {
      throw const FormatException('size');
    }
    final stream = result.files.single.readStream;
    if (stream == null) throw const FormatException('image');
    final buffer = BytesBuilder(copy: false);
    await for (final chunk in stream) {
      if (buffer.length + chunk.length > 12 * 1024 * 1024) {
        throw const FormatException('size');
      }
      buffer.add(chunk);
    }
    bytes = buffer.takeBytes();
  }
  if (bytes == null) return null;
  return compute(preparePaymentProof, bytes);
}

/// Decode only still JPEG/PNG images. Re-encoding strips private EXIF metadata.
/// Header limits avoid allocating unbounded bitmaps for a small compressed file.
Uint8List preparePaymentProof(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > 12 * 1024 * 1024) {
    throw const FormatException('image-size');
  }
  final img.Decoder decoder;
  if (bytes.length > 3 &&
      bytes[0] == 255 &&
      bytes[1] == 216 &&
      bytes[2] == 255) {
    decoder = img.JpegDecoder();
  } else if (bytes.length > 8 &&
      bytes[0] == 137 &&
      bytes[1] == 80 &&
      bytes[2] == 78 &&
      bytes[3] == 71) {
    decoder = img.PngDecoder();
  } else {
    throw const FormatException('image-format');
  }
  final info = decoder.startDecode(bytes);
  if (info == null ||
      info.width <= 0 ||
      info.height <= 0 ||
      info.width * info.height > 24000000 ||
      info.numFrames != 1) {
    throw const FormatException('image-dimensions');
  }
  final decoded = decoder.decodeFrame(0);
  if (decoded == null) throw const FormatException('image-format');
  var picture = img.bakeOrientation(decoded);
  if (picture.width > 1600 || picture.height > 1600) {
    picture = img.copyResize(picture,
        width: picture.width >= picture.height ? 1600 : null,
        height: picture.height > picture.width ? 1600 : null);
  }
  // Copy pixels into a fresh image to drop EXIF/GPS and embedded thumbnails.
  picture = img.Image.fromBytes(
      width: picture.width,
      height: picture.height,
      bytes: picture.getBytes(order: img.ChannelOrder.rgb).buffer,
      numChannels: 3);
  for (final quality in [88, 78, 65, 50]) {
    final encoded = img.encodeJpg(picture, quality: quality);
    if (encoded.length <= maxProofBytes) return encoded;
  }
  throw const FormatException('image-size');
}
