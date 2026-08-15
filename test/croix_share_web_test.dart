@TestOn('browser')
library;

import 'package:choloto/croix/croix_share_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compiles the browser-specific JPEG delivery path', () {
    expect(deliverPreparedCroixJpeg, isA<Function>());
  });
}
