import 'dart:js_interop';

import 'package:flutter/widgets.dart';

import 'croix_ad_gate.dart';
import 'draw_ad_eligibility.dart';
import 'draw_ad_platform_web.dart' show drawAdsEnabled;

@JS('cholotoCroixAds.prepare')
external JSFunction _prepare(JSString path, JSFunction ready, JSFunction done);

Widget gateCroix(Widget child) {
  // Use the full Ad Manager unit path supplied by Sanon's production network.
  const path = String.fromEnvironment('CHOLOTO_CROIX_REWARDED_UNIT');
  if (!drawAdsEnabled || path.isEmpty) return child;
  return CroixAdGate(
    accounts: watchDrawAdAccount,
    prepare: (ready, done) {
      final cancel = _prepare(
          path.toJS,
          ((JSFunction show) {
            ready(() => show.callAsFunction());
          }).toJS,
          ((bool open) => done(open)).toJS);
      return () => cancel.callAsFunction();
    },
    child: child,
  );
}
