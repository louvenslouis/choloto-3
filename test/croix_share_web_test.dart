@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:choloto/croix/croix_share_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:web/web.dart' as web;

@JS('Object.getOwnPropertyDescriptor')
external JSObject? _propertyDescriptor(JSObject target, String key);

@JS('Object.defineProperty')
external void _defineProperty(JSObject target, String key, JSObject descriptor);

@JS('Promise.resolve')
external JSPromise<JSAny?> _resolved();

@JS('Promise.reject')
external JSPromise<JSAny?> _rejected(web.DOMException error);

void _replaceNavigatorProperty(String key, JSAny? value) {
  final navigator = web.window.navigator;
  final original = _propertyDescriptor(navigator, key);
  _defineProperty(
      navigator,
      key,
      JSObject()
        ..['configurable'] = true.toJS
        ..['value'] = value);
  addTearDown(() {
    if (original == null) {
      navigator.delete(key.toJS);
    } else {
      _defineProperty(navigator, key, original);
    }
  });
}

void main() {
  const fileName = 'croix-de-la-chance.jpg';
  const title = 'Partager la Croix de la Chance';
  // The Flutter browser test server serves files in test/. A visual run can
  // pass the actual poster exported by croix_presentation_test to every case.
  const exportedPoster = String.fromEnvironment('CROIX_EXPORTED_JPEG');
  late Uint8List jpeg;
  late List<web.ShareData> capabilityChecks;
  late List<web.ShareData> shares;
  late List<({String name, Future<web.Blob> blob})> downloads;

  setUpAll(() async {
    if (exportedPoster.isEmpty) {
      final poster = image.Image(width: 3, height: 2)
        ..setPixelRgb(1, 1, 92, 42, 120);
      jpeg = image.encodeJpg(poster);
      return;
    }
    final response = await web.window
        .fetch('/${Uri.encodeComponent(exportedPoster)}'.toJS)
        .toDart;
    expect(response.ok, isTrue,
        reason: 'Load the JPEG exported by the share button');
    jpeg = (await response.arrayBuffer().toDart).toDart.asUint8List();
    expect(image.JpegDecoder().startDecode(jpeg), isNotNull);
  });

  setUp(() {
    capabilityChecks = [];
    shares = [];
    downloads = [];
    final listen = ((web.Event event) {
      final target = event.target;
      if (!target.instanceOfString('HTMLAnchorElement')) return;
      final anchor = target as web.HTMLAnchorElement;
      // Keep the browser's real Blob URL alive for the read before its owner
      // revokes it. Prevent the actual save to the test machine.
      event.preventDefault();
      final response = web.window.fetch(anchor.href.toJS).toDart;
      downloads.add((
        name: anchor.download,
        blob: response.then((result) => result.blob().toDart),
      ));
    }).toJS;
    web.document.addEventListener('click', listen, true.toJS);
    addTearDown(
        () => web.document.removeEventListener('click', listen, true.toJS));
  });

  void browser({
    bool? active = true,
    bool? supportsFiles = true,
    String? rejection,
  }) {
    _replaceNavigatorProperty('userActivation',
        active == null ? null : (JSObject()..['isActive'] = active.toJS));
    _replaceNavigatorProperty(
        'canShare',
        supportsFiles == null
            ? null
            : ((web.ShareData data) {
                capabilityChecks.add(data);
                return supportsFiles;
              }).toJS);
    _replaceNavigatorProperty(
        'share',
        supportsFiles == null
            ? null
            : ((web.ShareData data) {
                shares.add(data);
                return rejection == null
                    ? _resolved()
                    : _rejected(web.DOMException('Browser test', rejection));
              }).toJS);
  }

  Future<bool> deliver({bool Function()? isCurrent}) =>
      deliverPreparedCroixJpeg(jpeg,
          fileName: fileName, subject: title, isCurrent: isCurrent);

  Future<void> expectPoster(web.Blob blob) async {
    expect(blob.type, 'image/jpeg');
    final contents = await blob.arrayBuffer().toDart;
    expect(contents.toDart.asUint8List(), orderedEquals(jpeg));
  }

  Future<void> expectDownload() async {
    final download = downloads.single;
    expect(download.name, fileName);
    await expectPoster(await download.blob);
    expect(web.document.querySelector('a[download="$fileName"]'), isNull);
  }

  for (final activation in [true, null]) {
    test(
        'Delivers the exact JPEG within the tap with userActivation=$activation',
        () async {
      browser(active: activation);
      final delivery = deliver();
      // Waiting for a second event loop turn can lose transient activation.
      expect(capabilityChecks, hasLength(1));
      expect(shares, hasLength(1));
      expect(await delivery, isFalse);
      for (final data in [capabilityChecks.single, shares.single]) {
        expect(data.title, title);
        final file = data.files.toDart.single;
        expect(file.name, fileName);
        await expectPoster(file);
      }
      expect(downloads, isEmpty);
    });
  }

  test('Cancelling the native share sheet never downloads the image', () async {
    browser(rejection: 'AbortError');
    expect(await deliver(), isFalse);
    expect(shares, hasLength(1));
    expect(downloads, isEmpty);
  });

  for (final supportsFiles in [false, null]) {
    test(
        'Downloads the exact JPEG in the tap when file sharing is $supportsFiles',
        () async {
      browser(supportsFiles: supportsFiles);
      final delivery = deliver();
      expect(downloads, hasLength(1));
      expect(await delivery, isTrue);
      expect(shares, isEmpty);
      await expectDownload();
    });
  }

  test('Expired activation downloads once without opening the share sheet',
      () async {
    browser(active: false);
    final delivery = deliver();
    expect(downloads, hasLength(1));
    expect(await delivery, isTrue);
    expect(shares, isEmpty);
    await expectDownload();
  });

  test('A browser denial falls back to the same JPEG without a second tap',
      () async {
    browser(rejection: 'NotAllowedError');
    expect(await deliver(), isTrue);
    expect(shares, hasLength(1));
    await expectDownload();
  });

  test('A rejected share cannot download a withdrawn publication', () async {
    browser(rejection: 'NotAllowedError');
    var published = true;
    final delivery = deliver(isCurrent: () => published);
    expect(shares, hasLength(1));
    published = false;
    expect(await delivery, isFalse);
    expect(downloads, isEmpty);
  });

  test('An already withdrawn publication does not reach the browser', () async {
    browser();
    expect(await deliver(isCurrent: () => false), isFalse);
    expect(capabilityChecks, isEmpty);
    expect(shares, isEmpty);
    expect(downloads, isEmpty);
  });
}
