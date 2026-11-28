import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/backend/schema/structs/data_stack_struct.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/internationalization.dart';

/// The numbers remain live text above the unlettered, die-cut ticket.
class BingoStoryResultTicket extends StatelessWidget {
  const BingoStoryResultTicket({
    super.key,
    required this.entry,
    required this.count,
  });

  final DataStackStruct entry;
  final int count;

  // Registration points on the 600 × 600 illustration. Keep ink clear of
  // the side cutouts and the stacked gold edges under the front face.
  static const _tilt = -7.5 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final strings = FFLocalizations.of(context);
    final number = entry.boul.trim().isEmpty ? '—' : entry.boul.trim();
    final period = entry.periode.trim();
    final market = entry.tirage.trim();
    final prize = entry.valeur.trim();
    final day = switch (period.toLowerCase()) {
      'midi' || 'midday' => true,
      'soir' || 'swa' || 'evening' => false,
      _ => null,
    };
    final periodLabel = day == null
        ? period
        : strings.getText(day ? 'home_draw_midday' : 'home_draw_evening');
    final countLabel = count > 1
        ? strings.getVariableText(
            frText: '$count résultats',
            enText: '$count results',
            crText: '$count rezilta')
        : '';
    final label = [number, prize, market, periodLabel, countLabel]
        .where((part) => part.isNotEmpty)
        .join(', ');

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: label,
      child: LayoutBuilder(builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final unit = side / 600;
        return Center(
          child: SizedBox.square(
            dimension: side,
            child: Stack(children: [
              Positioned.fill(
                child: Image.asset('assets/images/bingo/story_ticket.webp',
                    fit: BoxFit.contain, excludeFromSemantics: true),
              ),
              Positioned(
                left: 76 * unit,
                top: 313 * unit,
                width: 448 * unit,
                height: 152 * unit,
                child: Transform.rotate(
                  angle: _tilt,
                  child: _TicketInscription(
                    number: number,
                    prize: prize.toUpperCase(),
                    market: market,
                    day: day,
                    otherPeriod: day == null ? period : '',
                    unit: unit,
                  ),
                ),
              ),
              if (count > 1)
                Positioned(
                  right: 60 * unit,
                  top: 493 * unit,
                  width: 85 * unit,
                  height: 44 * unit,
                  child: Transform.rotate(
                    angle: _tilt,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.designToken.background.home,
                        borderRadius: BorderRadius.circular(10 * unit),
                        border: Border.all(
                            color: theme.designToken.vip.goldLight,
                            width: 2.5 * unit),
                        boxShadow: [theme.designToken.shadow.sm],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5 * unit),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('×$count',
                              style: theme.designToken.vip.typography
                                  .heading(27 * unit)
                                  .copyWith(
                                      color: theme.designToken.vip.goldLight)),
                        ),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        );
      }),
    );
  }
}

class _TicketInscription extends StatelessWidget {
  const _TicketInscription({
    required this.number,
    required this.prize,
    required this.market,
    required this.day,
    required this.otherPeriod,
    required this.unit,
  });
  final String number;
  final String prize;
  final String market;
  final bool? day;
  final String otherPeriod;
  final double unit;

  // Only these glyphs between digits are separators. Keep every original
  // character, including leading zeros and unfamiliar historical formats.
  static final _tokens = RegExp(r'[0-9]+|[^0-9]+');
  static final _separator = RegExp(r'^[Xx×*•.\-]+$');

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final vip = theme.designToken.vip;
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final textSize = 25 * unit;
    final prizeStyle = vip.typography.posterTitle(compact: false).copyWith(
          color: theme.primaryText,
          fontSize: textSize,
          height: 1.1,
        );
    final marketStyle = vip.typography.market.copyWith(
      fontSize: textSize,
      letterSpacing: 0,
      height: 1.1,
      shadows: [
        Shadow(
            color: theme.primaryBackground,
            offset: Offset(0, unit),
            blurRadius: unit)
      ],
    );
    final marketText =
        [market, otherPeriod].where((value) => value.isNotEmpty).join(' · ');
    final iconSize = scaler.scale(textSize);
    final gap = 9 * unit;
    final hasMarket = day != null || marketText.isNotEmpty;
    final hasDetails = hasMarket || prize.isNotEmpty;

