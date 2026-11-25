import 'dart:ui' as ui show Gradient, TextDirection;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderProxyBox;

import '/backend/schema/prediction_record.dart';
import '/backend/schema/structs/predictions_struct.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/internationalization.dart' show kTranslationsMap;

enum _Category {
  favorite('viphstfav', 'favorite', Icons.star_outline_rounded,
      FFVipJewel.tourmaline),
  soutni(
      'viphstsou', 'soutni', Icons.trip_origin_rounded, FFVipJewel.aquamarine),
  boloto('viphstbol', 'boloto', Icons.casino_outlined, FFVipJewel.sapphire),
  mariage('viphstmar', 'mariage', Icons.link_rounded, FFVipJewel.ruby),
  threeDigits(
      'viphstc3f', 'three_digits', Icons.looks_3_outlined, FFVipJewel.amethyst),
  fourDigits(
      'viphstc4f', 'four_digits', Icons.looks_4_outlined, FFVipJewel.emerald),
  extra('viphstext', 'extra', Icons.auto_awesome_outlined, FFVipJewel.amber);

  const _Category(this.labelKey, this.artwork, this.icon, this.jewel);
  final String labelKey;
  final String artwork;
  final IconData icon;
  final FFVipJewel jewel;
}

const _artAspectRatio = 4 / 3;
final _marriagePair = RegExp(r'^([0-9]+)(\s*[xX×]\s*)([0-9]+)$');

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
  Widget build(BuildContext context) => ListenableBuilder(
        // Track widths are measured during build, including before Inter loads.
        listenable: PaintingBinding.instance.systemFonts,
        builder: (context, _) => _buildPanel(context),
      );

  Widget _buildPanel(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final type = tokens.vip.typography;
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
      final compact = available < 440;
      final gap = compact ? spacing.sm : spacing.md;
      final wideBoard = available >= 640;
      final titleStyle = type.posterTitle(compact: !wideBoard);
      final rows = available < 280
          ? [
              for (final group in groups) [group]
            ]
          : [
              groups.sublist(0, 2),
              groups.sublist(2, 4),
              if (wideBoard)
                groups.sublist(4)
              else ...[groups.sublist(4, 6), groups.sublist(6)],
            ];
      final dateBlock = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              date.isEmpty
                  ? strings.getText('viphstnod')
                  : date[0].toUpperCase() + date.substring(1),
              style: type.heading(compact ? 21 : 28),
            ),
          ),
          if (period.isNotEmpty)
            Text(period,
                style: type.supporting.copyWith(color: tokens.home.mutedText)),
        ],
      );
      final alignMetadata = available >= 280;
      final probability = MergeSemantics(
        child: Column(
          crossAxisAlignment:
              alignMetadata ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(strings.getText('vipproblb'),
                textAlign: alignMetadata ? TextAlign.end : TextAlign.start,
                style: type.supporting.copyWith(color: tokens.home.mutedText)),
            Text('${prediction.pourcentage}%',
                style:
                    type.numeral(24).copyWith(color: tokens.home.amethystGlow)),
          ],
        ),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!prediction.hasPourcentage())
            dateBlock
          else if (alignMetadata)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: dateBlock),
                SizedBox(width: gap),
                Flexible(
                    child: Align(
                        alignment: Alignment.topRight, child: probability)),
              ],
            )
          else ...[
            dateBlock,
            SizedBox(height: spacing.sm),
            probability,
          ],
          SizedBox(height: spacing.md),
          for (final (index, row) in rows.indexed) ...[
            if (index > 0) SizedBox(height: gap),
            _predictionRow(
              row,
              width: constraints.maxWidth,
              gap: gap,
              titleStyle: titleStyle,
            ),
          ],
        ],
      );
    });
  }

  Widget _predictionRow(
    List<(PredictionsStruct, _Category)> row, {
    required double width,
    required double gap,
    required TextStyle titleStyle,
  }) {
    final cardWidth = (width - gap * (row.length - 1)) / row.length;
    final extraBand = row.length == 1 && row.first.$2 == _Category.extra;
    // Wide tiles read horizontally. The content can always grow past this
    // baseline, including a single published selection at large text sizes.
    final minimumHeight = extraBand
        ? (cardWidth * .34).clamp(104.0, 144.0).toDouble()
        : min(cardWidth / _artAspectRatio, 192.0);
    return IntrinsicHeight(
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
                width: cardWidth,
                minimumHeight: minimumHeight,
                titleStyle: titleStyle,
              ),
            ),
          ],
        ],
      ),
    );
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
    required this.minimumHeight,
    required this.titleStyle,
  });

  final PredictionsStruct group;
  final _Category category;
  final double width;
  final double minimumHeight;
  final TextStyle titleStyle;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final type = tokens.vip.typography;
    final strings = FFLocalizations.of(context);
    final name = group.name.trim();
    final knownNames = kTranslationsMap[category.labelKey]!.values;
    final label = name.isEmpty || knownNames.contains(name.toUpperCase())
        ? strings.getText(category.labelKey)
        : name;
    final values = _publishedValues(category, group.boul);
    final marriages = category == _Category.mariage;
    final textScaler = MediaQuery.textScalerOf(context);
    final small = width < 200 * textScaler.scale(16) / 16;
    final inset = small ? spacing.sm + spacing.xs : spacing.md;
    final contentWidth = width - 2 * inset;
    final frame = _PosterFrame(
      radius: tokens.radius.md,
      bevel: spacing.md,
      rim: tokens.vip.posterRim(category.jewel),
    );
    final shade = tokens.vip.posterShade(category.jewel);
    var multipleSize = small ? 32.0 : 40.0;
    if (small &&
        category == _Category.fourDigits &&
        values.length > 1 &&
        values.every((entry) => RegExp(r'^[0-9]{4}$').hasMatch(entry.$2))) {
      final widths = _ValueMeasure(context);
      final limit = (contentWidth - spacing.sm - spacing.xs) / 2;
      if (widths.of('0000', type.numeral(32)) > limit &&
          widths.of('0000', type.numeral(28)) <= limit) {
        multipleSize = 28;
      }
      widths.dispose();
    }
    final numbers = <_PredictionValue>[];
    for (final (index, value) in values) {
      final pair = marriages ? _marriagePair.firstMatch(value) : null;
      final length =
          pair == null ? value.length : pair[1]!.length + 1 + pair[3]!.length;
      final size = length > 7
          ? (small ? 25.0 : 34.0)
          : (length > 3 || values.length > 1)
              ? multipleSize
              : (small ? 46.0 : 60.0);
      numbers.add(_PredictionValue(
        value: value,
        style: type.numeral(size),
        pair: pair,
        market: switch ((category, index)) {
          (_Category.favorite, 0 || 1) ||
          (_Category.soutni, 1) =>
            strings.getText('xm4yj0vd'),
          (_Category.soutni, 0) => strings.getText('vip_market_gg_ny'),
          _ => null,
        },
      ));
    }
    final marketCount =
        numbers.takeWhile((entry) => entry.market != null).length;
    final Widget selection;
    if (numbers.isEmpty) {
      selection = Text('—',
          semanticsLabel: strings.getText('viphstnos'),
          style: type.numeral(small ? 32 : 40));
    } else if (marriages) {
      selection = _MarriageValues(values: numbers, width: contentWidth);
    } else if (marketCount > 0) {
      selection = _MarketValues(
        values: numbers,
        marketCount: marketCount,
        width: contentWidth,
      );
    } else {
      selection = _NumberGrid(values: numbers, width: contentWidth);
    }

    return SizedBox(
      width: width,
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: frame),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: ShapeDecoration(shape: frame),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned.fill(child: _PredictionArtwork(category: category)),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: minimumHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, inset, inset, spacing.sm),
                  child: MergeSemantics(
                    child: Semantics(
                      label: label,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: inset),
                            child: _TextShade(
                                inset: inset,
                                ink: shade,
                                compact: small,
                                child: selection),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(top: spacing.sm + spacing.xs),
                            child: ExcludeSemantics(
                              child: CustomPaint(
                                painter: _TitleRibbon(
                                  face: tokens.vip.titleRibbon(category.jewel),
                                  trim: tokens.vip.gold,
                                  bevel: spacing.sm + spacing.xs,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      inset,
                                      spacing.xs,
                                      spacing.md + spacing.xs,
                                      spacing.xs),
                                  child: Text(label, style: titleStyle),
                                ),
                              ),
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
        ),
      ),
    );
  }
}

