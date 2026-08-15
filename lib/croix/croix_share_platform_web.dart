import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui';

import 'package:web/web.dart' as web;

import 'croix_download_web.dart';

Future<bool> deliverPreparedCroixJpeg(
  Uint8List jpegBytes, {
  required String fileName,
  required String subject,
  Rect? sharePositionOrigin,
}) {
  final file = web.File(
    <JSUint8Array>[jpegBytes.toJS].toJS,
    fileName,
    web.FilePropertyBag(type: 'image/jpeg'),
  );
  final shareData = web.ShareData(
    files: <web.File>[file].toJS,
    title: subject,
  );

  try {
    if (!web.window.navigator.canShare(shareData)) {
      downloadCroixJpeg(jpegBytes, fileName: fileName);
      return Future.value(true);
    }

    // Calling navigator.share here, before returning a Future, preserves the
    // transient user activation required by Chrome on Android.
    final sharePromise = web.window.navigator.share(shareData);
    return _completeBrowserShare(
      sharePromise,
      jpegBytes,
      fileName: fileName,
    );
  } catch (_) {
    downloadCroixJpeg(jpegBytes, fileName: fileName);
    return Future.value(true);
  }
}

Future<bool> _completeBrowserShare(
  JSPromise<JSAny?> sharePromise,
  Uint8List jpegBytes, {
  required String fileName,
}) async {
  try {
    await sharePromise.toDart;
    return false;
  } on web.DOMException catch (error) {
    if (error.name == 'AbortError') {
      return false;
    }
    downloadCroixJpeg(jpegBytes, fileName: fileName);
    return true;
  } catch (_) {
    downloadCroixJpeg(jpegBytes, fileName: fileName);
    return true;
  }
}
