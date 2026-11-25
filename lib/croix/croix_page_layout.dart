import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/components/cross_poster_heading.dart';
import '/components/cross_poster_surface.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CroixPageLayout extends StatelessWidget {
  const CroixPageLayout(
      {super.key, required this.child, this.action, this.onBack});

  final Widget child;
  final Widget? action;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return Scaffold(
      backgroundColor: tokens.background.home,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: tokens.background.homeGradient),
        child: SafeArea(
          child: LayoutBuilder(builder: (context, viewport) {
            final margin =
                viewport.maxWidth < 600 ? tokens.spacing.md : tokens.spacing.lg;
            return SingleChildScrollView(
              padding: EdgeInsets.all(margin),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: math.max(0, viewport.maxHeight - margin * 2)),
                child: Align(
                  alignment: const Alignment(0, -.46),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Tooltip(
                            message:
                                FFLocalizations.of(context).getVariableText(
                              frText: 'Retour',
                              enText: 'Back',
                              crText: 'Retounen',
                            ),
                            child: FlutterFlowIconButton(
                              icon: Icon(Icons.arrow_back_rounded,
                                  size: 22, color: tokens.home.amethystGlow),
                              buttonSize: 48,
                              fillColor: tokens.vip.illustrationInk,
                              borderColor: tokens.vip.illustrationBorder,
                              borderWidth: 1,
                              borderRadius: tokens.radius.full,
                              focusBorderSide: BorderSide(
                                  color: tokens.home.amethystGlow, width: 2),
                              onPressed: onBack ?? context.safePop,
                            ),
                          ),
                        ),
                        SizedBox(height: tokens.spacing.md),
                        child,
                        if (action != null) ...[
                          SizedBox(height: tokens.spacing.md),
                          Center(child: action),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class CroixShareButton extends StatelessWidget {
  const CroixShareButton({super.key, required this.onPressed});

  final Future<void> Function(BuildContext context) onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);
    return Tooltip(
      message: strings.getText('croixsharetitle'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 180),
        child: FFButtonWidget(
          text: strings.getText('croix_share_image'),
          icon: Icon(Icons.ios_share_rounded, size: 20, color: theme.onPrimary),
          options: FFButtonOptions(
            padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.lg, vertical: tokens.spacing.sm),
            borderRadius: BorderRadius.circular(tokens.radius.full),
            color: theme.primary,
            textStyle: tokens.vip.typography.action
                .copyWith(color: theme.onPrimary, fontSize: 15),
            maxLines: 2,
            elevation: 0,
          ),
          onPressed: () => onPressed(context),
        ),
      ),
    );
  }
}

class CroixStatusCard extends StatelessWidget {
  const CroixStatusCard({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return CrossPosterSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CrossPosterHeading(),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 180),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Center(
                  child: child ??
                      CircularProgressIndicator(color: theme.onPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}