// Three rounded corners and one cut shoulder recall the bevel on the name ribbon.
class _PosterFrame extends ShapeBorder {
  const _PosterFrame(
      {required this.radius, required this.bevel, required this.rim});
  final double radius;
  final double bevel;
  final Gradient rim;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {ui.TextDirection? textDirection}) {
    final r = min(radius, rect.shortestSide / 2);
    final cut = min(bevel, rect.shortestSide / 2);
    final round = Radius.circular(r);
    return Path()
      ..moveTo(rect.left + r, rect.top)
      ..lineTo(rect.right - cut, rect.top)
      ..lineTo(rect.right, rect.top + cut)
      ..lineTo(rect.right, rect.bottom - r)
      ..arcToPoint(Offset(rect.right - r, rect.bottom), radius: round)
      ..lineTo(rect.left + r, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom - r), radius: round)
      ..lineTo(rect.left, rect.top + r)
      ..arcToPoint(Offset(rect.left + r, rect.top), radius: round)
      ..close();
  }

  @override
  Path getInnerPath(Rect rect, {ui.TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(1.5));

  @override
  void paint(Canvas canvas, Rect rect, {ui.TextDirection? textDirection}) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = rim.createShader(rect);
    canvas.drawPath(getOuterPath(rect.deflate(.75)), paint);
    // One short inner facet catches the light at the cut, clear of the values.
    final shoulder = Path()
      ..moveTo(rect.right - bevel * 1.65, rect.top + 4)
      ..lineTo(rect.right - bevel - 2, rect.top + 4)
      ..lineTo(rect.right - 4, rect.top + bevel + 2)
      ..lineTo(rect.right - 4, rect.top + bevel * 1.65);
    canvas.drawPath(shoulder, paint..strokeWidth = .7);
  }

  @override
  ShapeBorder scale(double t) =>
      _PosterFrame(radius: radius * t, bevel: bevel * t, rim: rim);
}

