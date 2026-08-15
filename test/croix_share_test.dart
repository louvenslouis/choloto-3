import 'dart:typed_data';

import 'package:choloto/croix/croix_share.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_codec;

void main() {
  test('converts the captured PNG visual to a JPEG image', () {
    final source = image_codec.Image(width: 4, height: 4);
    final pngBytes = Uint8List.fromList(image_codec.encodePng(source));

    final jpegBytes = pngToJpeg(pngBytes);
    final decodedJpeg = image_codec.decodeJpg(jpegBytes);

    expect(jpegBytes.take(2), orderedEquals([0xFF, 0xD8]));
    expect(decodedJpeg, isNotNull);
    expect(decodedJpeg!.width, 4);
    expect(decodedJpeg.height, 4);
  });

  test('rejects invalid captured image bytes', () {
    expect(
      () => pngToJpeg(Uint8List.fromList([0x00, 0x01, 0x02])),
      throwsFormatException,
    );
  });

  test('downloads the JPEG when web file sharing is unavailable', () async {
    var downloaded = false;

    final delivery = await deliverCroixJpeg(
      share: () => Future<void>.error(StateError('canShare is false')),
      download: () => downloaded = true,
      isWeb: true,
    );

    expect(delivery, CroixShareDelivery.downloaded);
    expect(downloaded, isTrue);
  });

  test('does not hide native sharing failures', () async {
    var downloaded = false;

    await expectLater(
      deliverCroixJpeg(
        share: () => Future<void>.error(StateError('native share failed')),
        download: () => downloaded = true,
        isWeb: false,
      ),
      throwsStateError,
    );
    expect(downloaded, isFalse);
  });
}
