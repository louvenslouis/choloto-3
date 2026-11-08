import 'package:flutter/widgets.dart';

import 'draw_ad_eligibility.dart';
import 'draw_ad_platform_stub.dart'
    if (dart.library.js_interop) 'draw_ad_platform_web.dart';

class DrawAdBanner extends StatefulWidget {
  const DrawAdBanner({super.key});

  @override
  State<DrawAdBanner> createState() => _DrawAdBannerState();
}

class _DrawAdBannerState extends State<DrawAdBanner> {
  late final _accounts = watchFreeDrawAccount();

  @override
  Widget build(BuildContext context) {
    if (!drawAdsEnabled) {
      return const SizedBox.shrink();
    }
    return StreamBuilder<String?>(
      stream: _accounts,
      builder: (context, snapshot) {
        final uid = snapshot.data;
        if (snapshot.hasError || uid == null) return const SizedBox.shrink();
        return DrawAdPlacement(key: ValueKey(uid));
      },
    );
  }
}