class _TitleRibbon extends CustomPainter {
  const _TitleRibbon(
      {required this.face, required this.trim, required this.bevel});
  final Gradient face;
  final Gradient trim;
  final double bevel;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    // The bevel stays narrow when a translated title wraps onto several lines.
    Path ribbon(double right, double bottom) => Path()
      ..moveTo(0, 0)
      ..lineTo(right, 0)
      ..lineTo(max(0.0, right - bevel), bottom)
      ..lineTo(0, bottom)
      ..close();
    final paint = Paint()..shader = trim.createShader(bounds);
    canvas.drawPath(ribbon(size.width, size.height), paint);
    paint.shader = face.createShader(bounds);
    canvas.drawPath(ribbon(size.width - 2.5, size.height - 1), paint);
  }

  @override
  bool shouldRepaint(_TitleRibbon old) =>
      face != old.face || trim != old.trim || bevel != old.bevel;
}

// Wide market rows and tall selections share the same uncropped still life.
class _PredictionArtwork extends StatelessWidget {
  const _PredictionArtwork({required this.category});
  final _Category category;

  @override
  Widget build(BuildContext context) {
    final tokens = FlutterFlowTheme.of(context).designToken;
    final ground = tokens.vip.posterGround(category.jewel);
    return LayoutBuilder(builder: (context, bounds) {
      final artworkWidth =
          min(bounds.maxWidth, bounds.maxHeight * _artAspectRatio);
      final artworkHeight = artworkWidth / _artAspectRatio;
      final above = bounds.maxHeight - artworkHeight;
      final left = bounds.maxWidth - artworkWidth;
      return Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: ground)),
          Positioned(
            bottom: 0,
            right: 0,
            width: artworkWidth,
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
                      size: artworkWidth * .33),
                ),
              ),
            ),
          ),
          if (above > .5 || left > .5)
            Positioned(
              top: max(0.0, above - 1),
              left: max(0.0, left - 1),
              width: left > .5 ? artworkWidth * .42 : artworkWidth,
              height: above > .5
                  ? min(artworkHeight * .4, above + tokens.spacing.md)
                  : artworkHeight,
              child: DecoratedBox(
                  decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: left > .5 ? Alignment.centerLeft : Alignment.topCenter,
                  end: left > .5
                      ? Alignment.centerRight
                      : Alignment.bottomCenter,
                  colors: [ground, ground.withValues(alpha: 0)],
                ),
              )),
            ),
          Positioned.fill(
            child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: tokens.vip.posterLight(category.jewel),
                ),
                child:
                    CustomPaint(painter: _FoilEngraving(tokens.vip.goldLight))),
          ),
        ],
      );
    });
  }
}

