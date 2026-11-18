import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'tirages_home_model.dart';
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
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 520;
          return Row(
            children: [
              Container(
                width: tokens.spacing.xs,
                height: wide ? 32 : 20,
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
                      fontSize: wide
                          ? (constraints.maxWidth * .054).clamp(29.0, 44.0)
                          : 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Tooltip(
                message: strings.getText('home_draw_refresh'),
                child: FlutterFlowIconButton(
                  buttonSize: 44,
                  icon:
                      Icon(Icons.refresh_rounded, color: tokens.home.mutedText),
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
          );
        }),
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
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final wide = width >= 520;
      final horizontal = wide ? tokens.spacing.lg : tokens.spacing.sm;
      final vertical = wide ? tokens.spacing.md : tokens.spacing.sm;
      final logoSize = wide
          ? (width * .105).clamp(64.0, 92.0)
          : (width * .14).clamp(40.0, 52.0);
      final spacing = wide ? tokens.spacing.md : tokens.spacing.sm;
      final surface = tokens.home.surface.colors;
      return Container(
        alignment: Alignment.center,
        padding:
            EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        decoration: BoxDecoration(
          // A reflection along the top lip makes the sapphire glass catch the light.
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: const Alignment(.42, 1.5),
            colors: [
              Color.lerp(surface.first, tokens.home.edge, .36)!,
              surface.first,
              surface.last,
              Color.lerp(surface.last, tokens.home.edge, .22)!,
            ],
            stops: const [0, .22, .72, 1],
          ),
          borderRadius:
              BorderRadius.circular(wide ? tokens.radius.lg : tokens.radius.md),
          border: Border.all(color: tokens.home.edge),
        ),
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
                SizedBox(width: spacing),
                Container(
                    width: 1, height: logoSize * .62, color: tokens.home.edge),
                SizedBox(width: spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: theme.titleMedium.override(
                            color: theme.primaryText,
                            fontSize:
                                wide ? (width * .042).clamp(22.0, 34.0) : 17,
                            fontWeight: FontWeight.w800,
                            lineHeight: 1.1,
                          )),
                      if (subtitle.isNotEmpty) ...[
                        SizedBox(height: tokens.spacing.xs),
                        Text(subtitle,
                            style: theme.labelMedium.override(
                              color: tokens.home.mutedText,
                              fontSize:
                                  wide ? (width * .026).clamp(15.0, 22.0) : 12,
                              fontWeight: FontWeight.w600,
                              lineHeight: 1.1,
                            )),
                      ],
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
            final chipSize = math.max(
              wide
                  ? (width * .096).clamp(52.0, 84.0)
                  : (width * .116).clamp(33.0, 44.0),
              textScale.scale(18) + 14,
            );
            final chipGap = wide ? tokens.spacing.md : tokens.spacing.xs;
            final numbers = Wrap(
              spacing: chipGap,
              runSpacing: tokens.spacing.xs,
              children: [
                for (int i = 0; i < count; i++)
                  _ResultChip(
                    value:
                        valueOrDefault(record.numeros.elementAtOrNull(i), '-'),
                    size: chipSize,
                  ),
              ],
            );
            final numberWidth = chipSize * count + chipGap * (count - 1);
            final inline = width - horizontal * 2 - numberWidth - 2 >=
                logoSize +
                    spacing * 2 +
                    tokens.spacing.sm +
                    1 +
                    textScale.scale(68);
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
    });
  }
}

class _ResultChip extends StatelessWidget {
  const _ResultChip({required this.value, required this.size});

  final String value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return RepaintBoundary(
      child: CustomPaint(
        key: const ValueKey('home-result-chip'),
        painter: _ResultChipPainter(
            theme.designToken.vip.goldLight,
            theme.warning,
            theme.designToken.home.membership.colors.first,
            theme.onPrimary),
        child: SizedBox.square(
          dimension: size,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                size * .095, size * .10, size * .095, size * .14),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value,
                    style: theme.titleLarge.override(
                      color: theme.onPrimary,
                      fontSize: size * .43,
                      letterSpacing: -.45,
                      fontWeight: FontWeight.w900,
                      lineHeight: 1,
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The chip's edge inserts continue onto its visible lower bevel.
class _ResultChipPainter extends CustomPainter {
  const _ResultChipPainter(this.light, this.gold, this.brass, this.ink);

  final Color light;
  final Color gold;
  final Color brass;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final paint = Paint();
    const rim = Rect.fromLTWH(2, 1.5, 96, 92);
    const hub = Rect.fromLTWH(13, 11.5, 74, 72);
    final bronze = Color.lerp(brass, ink, .52)!;
    final edge = rim.shift(const Offset(0, 3.5));
    canvas.drawOval(
        edge.shift(const Offset(0, 2)),
        paint
          ..color = ink.withValues(alpha: .48)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.8));
    paint.maskFilter = null;
    canvas.drawOval(
        edge,
        paint
          ..color = light
          ..shader = LinearGradient(
            colors: [bronze, brass, bronze, brass, bronze],
          ).createShader(edge));
    canvas.drawOval(
        rim,
        paint
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [light, gold, brass, gold],
            stops: const [0, .28, .76, 1],
          ).createShader(rim));
    // The darker inserts are cut broad, like the wedges in the home artwork.
    paint.shader = null;
    for (var i = 0; i < 10; i++) {
      final angle = (i + .27) * math.pi / 5;
      final wedge = Path()
        ..arcTo(rim, angle, .25, true)
        ..arcTo(hub, angle + .25, -.25, false)
        ..close();
      canvas.drawPath(
          wedge,
          paint
            ..color = Color.lerp(
                brass, bronze, .15 + .27 * (1 + math.sin(angle)) / 2)!);
    }
    canvas.drawOval(hub.inflate(.65), paint..color = bronze);
    canvas.drawOval(
        hub,
        paint
          ..shader = RadialGradient(
            center: const Alignment(-.44, -.65),
            radius: 1.25,
            colors: [light, gold, brass],
            stops: const [0, .57, 1],
          ).createShader(hub));
    canvas.drawArc(
        rim.deflate(.7),
        3.25,
        2.75,
        false,
        paint
          ..shader = null
          ..color = light
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ResultChipPainter old) =>
      old.light != light ||
      old.gold != gold ||
      old.brass != brass ||
      old.ink != ink;
}
