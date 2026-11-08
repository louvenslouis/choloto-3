import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import '/flutter_flow/flutter_flow_theme.dart';

bool get drawAdsEnabled => Uri.base.origin == 'https://app.choloto.com';

@JS('cholotoDrawAds.watchConsent')
external JSFunction _watchConsent(JSFunction callback);

@JS('cholotoDrawAds.mount')
external JSFunction _mount(web.HTMLElement element, JSFunction unavailable);

class DrawAdPlacement extends StatefulWidget {
  const DrawAdPlacement({super.key});

  @override
  State<DrawAdPlacement> createState() => _DrawAdPlacementState();
}

class _DrawAdPlacementState extends State<DrawAdPlacement> {
  late final JSFunction _stopConsent;
  JSFunction? _stopSlot;
  bool _allowed = false;
  bool _unfilled = false;
  int _consentRevision = 0;

  @override
  void initState() {
    super.initState();
    _stopConsent = _watchConsent(((bool allowed) {
      if (!mounted || _allowed == allowed) return;
      if (!allowed) _clearSlot();
      setState(() {
        _consentRevision++;
        _allowed = allowed;
        _unfilled = false;
      });
    }).toJS);
  }

  void _clearSlot() {
    _stopSlot?.callAsFunction();
    _stopSlot = null;
  }

  @override
  void dispose() {
    _stopConsent.callAsFunction();
    _clearSlot();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_allowed || _unfilled) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 300) return const SizedBox.shrink();
      final wide = constraints.maxWidth >= 728;
      final revision = _consentRevision;
      final spacing = FlutterFlowTheme.of(context).designToken.spacing;
      return Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.sm),
        child: Center(
          child: SizedBox(
            width: wide ? 728 : constraints.maxWidth.clamp(300, 320),
            height: wide ? 90 : 50,
            child: HtmlElementView.fromTagName(
              key: ValueKey((wide, revision)),
              tagName: 'div',
              onElementCreated: (element) {
                if (!mounted ||
                    !_allowed ||
                    _unfilled ||
                    revision != _consentRevision) {
                  return;
                }
                _clearSlot();
                _stopSlot = _mount(
                    element as web.HTMLElement,
                    (() {
                      if (mounted) setState(() => _unfilled = true);
                    }).toJS);
              },
            ),
          ),
        ),
      );
    });
  }
}