// A small fan of engraved lines fades out before reaching the still life.
class _FoilEngraving extends CustomPainter {
  const _FoilEngraving(this.foil);
  final Color foil;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width * .57;
    final height = min(size.height, width);
    final baseline = size.height - height * .24;
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final y = baseline - i * 3;
      path.moveTo(0, y);
      path.cubicTo(width * .35, y + height * .06, width * .56, y - height * .32,
          width, y - height * .27);
    }
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .65
          ..shader = ui.Gradient.linear(Offset.zero, Offset(width, 0), [
            foil.withValues(alpha: .12),
            foil.withValues(alpha: .31),
            foil.withValues(alpha: 0),
          ], const [
            0,
            .42,
            1
          ]));
  }

  @override
  bool shouldRepaint(_FoilEngraving old) => foil != old.foil;
}

// The child supplies its true size, including every wrapped row and market
// caption. Only the pictorial background outside that footprint fades to clear.
class _TextShade extends StatelessWidget {
  const _TextShade(
      {required this.inset,
      required this.ink,
      required this.compact,
      required this.child});
  final double inset;
  final Color ink;
  final bool compact;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = FlutterFlowTheme.of(context).designToken;
    final fade = compact
        ? Size(tokens.spacing.lg, tokens.spacing.xl)
        : Size(tokens.spacing.xl + tokens.spacing.lg,
            tokens.spacing.xl + tokens.spacing.md);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          left: -inset,
          right: -fade.width,
          top: -inset,
          bottom: -fade.height,
          child: CustomPaint(
              painter: _CornerFade(
            ink: ink,
            fade: fade,
          )),
        ),
        child,
      ],
    );
  }
}

class _CornerFade extends CustomPainter {
  const _CornerFade({required this.ink, required this.fade});
  final Color ink;
  final Size fade;

  @override
  void paint(Canvas canvas, Size size) {
    // Work in units of one feather. Both straight edges meet the same radial
    // falloff at the corner, without a blur filter or an off-screen layer.
    canvas.save();
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
  bool shouldRepaint(_CornerFade old) => ink != old.ink || fade != old.fade;
}

class _PredictionValue extends StatelessWidget {
  const _PredictionValue({
    required this.value,
    required this.market,
    required this.pair,
    required this.style,
  });

  final String value;
  final String? market;
  final RegExpMatch? pair;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final type = FlutterFlowTheme.of(context).designToken.vip.typography;
    final match = pair;
    if (match == null) return Text(value, style: style);
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: match[1]),
        TextSpan(text: match[2], style: type.pairSeparator(style)),
        TextSpan(text: match[3]),
      ]),
      style: style,
    );
  }
}

class _ValueMeasure {
  _ValueMeasure(BuildContext context)
      : _painter = TextPainter(
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        );

  final TextPainter _painter;

  double of(String text, TextStyle style) {
    _painter.text = TextSpan(text: text, style: style);
    _painter.layout();
    return _painter.width.ceilToDouble();
  }

  void dispose() => _painter.dispose();
}

class _MarketValues extends StatelessWidget {
  const _MarketValues({
    required this.values,
    required this.marketCount,
    required this.width,
  });

  final List<_PredictionValue> values;
  final int marketCount;
  final double width;

  @override
  Widget build(BuildContext context) {
    final tokens = FlutterFlowTheme.of(context).designToken;
    final marketStyle = tokens.vip.typography.market;
    final gap = tokens.spacing.sm;
    final widths = _ValueMeasure(context);
    final labelled = values.take(marketCount);
    final labelWidth = labelled
        .map((entry) => widths.of(entry.market!, marketStyle))
        .reduce(max);
    final numberWidth = width - labelWidth - gap;
    Widget line(double height) => SizedBox(
          width: min(width, labelWidth + gap + tokens.spacing.lg),
          child: Divider(
            height: height,
            thickness: 1,
            color: tokens.vip.illustrationBorder,
          ),
        );
    final rows = [
      for (final (index, entry) in labelled.indexed) ...[
        if (index > 0) line(tokens.spacing.xs),
        if (widths.of(entry.value, entry.style) <= numberWidth)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  width: labelWidth,
                  child: Text(entry.market!, style: marketStyle)),
              SizedBox(width: gap),
              Flexible(child: entry),
            ],
          )
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(entry.market!, style: marketStyle), entry],
          ),
      ],
      if (marketCount < values.length) ...[
        line(gap),
        _NumberGrid(values: values.sublist(marketCount), width: width),
      ],
    ];
    widths.dispose();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

