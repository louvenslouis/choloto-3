import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'tirages_home_model.dart';
import 'vip_casino_card.dart';
export 'tirages_home_model.dart';

class TiragesHomeWidget extends StatefulWidget {
  const TiragesHomeWidget({super.key});

  @override
  State<TiragesHomeWidget> createState() => _TiragesHomeWidgetState();
}

class _TiragesHomeWidgetState extends State<TiragesHomeWidget> {
  late TiragesHomeModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TiragesHomeModel());
    _model.loadDraws();
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);
    return Column(
      key: const ValueKey('home-draws-gradient-card'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: tokens.spacing.xs,
              height: 22,
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(tokens.radius.full),
              ),
            ),
            SizedBox(width: tokens.spacing.sm),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  strings.getText('home_latest_results'),
                  style: theme.headlineSmall.override(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Tooltip(
              message: strings.getText('home_draw_refresh'),
              child: FlutterFlowIconButton(
                buttonSize: 44,
                icon: Icon(Icons.refresh_rounded, color: tokens.home.mutedText),
                onPressed: () {
                  logFirebaseEvent('TIRAGES_HOME_COMP_refresh_ICN_ON_TAP');
                  logFirebaseEvent('IconButton_update_component_state');
                  setState(() => _model.loadDraws(refresh: true));
                },
              ),
            ),
            Tooltip(
              message: strings.getText('zljfxk4l'),
              child: FlutterFlowIconButton(
                buttonSize: 44,
                icon: Icon(Icons.arrow_forward_rounded,
                    color: tokens.home.mutedText),
                onPressed: () {
                  logFirebaseEvent('TIRAGES_HOME_COMP_VOIR_TOUT_BTN_ON_TAP');
                  logFirebaseEvent('Button_navigate_to');
                  context.pushNamed(TiragesWidget.routeName);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.xs),
        _DrawRow(
          future: _model.newYork,
          title: strings.getText('home_draw_new_york'),
          asset: 'assets/images/New_york.png',
          maxNumbers: 3,
        ),
        SizedBox(height: tokens.spacing.sm),
        _DrawRow(
          future: _model.florida,
          title: strings.getText('home_draw_florida'),
          asset: 'assets/images/Florida.png',
          maxNumbers: 4,
        ),
      ],
    );
  }
}

class _DrawRow extends StatelessWidget {
  const _DrawRow({
    required this.future,
    required this.title,
    required this.asset,
    required this.maxNumbers,
  });

  final Future<List<ResultatsRecord>> future;
  final String title;
  final String asset;
  final int maxNumbers;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: tokens.home.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.home.edge),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 520;
        final padding = wide ? tokens.spacing.md : tokens.spacing.sm;
        final logoSize = wide ? 52.0 : 40.0;
        return Padding(
          padding: EdgeInsets.all(padding),
          child: FutureBuilder<List<ResultatsRecord>>(
            future: future,
            builder: (context, snapshot) {
              final record = snapshot.data?.firstOrNull;
              final subtitle = record == null
                  ? (snapshot.connectionState != ConnectionState.done
                      ? ''
                      : strings.getText(snapshot.hasError
                          ? 'home_draw_unavailable'
                          : 'home_draw_empty'))
                  : [
                      if (record.periode.isNotEmpty)
                        switch (record.periode.trim().toLowerCase()) {
                          'midi' => strings.getText('home_draw_midday'),
                          'soir' => strings.getText('home_draw_evening'),
                          _ => record.periode,
                        },
                      if (record.hasDate())
                        dateTimeFormat('MMMd', record.date,
                            locale: strings.languageCode),
                    ].join(' · ');
              final identity = Row(
                children: [
                  Image.asset(asset,
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true),
                  SizedBox(width: tokens.spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: theme.titleMedium.override(
                              color: theme.primaryText,
                              fontWeight: FontWeight.w800,
                            )),
                        if (subtitle.isNotEmpty)
                          Text(subtitle,
                              style: theme.labelMedium.override(
                                color: tokens.home.mutedText,
                              )),
                      ],
                    ),
                  ),
                ],
              );

              if (record == null) {
                return Row(children: [
                  Expanded(child: identity),
                  if (snapshot.connectionState != ConnectionState.done)
                    Padding(
                      padding: EdgeInsets.all(tokens.spacing.sm),
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.primary,
                        ),
                      ),
                    ),
                ]);
              }

              final count = record.numeros.length.clamp(3, maxNumbers);
              final textScale = MediaQuery.textScalerOf(context);
              final chipSize =
                  math.max(wide ? 50.0 : 37.0, textScale.scale(18) + 16);
              final numbers = Wrap(
                spacing: tokens.spacing.xs,
                runSpacing: tokens.spacing.xs,
                children: [
                  for (int i = 0; i < count; i++)
                    VipCasinoChip(
                      child: SizedBox.square(
                        dimension: chipSize,
                        child: Padding(
                          padding: EdgeInsets.all(tokens.spacing.xs),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              valueOrDefault(
                                  record.numeros.elementAtOrNull(i), '-'),
                              style: theme.titleLarge.override(
                                color: theme.onPrimary,
                                fontSize: wide ? 23 : 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
              final numberWidth =
                  chipSize * count + tokens.spacing.xs * (count - 1);
              final inline = constraints.maxWidth - padding * 2 - numberWidth >=
                  logoSize + tokens.spacing.sm * 2 + textScale.scale(76);
              return inline
                  ? Row(children: [
                      Expanded(child: identity),
                      SizedBox(width: tokens.spacing.sm),
                      numbers,
                    ])
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        identity,
                        SizedBox(height: tokens.spacing.sm),
                        numbers
                      ],
                    );
            },
          ),
        );
      }),
    );
  }
}
