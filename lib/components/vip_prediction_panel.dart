import 'dart:ui' as ui show Gradient;

import 'package:collection/collection.dart' show ListExtensions;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderProxyBox;

import '/backend/schema/prediction_record.dart';
import '/backend/schema/structs/predictions_struct.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/internationalization.dart' show kTranslationsMap;

enum _Category {
  favorite('viphstfav', 'favorite', Icons.star_outline_rounded),
  soutni('viphstsou', 'soutni', Icons.trip_origin_rounded),
  boloto('viphstbol', 'boloto', Icons.casino_outlined),
  mariage('viphstmar', 'mariage', Icons.link_rounded),
  threeDigits('viphstc3f', 'three_digits', Icons.looks_3_outlined),
  fourDigits('viphstc4f', 'four_digits', Icons.looks_4_outlined),
  extra('viphstext', 'extra', Icons.auto_awesome_outlined);

  const _Category(this.labelKey, this.artwork, this.icon);
  final String labelKey;
  final String artwork;
  final IconData icon;
}

const _artAspectRatio = 4 / 3;
final _marriagePair = RegExp(r'^[0-9]+\s*[xX×]\s*[0-9]+$');

List<(int, String)> _publishedValues(_Category category, List<String> slots) {
  final result = <(int, String)>[];
  for (var i = 0; i < slots.length; i++) {
    final start = i;
    var value = slots[i].trim();
    if (value.isEmpty) continue;
    if (category == _Category.mariage && !_marriagePair.hasMatch(value)) {
      // The dashboard editor can split one pair at either or both spaces.
      var candidate = value;
      for (var next = start + 1;
          next < slots.length && next <= start + 2;
          next++) {
        final part = slots[next].trim();
        if (part.isEmpty) break;
        candidate = '$candidate $part';
        if (_marriagePair.hasMatch(candidate)) {
          value = candidate;
          i = next;
          break;
        }
      }
    }
    result.add((start, value));
  }
  return result;
}

class VipPredictionPanel extends StatelessWidget {
  const VipPredictionPanel({super.key, required this.prediction});

