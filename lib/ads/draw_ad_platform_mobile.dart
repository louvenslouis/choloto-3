import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/internationalization.dart';

bool get drawAdsEnabled =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

class DrawAdPlacement extends StatefulWidget {
  const DrawAdPlacement({super.key});

  @override
  State<DrawAdPlacement> createState() => _DrawAdPlacementState();
}

class _DrawAdPlacementState extends State<DrawAdPlacement> {
  BannerAd? _banner;
  bool _loaded = false;
  bool _privacyRequired = false;
  bool _changingConsent = false;

  @override
  void initState() {
    super.initState();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        if (mounted) {
          ConsentForm.loadAndShowConsentFormIfRequired(_afterConsent);
        }
      },
      (_) {},
    );
  }

  Future<void> _afterConsent(FormError? error) async {
    if (!mounted) return;
    try {
      final consent = ConsentInformation.instance;
      final required = await consent.getPrivacyOptionsRequirementStatus();
      if (!mounted) return;
      _privacyRequired = required == PrivacyOptionsRequirementStatus.required;
      if (error != null || !await consent.canRequestAds() || !mounted) return;
      await MobileAds.instance.initialize();
      if (mounted) await _loadBanner();
    } on PlatformException {
      _clearBanner();
    } finally {
      if (mounted) setState(() => _changingConsent = false);
    }
  }

  Future<void> _loadBanner() async {
    final android = defaultTargetPlatform == TargetPlatform.android;
    final id = kReleaseMode
        ? (android
            ? 'ca-app-pub-4099201352969884/8094379250'
            : 'ca-app-pub-4099201352969884/1389370100')
        : (android
            ? 'ca-app-pub-3940256099942544/6300978111'
            : 'ca-app-pub-3940256099942544/2934735716');
    final banner = BannerAd(
      size: AdSize.banner,
      adUnitId: id,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted && identical(ad, _banner)) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          if (identical(ad, _banner)) {
            _clearBanner();
            if (mounted) setState(() {});
          }
        },
      ),
    );
    _banner = banner;
    await banner.load();
  }

  void _clearBanner() {
    _banner?.dispose();
    _banner = null;
    _loaded = false;
  }

  void _editConsent() {
    setState(() {
      _changingConsent = true;
      _clearBanner();
    });
    ConsentForm.showPrivacyOptionsForm(_afterConsent);
  }

  @override
  void dispose() {
    _clearBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (!_privacyRequired && !_loaded) return const SizedBox.shrink();
    final theme = FlutterFlowTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_loaded && banner != null)
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth < banner.size.width) {
              return const SizedBox.shrink();
            }
            return Center(
                child: Padding(
              padding:
                  EdgeInsets.symmetric(vertical: theme.designToken.spacing.sm),
              child: SizedBox(
                width: banner.size.width.toDouble(),
                height: banner.size.height.toDouble(),
                child: AdWidget(ad: banner),
              ),
            ));
          }),
        if (_privacyRequired)
          TextButton(
            onPressed: _changingConsent ? null : _editConsent,
            child: Text(
                FFLocalizations.of(context).getVariableText(
                  frText: 'Confidentialité des annonces',
                  enText: 'Ad privacy options',
                  crText: 'Konfidansyalite piblisite',
                ),
                style: theme.labelMedium.copyWith(color: theme.primaryText)),
          ),
      ],
    );
  }
}