class _NumberGrid extends StatelessWidget {
  const _NumberGrid({required this.values, required this.width});

  final List<_PredictionValue> values;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (values.length == 1) return values.first;
    final tokens = FlutterFlowTheme.of(context).designToken;
    final spacing = tokens.spacing;
    final gap = spacing.sm + spacing.xs;
    final scaler = MediaQuery.textScalerOf(context);
    final widths = _ValueMeasure(context);
    final advances = [
      for (final entry in values) widths.of(entry.value, entry.style)
    ];
    widths.dispose();
    final twoColumnLimit = (width - gap) / 2;
    final track = advances.where((w) => w <= twoColumnLimit).fold(0.0, max);
    final threeAcross = values.length == 3 &&
        advances.every((w) => w <= twoColumnLimit) &&
        3 * track + 2 * gap <= width * .78;
    final columns = threeAcross ? 3 : 2;
    final rows = <Widget>[];
    var i = 0;
    while (i < values.length) {
      // A long selection owns its line. Short selections on either side
      // retain their published order and the same column starts.
      if (advances[i] > twoColumnLimit) {
        rows.add(values[i++]);
        continue;
      }
      final start = i++;
      while (i < values.length &&
          i - start < columns &&
          advances[i] <= twoColumnLimit) {
        i++;
      }
      final em = scaler.scale(values[start].style.fontSize!);
      rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var cell = start; cell < i; cell++) ...[
            if (cell > start)
              SizedBox(
                height: em * values[start].style.height!,
                child: VerticalDivider(
                  width: gap,
                  thickness: 1,
                  indent: em * .25,
                  endIndent: em * .25,
                  color: tokens.vip.illustrationBorder,
                ),
              ),
            if (cell < i - 1)
              SizedBox(width: track, child: values[cell])
            else
              Flexible(child: values[cell]),
          ],
        ],
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xs,
      children: rows,
    );
  }
}

class _MarriageValues extends StatelessWidget {
  const _MarriageValues({required this.values, required this.width});

  final List<_PredictionValue> values;
  final double width;

  @override
  Widget build(BuildContext context) {
    final spacing = FlutterFlowTheme.of(context).designToken.spacing;
    final type = FlutterFlowTheme.of(context).designToken.vip.typography;
    final widths = _ValueMeasure(context);
    final gap = spacing.sm * MediaQuery.textScalerOf(context).scale(16) / 16;
    final pairs = [
      for (final entry in values)
        if (entry.pair case final pair?)
          (
            first: widths.of(pair[1]!, entry.style),
            sign: widths.of(pair[2]!.trim(), type.pairSeparator(entry.style)),
            second: widths.of(pair[3]!, entry.style),
          )
        else
          null,
    ];
    widths.dispose();
    // Oversized historical pairs wrap independently, keeping them out of the
    // column measurements for pairs that can read on a single line.
    final fitting = pairs.nonNulls
        .where((p) => p.first + p.sign + p.second + 2 * gap <= width);
    final firstWidth = fitting.fold(0.0, (w, p) => max(w, p.first));
    final signWidth = fitting.fold(0.0, (w, p) => max(w, p.sign));
    final rows = <Widget>[];
    for (final (i, entry) in values.indexed) {
      final pair = entry.pair;
      final measured = pairs[i];
      if (pair == null || measured == null) {
        rows.add(entry);
        continue;
      }
      final aligned = measured.first <= firstWidth &&
          measured.sign <= signWidth &&
          firstWidth + signWidth + 2 * gap + measured.second <= width;
      rows.add(Semantics(
        key: ValueKey('vip-marriage-pair-$i'),
        label: entry.value,
        excludeSemantics: true,
        child: aligned
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      width: firstWidth,
                      child: Text(pair[1]!,
                          style: entry.style, textAlign: TextAlign.end)),
                  SizedBox(width: gap),
                  SizedBox(
                      width: signWidth,
                      child: Text(pair[2]!.trim(),
                          style: type.pairSeparator(entry.style),
                          textAlign: TextAlign.center)),
                  SizedBox(width: gap),
                  Flexible(child: Text(pair[3]!, style: entry.style)),
                ],
              )
            : entry,
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xs,
      children: rows,
    );
  }
}
