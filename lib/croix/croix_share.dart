import 'dart:typed_data';

import 'package:image/image.dart' as image_codec;

enum CroixShareDelivery { shared, downloaded }

Uint8List pngToJpeg(Uint8List pngBytes, {int quality = 95}) {
  image_codec.Image? decodedImage;
  try {
    decodedImage = image_codec.decodeImage(pngBytes);
  } catch (_) {
    throw const FormatException('Unable to decode the cross image.');
  }
  if (decodedImage == null) {
    throw const FormatException('Unable to decode the cross image.');
  }

  return Uint8List.fromList(
    image_codec.encodeJpg(decodedImage, quality: quality),
  );
}

Future<CroixShareDelivery> deliverCroixJpeg({
  required Future<void> Function() share,
  required void Function() download,
  required bool isWeb,
}) async {
  try {
    await share();
    return CroixShareDelivery.shared;
  } catch (_) {
    if (!isWeb) {
      rethrow;
    }

    download();
    return CroixShareDelivery.downloaded;
  }
}
