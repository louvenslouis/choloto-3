import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'dart:ui';

import 'package:web/web.dart' as web;

import 'croix_download_web.dart';

Future<bool> deliverPreparedCroixJpeg(
  Uint8List jpegBytes, {
  required String fileName,
  required String subject,
  Rect? sharePositionOrigin,
  bool Function()? isCurrent,
}) {
  if (isCurrent?.call() == false) return Future.value(false);

  bool download() {
    if (isCurrent?.call() == false) return false;
    downloadCroixJpeg(jpegBytes, fileName: fileName);
    return true;
  }

  final navigator = web.window.navigator;
  // userActivation is optional even on browsers that implement Web Share.
  final activation =
      navigator.getProperty<web.UserActivation?>('userActivation'.toJS);
  if (activation?.isActive == false) {
    return Future.value(download());
  }
  try {
    final file = web.File(
      <JSUint8Array>[jpegBytes.toJS].toJS,
      fileName,
      web.FilePropertyBag(type: 'image/jpeg'),
    );
    final shareData = web.ShareData(
      files: <web.File>[file].toJS,
      title: subject,
    );
    if (navigator.canShare(shareData)) {
      // Start the share sheet in the tap handler whenever the cached JPEG is ready.
      return _completeBrowserShare(navigator.share(shareData), download);
    }
  } catch (_) {
    // Browsers without the Web Share API still support a JPEG download.
  }
  return Future.value(download());
}

Future<bool> _completeBrowserShare(
  JSPromise<JSAny?> sharePromise,
  bool Function() download,
) async {
  try {
    await sharePromise.toDart;
    return false;
  } on web.DOMException catch (error) {
    if (error.name == 'AbortError') {
      return false;
    }
    return download();
  } catch (_) {
    return download();
  }
}
