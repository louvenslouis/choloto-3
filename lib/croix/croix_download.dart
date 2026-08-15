import 'dart:typed_data';

import 'croix_download_stub.dart'
    if (dart.library.js_interop) 'croix_download_web.dart' as platform;

void downloadCroixJpeg(Uint8List bytes, {required String fileName}) {
  platform.downloadCroixJpeg(bytes, fileName: fileName);
}
