import 'dart:typed_data';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';

Future<bool> deliverPreparedCroixJpeg(
  Uint8List jpegBytes, {
  required String fileName,
  required String subject,
  Rect? sharePositionOrigin,
  bool Function()? isCurrent,
}) async {
  if (isCurrent?.call() == false) return false;
  await Share.shareXFiles(
    [
      XFile.fromData(
        jpegBytes,
        mimeType: 'image/jpeg',
      ),
    ],
    subject: subject,
    fileNameOverrides: [fileName],
    sharePositionOrigin: sharePositionOrigin,
  );
  return false;
}
