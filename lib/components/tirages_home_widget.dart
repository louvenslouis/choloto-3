import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'draw_result_chip.dart';
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
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 520;
      return Column(
        key: const ValueKey('home-draws-gradient-card'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: tokens.spacing.xs,
                height: wide ? tokens.spacing.lg : 20,
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
                      fontSize: wide ? 32 : 22,
                      fontWeight: FontWeight.w800,
                      lineHeight: 1.15,
                    ),
                  ),
                ),
              ),
              Tooltip(
                message: strings.getText('home_draw_refresh'),
                child: FlutterFlowIconButton(
                  buttonSize: kMinInteractiveDimension,
                  borderRadius: tokens.radius.full,
                  focusBorderSide: BorderSide(color: theme.primary, width: 2),
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
                  buttonSize: kMinInteractiveDimension,
                  borderRadius: tokens.radius.full,
                  focusBorderSide: BorderSide(color: theme.primary, width: 2),
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
          DecoratedBox(
            decoration: tokens.home.panel,
            child: Column(children: [
              _marketRow(
                future: _model.newYork,
                title: strings.getText('home_draw_new_york'),
                asset: 'assets/images/New_york.png',
                maxNumbers: 3,
              ),
              Divider(
                height: 1,
                thickness: 1,
                indent: tokens.spacing.md,
                endIndent: tokens.spacing.md,
                color: tokens.home.panelEdge,
              ),
              _marketRow(
                future: _model.florida,
                title: strings.getText('home_draw_florida'),
                asset: 'assets/images/Florida.png',
                maxNumbers: 4,
              ),
            ]),
          ),
        ],
      );
    });
  }
}

Widget _marketRow({
  required Future<List<ResultatsRecord>> future,
  required String title,
  required String asset,
  required int maxNumbers,
}) =>
    FutureBuilder<List<ResultatsRecord>>(
      future: future,
      builder: (context, snapshot) => _DrawSurface(
        title: title,
        asset: asset,
        maxNumbers: maxNumbers,
        snapshot: snapshot,
      ),
    );

class _DrawSurface extends StatefulWidget {
  const _DrawSurface(
      {required this.title,
      required this.asset,
      required this.maxNumbers,
      required this.snapshot});

  final String title;
  final String asset;
  final int maxNumbers;
  final AsyncSnapshot<List<ResultatsRecord>> snapshot;

  @override
  State<_DrawSurface> createState() => _DrawSurfaceState();
}

class _DrawSurfaceState extends State<_DrawSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _arrival;
  ResultatsRecord? _lastDraw;
  bool _hasBaseline = false;
  bool _allowMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _allowMotion = !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (!_allowMotion && !_arrival.isCompleted) _arrival.value = 1;
  }

  @override
  void initState() {
    super.initState();
    _arrival = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 540),
      value: 1,
    );
    _observeDraw();
  }

  @override
  void didUpdateWidget(_DrawSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    _observeDraw();
  }

  void _observeDraw() {
    final snapshot = widget.snapshot;
    if (snapshot.connectionState != ConnectionState.done || snapshot.hasError) {
      return;
    }
    final draw = snapshot.data?.firstOrNull;
    if (draw != null && draw.numeros.isNotEmpty) {
      final previous = _lastDraw;
      final older = previous?.date != null &&
          draw.date != null &&
          draw.date!.isBefore(previous!.date!);
      final changed = previous == null ||
          draw.reference.path != previous.reference.path ||
          draw.date != previous.date ||
          draw.periode != previous.periode;
      if (!older && changed) {
        if (_hasBaseline && _allowMotion) _arrival.forward(from: 0);
        _lastDraw = draw;
      }
    }
    _hasBaseline = true;
  }

  @override
  void dispose() {
    _arrival.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final record = snapshot.data?.firstOrNull;
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);
    final viewport = MediaQuery.sizeOf(context);
    final phonePortrait =
        viewport.width < kBreakpointSmall && viewport.height > viewport.width;
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final wide = width >= 520;
      final horizontal = wide ? tokens.spacing.lg : tokens.spacing.md;
      // The phone panel and support FAB share their trailing screen inset.
      final endInset = phonePortrait
          ? kMinInteractiveDimension + tokens.spacing.sm
          : horizontal;
      final vertical =
          wide ? tokens.spacing.md : tokens.spacing.sm + tokens.spacing.xs;
      final logoSize = wide ? 56.0 : 40.0;
      final spacing = wide ? tokens.spacing.md : tokens.spacing.sm;
      return Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          horizontal,
          vertical,
          endInset,
          vertical,
        ),
        child: Builder(
          builder: (context) {
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
                Image.asset(widget.asset,
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true),
                SizedBox(width: spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: theme.titleMedium.override(
                            color: theme.primaryText,
                            fontSize: wide ? 24 : 17,
                            fontWeight: FontWeight.w700,
                            lineHeight: 1.1,
                          )),
                      if (subtitle.isNotEmpty) ...[
                        SizedBox(height: tokens.spacing.xs),
                        Text(subtitle,
                            style: theme.labelMedium.override(
                              color: tokens.home.mutedText,
                              fontSize: wide ? 16 : 14,
                              fontWeight: FontWeight.w500,
                              lineHeight: 1.2,
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

            final count = record.numeros.length.clamp(3, widget.maxNumbers);
            final textScale = MediaQuery.textScalerOf(context);
            final chipSize = math.max(
              wide
                  ? (width * .08).clamp(48.0, 64.0)
                  : (width * .116).clamp(33.0, 44.0),
              textScale.scale(18) + 14,
            );
            final chipGap = wide ? tokens.spacing.sm : tokens.spacing.xs;
            final numbers = Wrap(
              spacing: chipGap,
              runSpacing: tokens.spacing.xs,
              children: [
                for (int i = 0; i < count; i++)
                  _ResultChip(
                    arrival: _arrival,
                    index: i,
                    value:
                        valueOrDefault(record.numeros.elementAtOrNull(i), '-'),
                    size: chipSize,
                  ),
              ],
            );
            final numberWidth = chipSize * count + chipGap * (count - 1);
            final inline = width - horizontal - endInset - numberWidth >=
                logoSize + spacing + tokens.spacing.sm + textScale.scale(80);
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
  const _ResultChip(
      {required this.value,
      required this.size,
      required this.arrival,
      required this.index});

  final Animation<double> arrival;
  final int index;

  final String value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final chip = DrawResultChip(
      key: const ValueKey('home-result-chip'),
      value: value,
      size: size,
    );
    if (value == '-') return chip;
    return AnimatedBuilder(
      animation: arrival,
      child: chip,
      builder: (context, child) {
        final phase = ((arrival.value - index * .10) / .70).clamp(0.0, 1.0);
        // Each numbered chip rocks onto its edge, then settles flat in its own slot.
        final settle = 1 - Curves.easeOutBack.transform(phase);
        return Transform(
          key: const ValueKey('home-result-chip-motion'),
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..translateByDouble(0, -size * .18 * settle, 0, 1)
            ..rotateZ(-.14 * settle)
            ..rotateX(.32 * settle),
          child: child,
        );
      },
    );
  }
}