  final PredictionRecord prediction;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final strings = FFLocalizations.of(context);
    final groups = [
      (prediction.favori, _Category.favorite),
      (prediction.soutni, _Category.soutni),
      (prediction.boloto, _Category.boloto),
      (prediction.mariage, _Category.mariage),
      (prediction.chif3, _Category.threeDigits),
      (prediction.chif4, _Category.fourDigits),
      (prediction.extra, _Category.extra),
    ];
    final date = dateTimeFormat('MMMMEEEEd', prediction.date,
        locale: strings.languageCode);
    final period = switch (prediction.periode.trim().toLowerCase()) {
      'midi' || 'midday' => strings.getText('home_draw_midday'),
      'soir' || 'evening' || 'aswè' => strings.getText('home_draw_evening'),
      _ => prediction.periode.trim(),
    };
    return LayoutBuilder(builder: (context, constraints) {
      final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
      final available = constraints.maxWidth / textScale;
      final columns = switch (available) {
        >= 960 => 4,
        >= 640 => 3,
        >= 280 => 2,
        _ => 1,
      };
      final compact = available < 440;
      final gap = compact ? spacing.sm : spacing.md;
      final columnWidth =
          (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OverflowBar(
            alignment: MainAxisAlignment.spaceBetween,
            spacing: spacing.md,
            overflowSpacing: spacing.sm,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      date.isEmpty
                          ? strings.getText('viphstnod')
                          : date[0].toUpperCase() + date.substring(1),
                      style: theme.headlineSmall.override(
                        fontSize: compact ? 20 : 26,
                        fontWeight: FontWeight.w800,
                        lineHeight: 1.15,
                      ),
                    ),
                  ),
                  if (period.isNotEmpty)
                    Text(period,
                        style: theme.bodyMedium.copyWith(
                          color: tokens.home.mutedText,
                        )),
                ],
              ),
              if (prediction.hasPourcentage())
                MergeSemantics(
                  child: Wrap(
                    spacing: spacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(strings.getText('vipproblb'),
                          style: theme.labelMedium
                              .copyWith(color: tokens.home.mutedText)),
                      Text('${prediction.pourcentage}%',
                          style: theme.titleLarge.copyWith(
                            color: tokens.home.amethystGlow,
                            fontWeight: FontWeight.w800,
                          )),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          for (final (index, row) in groups.slices(columns).indexed) ...[
            if (index > 0) SizedBox(height: gap),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (column, entry) in row.indexed) ...[
                    if (column > 0) SizedBox(width: gap),
                    _MeasuredCard(
                      child: _PredictionCard(
                        key: ValueKey('vip-prediction-${entry.$2.name}'),
                        group: entry.$1,
                        category: entry.$2,
                        width: columnWidth,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

// A row needs the height of the actual wrapped selection at its column width.
// Intrinsic text heights alone can miss a line when a market wraps or a font loads.
class _MeasuredCard extends SingleChildRenderObjectWidget {
  const _MeasuredCard({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasuredCard();
}

class _RenderMeasuredCard extends RenderProxyBox {
  @override
  double computeMaxIntrinsicHeight(double width) =>
      child!.getDryLayout(BoxConstraints.tightFor(width: width)).height;
}

class _PredictionCard extends StatelessWidget {
  const _PredictionCard({
    super.key,
    required this.group,
    required this.category,
    required this.width,
  });

  final PredictionsStruct group;
  final _Category category;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final strings = FFLocalizations.of(context);
    final name = group.name.trim();
    final knownNames = kTranslationsMap[category.labelKey]!.values;
    final label = name.isEmpty || knownNames.contains(name.toUpperCase())
        ? strings.getText(category.labelKey)
        : name;
    final values = _publishedValues(category, group.boul);
    final marriages = category == _Category.mariage;
    final hasMarkets =
        category == _Category.favorite || category == _Category.soutni;
    final textScaler = MediaQuery.textScalerOf(context);
    final small = width < 200 * textScaler.scale(16) / 16;
    final inset = small ? spacing.sm + spacing.xs : spacing.md;
    final longest =
        values.fold(0, (length, entry) => max(length, entry.$2.length));
    final double fontSize;
    if (longest > 7) {
      fontSize = small ? 24 : 30;
    } else if (values.length > 1 || longest > 3) {
      fontSize = small ? 28 : 36;
    } else {
      fontSize = small ? 40 : 52;
    }
    final numberStyle = theme.displaySmall.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: -.8,
      color: theme.primaryText,
      height: 1.15,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final contentWidth = width - 2 * inset;
    var valuesWidth = contentWidth;
    if (!marriages && !hasMarkets && values.length > 2 && longest <= 7) {
      // Wrap a series of short numbers towards the left, while reserving
      // at least the width of its longest individual value.
      valuesWidth = width * .60 - inset;
      final painter = TextPainter(
        textDirection: Directionality.of(context),
        textScaler: textScaler,
      );
      for (final (_, value) in values) {
        painter.text = TextSpan(text: value, style: numberStyle);
        painter.layout();
        valuesWidth = max(valuesWidth, painter.width.ceilToDouble());
      }
      painter.dispose();
      valuesWidth = min(valuesWidth, contentWidth);
    }
    final radius = BorderRadius.circular(tokens.radius.md);
    final numbers = [
      for (final (index, value) in values)
        _PredictionValue(
          value: value,
          style: numberStyle,
          market: switch ((category, index)) {
            (_Category.favorite, 0 || 1) ||
            (_Category.soutni, 1) =>
              strings.getText('xm4yj0vd'),
            (_Category.soutni, 0) => strings.getText('vip_market_gg_ny'),
            _ => null,
          },
        ),
    ];
    Widget numberRow(List<Widget> entries) => Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.xs,
          children: entries,
        );
    final marketCount =
        numbers.takeWhile((entry) => entry.market != null).length;
    final Widget selection;
    if (numbers.isEmpty) {
      selection = Text('—',
          semanticsLabel: strings.getText('viphstnos'),
          style: theme.headlineMedium.copyWith(color: theme.primaryText));
    } else if (marriages) {
      selection = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xs,
        children: numbers,
      );
    } else if (marketCount > 0 && marketCount < numbers.length) {
      // Unlabelled historical slots start on a fresh line so a market can
      // never appear to describe one of their values.
      selection = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xs,
        children: [
          numberRow(numbers.sublist(0, marketCount)),
          numberRow(numbers.sublist(marketCount)),
        ],
      );
    } else {
      selection = numberRow(numbers);
    }

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: tokens.vip.illustrationInk,
        borderRadius: radius,
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: tokens.vip.illustrationBorder),
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(child: _PredictionArtwork(category: category)),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: width / _artAspectRatio),
            child: Padding(
              padding: EdgeInsets.all(inset),
              child: MergeSemantics(
                child: Semantics(
                  label: label,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: valuesWidth),
                        child: _TextShade(
                            inset: inset, atTop: true, child: selection),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: spacing.md),
                        child: _TextShade(
                          inset: inset,
                          atTop: false,
                          child: ExcludeSemantics(
                              child: Text(
                            label,
                            style: theme.titleMedium.copyWith(
                              fontSize: small ? 15 : 19,
                              color: theme.primaryText,
                              fontWeight: FontWeight.w800,
                              height: 1.12,
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A long list can make a tile much taller than its 4:3 still life. Keep the
// entire object at the lower right and blend the extra space into the artwork.
class _PredictionArtwork extends StatelessWidget {
  const _PredictionArtwork({required this.category});
  final _Category category;

  @override
  Widget build(BuildContext context) {
    final tokens = FlutterFlowTheme.of(context).designToken;
    final ink = tokens.vip.illustrationInk;
    return LayoutBuilder(builder: (context, bounds) {
      final artworkHeight = bounds.maxWidth / _artAspectRatio;
      final extension = max(0.0, bounds.maxHeight - artworkHeight);
      return Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: artworkHeight,
            child: Image.asset(
              'assets/images/vip_predictions/${category.artwork}.webp',
              key: ValueKey('vip-art-${category.name}'),
              fit: BoxFit.contain,
              excludeFromSemantics: true,
              errorBuilder: (_, __, ___) => Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacing.md),
                  child: Icon(category.icon,
                      color: tokens.home.amethystGlow,
                      size: bounds.maxWidth * .33),
                ),
              ),
            ),
          ),
          if (extension > .5)
            Positioned(
              top: extension - 1,
              left: 0,
              right: 0,
              height: min(artworkHeight * .4, extension + tokens.spacing.md),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [ink, ink.withValues(alpha: 0)],
                ),
              )),
            ),
        ],
      );
    });
  }
}