    double widthOf(TextSpan span) {
      final painter =
          TextPainter(text: span, textDirection: direction, textScaler: scaler)
            ..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    final parts = _tokens.allMatches(number).map((m) => m[0]!).toList();
    final material = theme.designToken.bingo;
    TextSpan inscription(double size) {
      final style = material.numeral(size);
      return TextSpan(style: style, children: [
        for (var i = 0; i < parts.length; i++)
          TextSpan(
              text: parts[i],
              style:
                  i > 0 && i < parts.length - 1 && _separator.hasMatch(parts[i])
                      ? style.copyWith(
                          fontSize: size * .70,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2 * unit)
                      : null),
      ]);
    }

    final numberSpan = inscription(110 * unit);
    final numberWidth = widthOf(numberSpan);
    final prizeWidth = widthOf(TextSpan(text: prize, style: prizeStyle));
    final marketWidth =
        widthOf(TextSpan(text: marketText, style: marketStyle)) +
            (day != null ? iconSize + gap : 0);
    final width = 448 * unit;
    final rule = vip.goldLight.withValues(alpha: .55);
    Widget display(TextSpan span) {
      Widget digits(TextSpan content) => Text.rich(content,
          maxLines: 1, softWrap: false, textDirection: TextDirection.ltr);

      // Mask only the face of the type. In a rotating, fitted ticket a
      // paragraph paint shader can sample the far end of its gradient.
      // A separate cast shadow stays dark behind the locally lit face.
      final relief = TextSpan(
        style: span.style!
            .copyWith(color: vip.goldShade, shadows: material.relief),
        children: span.children,
      );
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Stack(children: [
          Transform.translate(
              offset: Offset(0, 2 * unit), child: digits(relief)),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => material.goldFace.createShader(bounds),
            child: digits(span),
          ),
        ]),
      );
    }

    final prizeLabel =
        Text(prize, style: prizeStyle, maxLines: 1, softWrap: false);
    final marketLabel = Row(mainAxisSize: MainAxisSize.min, children: [
      if (day != null)
        Icon(day! ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            size: iconSize, color: theme.warning),
      if (day != null && marketText.isNotEmpty) SizedBox(width: gap),
      if (marketText.isNotEmpty)
        Text(marketText, style: marketStyle, maxLines: 1, softWrap: false),
    ]);

    // Reserve a full-size column for the lot and market. The optical midpoint
    // of the short layout stays consistent between draws with different labels.
    final inline = hasDetails &&
        numberWidth <= width * .54 &&
        math.max(prizeWidth, marketWidth) <= width * .46 - 3 * gap;
    if (inline) {
      return Row(key: const ValueKey('bingo-story-inline'), children: [
        Expanded(flex: 54, child: Center(child: display(numberSpan))),
        SizedBox(width: gap),
        Container(width: 1.5 * unit, height: 118 * unit, color: rule),
        SizedBox(width: gap),
        Expanded(
            flex: 46,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prize.isNotEmpty) prizeLabel,
                  if (prize.isNotEmpty && hasMarket)
                    SizedBox(height: 13 * unit),
                  if (hasMarket) marketLabel,
                ],
              ),
            )),
      ]);
    }

    final detailsAcross = prizeWidth + marketWidth + 2 * gap <= width;
    return Column(key: const ValueKey('bingo-story-stacked'), children: [
      Expanded(
          flex: detailsAcross ? 7 : 5,
          child: Center(child: display(numberSpan))),
      if (hasDetails) ...[
        Container(width: width * .83, height: unit, color: rule),
        Expanded(
            flex: detailsAcross ? 3 : 5,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Flex(
                direction: detailsAcross ? Axis.horizontal : Axis.vertical,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prize.isNotEmpty) prizeLabel,
                  if (hasMarket && prize.isNotEmpty)
                    SizedBox(
                        width: 2 * gap, height: detailsAcross ? 0 : 3 * unit),
                  if (hasMarket) marketLabel,
                ],
              ),
            )),
      ],
    ]);
  }
}
