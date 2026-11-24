import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/payments/payment_requests_widget.dart';
import '/settings/customerservice/customerservice_widget.dart';
import '/support/support_text.dart';
import 'devenir_v_i_p_model.dart';
export 'devenir_v_i_p_model.dart';

class DevenirVIPWidget extends StatefulWidget {
  const DevenirVIPWidget({super.key});

  @override
  State<DevenirVIPWidget> createState() => _DevenirVIPWidgetState();
}

class _DevenirVIPWidgetState extends State<DevenirVIPWidget> {
  late final DevenirVIPModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DevenirVIPModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FlutterFlowTheme.of(context).designToken;
    return LayoutBuilder(builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
      final wide = constraints.maxWidth / scale >= 656;
      final inset = wide ? tokens.spacing.lg : tokens.spacing.md;
      final offerWidth = wide
          ? (constraints.maxWidth - tokens.spacing.md) * 5 / 9
          : constraints.maxWidth;
      final offer = _MonthlyOffer(
        key: const ValueKey('vip-monthly-offer-card'),
        inset: inset,
        inlineDuration: offerWidth >= 260 * scale,
      );
      final comparison = Container(
        key: const ValueKey('vip-plan-comparison-card'),
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsets.all(inset),
        decoration: tokens.home.panel,
        child: const _PlanComparison(),
      );
      if (wide) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: offer),
              SizedBox(width: tokens.spacing.md),
              Expanded(flex: 4, child: comparison),
            ],
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [offer, SizedBox(height: tokens.spacing.md), comparison],
      );
    });
  }
}

class _MonthlyOffer extends StatelessWidget {
  const _MonthlyOffer(
      {super.key, required this.inset, required this.inlineDuration});