// The child supplies its true size, including every wrapped row and market
// caption. Only the pictorial background outside that footprint fades to clear.
class _TextShade extends StatelessWidget {
  const _TextShade(
      {required this.inset, required this.atTop, required this.child});
  final double inset;
  final bool atTop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = FlutterFlowTheme.of(context).designToken;
    final fade =
        Size(tokens.spacing.xl, atTop ? tokens.spacing.xl : tokens.spacing.md);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          left: -inset,
          right: -fade.width,
          top: atTop ? -inset : -fade.height,
          bottom: atTop ? -fade.height : -inset,
          child: CustomPaint(
              painter: _CornerFade(
            ink: tokens.vip.illustrationShade,
            fade: fade,
            atTop: atTop,
          )),
        ),
        child,
      ],
    );
  }
}

class _CornerFade extends CustomPainter {
  const _CornerFade(
      {required this.ink, required this.fade, required this.atTop});
  final Color ink;
  final Size fade;
  final bool atTop;

  @override
  void paint(Canvas canvas, Size size) {
    // Work in units of one feather. Both straight edges meet the same radial
    // falloff at the corner, without a blur filter or an off-screen layer.
    canvas.save();
    if (!atTop) {
      canvas.translate(0, size.height);
      canvas.scale(1, -1);
    }
    canvas.scale(fade.width, fade.height);
    final right = size.width / fade.width - 1;
    final bottom = size.height / fade.height - 1;
    final corner = Offset(right, bottom);
    final colors = [ink, ink.withValues(alpha: 0)];
    final paint = Paint()..isAntiAlias = false;
    canvas.drawRect(Rect.fromLTRB(0, 0, right, bottom), paint..color = ink);
    paint.color = ink.withValues(alpha: 1);
    paint.shader =
        ui.Gradient.linear(corner, Offset(right + 1, bottom), colors);
    canvas.drawRect(Rect.fromLTRB(right, 0, right + 1, bottom), paint);
    paint.shader =
        ui.Gradient.linear(corner, Offset(right, bottom + 1), colors);
    canvas.drawRect(Rect.fromLTRB(0, bottom, right, bottom + 1), paint);
    paint.shader = ui.Gradient.radial(corner, 1, colors);
    canvas.drawRect(Rect.fromLTWH(right, bottom, 1, 1), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CornerFade old) =>
      ink != old.ink || fade != old.fade || atTop != old.atTop;
}

class _PredictionValue extends StatelessWidget {
  const _PredictionValue({
    required this.value,
    required this.market,
    required this.style,
  });

  final String value;
  final String? market;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: style),
        if (market != null)
          Text(market!,
              style: theme.labelSmall.copyWith(
                color: theme.primaryText,
                fontWeight: FontWeight.w600,
              )),
      ],
    );
  }
}
