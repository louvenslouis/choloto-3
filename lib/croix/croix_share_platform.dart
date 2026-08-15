import 'dart:typed_data';
import 'dart:ui';

import 'croix_share_platform_native.dart'
    if (dart.library.js_interop) 'croix_share_platform_web.dart' as platform;

/// Returns true when the browser downloaded the JPEG instead of opening a
/// native share sheet.
Future<bool> deliverPreparedCroixJpeg(
  Uint8List jpegBytes, {
  required String fileName,
  required String subject,
  Rect? sharePositionOrigin,
}) {
  return platform.deliverPreparedCroixJpeg(
    jpegBytes,
    fileName: fileName,
    subject: subject,
    sharePositionOrigin: sharePositionOrigin,
  );
}