  final double inset;
  final bool inlineDuration;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final strings = FFLocalizations.of(context);
    final accent = tokens.home.amethystGlow;
    final buttonHeight =
        (MediaQuery.textScalerOf(context).scale(18) * 1.3 + spacing.md)
            .clamp(kMinInteractiveDimension, double.infinity)
            .toDouble();
    final stubHeight = buttonHeight + 2 * spacing.md;
    final calendar =
        Icon(Icons.calendar_month_rounded, size: 22, color: theme.onPrimary);
    final duration = Text(strings.getText('bl4kupme'),
        style: theme.labelMedium
            .override(color: theme.onPrimary, fontWeight: FontWeight.w700));
    final stamp = DecoratedBox(
      decoration: BoxDecoration(
        gradient: tokens.home.membership,
        border: Border.all(color: tokens.vip.goldLight.withValues(alpha: .64)),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.sm),
        child: inlineDuration
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [calendar, SizedBox(height: spacing.xs), duration])
            : Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: spacing.xs,
                children: [calendar, duration]),
      ),
    );
    final price = Text(
      strings.getText('r11k1q8q'),
      style: theme.headlineMedium.override(
        color: theme.primaryText,
        fontWeight: FontWeight.w800,
        letterSpacing: -.6,
        lineHeight: 1.08,
      ),
    );

    return ClipPath(
      clipper: _TicketNotches(stubHeight, spacing.sm),
      child: DecoratedBox(
        decoration: tokens.vip.pass,
        child: CustomPaint(
          foregroundPainter: _TicketPerforation(stubHeight, spacing.sm,
              tokens.vip.goldLight.withValues(alpha: .58)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: inset, vertical: spacing.lg),
                child: inlineDuration
                    ? Row(children: [
                        stamp,
                        SizedBox(width: spacing.md),
                        Expanded(child: price)
                      ])
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [stamp, SizedBox(height: spacing.sm), price],
                      ),
              ),
              Container(
                height: stubHeight,
                padding: EdgeInsets.symmetric(
                    horizontal: inset, vertical: spacing.md),
                decoration: BoxDecoration(
                  color: theme.primaryBackground.withValues(alpha: .28),
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(tokens.radius.lg)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FFButtonWidget(
                        key: const ValueKey('become-vip-button'),
                        text: strings.getText('i0zhxntw'),
                        onPressed: () {
                          logFirebaseEvent(
                              'DEVENIR_V_I_P_DEVENIR_V_I_P_BTN_ON_TAP');
                          context.pushNamed(PaymentRequestsWidget.routeName);
                        },
                        options: FFButtonOptions(
                          color: accent,
                          height: buttonHeight,
                          padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                          elevation: 0,
                          borderRadius: BorderRadius.circular(tokens.radius.sm),
                          textStyle: theme.titleMedium.override(
                            color: theme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Tooltip(
                      message: supportText(context, 'open'),
                      child: FlutterFlowIconButton(
                        key: const ValueKey('open-subscription-support-legacy'),
                        borderRadius: tokens.radius.sm,
                        borderWidth: 1,
                        borderColor: accent.withValues(alpha: .50),
                        focusBorderSide: BorderSide(color: accent, width: 2),
                        focusBorderRadius:
                            BorderRadius.circular(tokens.radius.sm),
                        hoverColor: accent.withValues(alpha: .14),
                        buttonSize: kMinInteractiveDimension,
                        icon: Icon(Icons.chat_bubble_outline_rounded,
                            size: 21, color: theme.primaryText),
                        onPressed: () =>
                            context.pushNamed(CustomerserviceWidget.routeName),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The cut-outs follow the tear-off strip when larger text makes its buttons taller.
class _TicketNotches extends CustomClipper<Path> {
  const _TicketNotches(this.stubHeight, this.radius);
  final double stubHeight;
  final double radius;

  @override
  Path getClip(Size size) {
    final seam = size.height - stubHeight;
    final holes = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, seam), radius: radius))
      ..addOval(
          Rect.fromCircle(center: Offset(size.width, seam), radius: radius));
    return Path.combine(
        PathOperation.difference, Path()..addRect(Offset.zero & size), holes);
  }

  @override
  bool shouldReclip(_TicketNotches oldClipper) =>
      stubHeight != oldClipper.stubHeight || radius != oldClipper.radius;
}

class _TicketPerforation extends CustomPainter {
  const _TicketPerforation(this.stubHeight, this.notchRadius, this.color);
  final double stubHeight;
  final double notchRadius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final seam = size.height - stubHeight;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    for (final x in [0.0, size.width]) {
      canvas.drawCircle(Offset(x, seam), notchRadius + .5, paint);
    }
    final dash = notchRadius / 2;
    final length = size.width - 4 * notchRadius;
    final count = (length / (2 * dash)).floor();
    final start = (size.width - (count * 2 - 1) * dash) / 2;
    for (var i = 0; i < count; i++) {
      final x = start + i * 2 * dash;
      canvas.drawLine(Offset(x, seam), Offset(x + dash, seam), paint);
    }
  }

  @override
  bool shouldRepaint(_TicketPerforation oldDelegate) =>
      stubHeight != oldDelegate.stubHeight ||
      notchRadius != oldDelegate.notchRadius ||
      color != oldDelegate.color;
}

class _PlanComparison extends StatelessWidget {
  const _PlanComparison();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final strings = FFLocalizations.of(context);
    final freeLabel = strings.getText('juufc32a');
    final vipLabel = strings.getText('zpnlwhem');
    final labelStyle = theme.labelMedium.override(
      color: tokens.home.mutedText,
      fontWeight: FontWeight.w600,
    );
    final freeColumn = EdgeInsets.symmetric(horizontal: spacing.sm);
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
      },
      border: TableBorder(
        horizontalInside: BorderSide(color: tokens.home.panelEdge),
      ),
      children: [
        TableRow(children: [
          Padding(
            padding:
                EdgeInsetsDirectional.only(end: spacing.sm, bottom: spacing.sm),
            child: Semantics(
              header: true,
              child: Text(strings.getText('99kfebqb'),
                  style:
                      theme.titleMedium.override(fontWeight: FontWeight.w700)),
            ),
          ),
          Padding(
            padding: freeColumn.add(EdgeInsets.only(bottom: spacing.sm)),
            child:
                Text(freeLabel, textAlign: TextAlign.center, style: labelStyle),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
                start: spacing.sm, bottom: spacing.sm),
            child: Text(vipLabel,
                textAlign: TextAlign.center,
                style: labelStyle.copyWith(color: tokens.home.amethystGlow)),
          ),
        ]),
        for (final (labelKey, free) in const [
          ('tv8dp8zl', true),
          ('vip_plan_predictions', false),
          ('viphstttl', false),
        ])
          TableRow(children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                  0, spacing.sm, spacing.sm, spacing.sm),
              child: Text(strings.getText(labelKey),
                  style: theme.bodyMedium.override(color: theme.primaryText)),
            ),
            Padding(
              padding: freeColumn,
              child: Icon(
                free ? Icons.check_rounded : Icons.remove_rounded,
                color: tokens.home.mutedText,
                size: 18,
                semanticLabel: '$freeLabel, ${_inclusion(context, free)}',
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(start: spacing.sm),
              child: Icon(
                Icons.check_rounded,
                color: tokens.home.amethystGlow,
                size: 20,
                semanticLabel: '$vipLabel, ${_inclusion(context, true)}',
              ),
            ),
          ]),
      ],
    );
  }

  String _inclusion(BuildContext context, bool included) =>
      FFLocalizations.of(context).getVariableText(
        frText: included ? 'inclus' : 'non inclus',
        enText: included ? 'included' : 'not included',
        crText: included ? 'ladan' : 'pa ladan',
      );
}
