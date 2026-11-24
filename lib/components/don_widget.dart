import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// Bottom sheet that displays the CHOLOTO MonCash tip information.
class DonWidget extends StatelessWidget {
  const DonWidget({super.key});

  static const String _moncashNumber = '+509 3662 3281';

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: tokens.home.surface.colors.last,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(tokens.radius.lg),
            topRight: Radius.circular(tokens.radius.lg),
          ),
          boxShadow: [theme.designToken.shadow.md],
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Tooltip(
                  message: FFLocalizations.of(context).getVariableText(
                      frText: 'Fermer', enText: 'Close', crText: 'Fèmen'),
                  child: FlutterFlowIconButton(
                    borderRadius: tokens.radius.sm,
                    buttonSize: kMinInteractiveDimension,
                    icon: Icon(
                      Icons.close_outlined,
                      color: theme.primaryText,
                      size: 24.0,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Text(
                FFLocalizations.of(context).getText('don_moncash_title'),
                style: theme.headlineMedium,
              ),
              Text(
                FFLocalizations.of(context).getText('don_moncash_instruction'),
                style: theme.bodyMedium.override(
                  color: tokens.home.mutedText,
                ),
              ),
              Container(
                padding: EdgeInsets.all(tokens.spacing.md),
                decoration: tokens.home.panel,
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: tokens.home.amethystGlow,
                      size: 28.0,
                    ),
                    SizedBox(width: tokens.spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FFLocalizations.of(context)
                                .getText('don_moncash_label'),
                            style: theme.labelLarge,
                          ),
                          SizedBox(height: tokens.spacing.xs),
                          Text(
                            _moncashNumber,
                            style: theme.titleLarge.override(
                              color: tokens.home.amethystGlow,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                FFLocalizations.of(context).getText('don_moncash_thanks'),
                textAlign: TextAlign.center,
                style: theme.bodySmall.override(
                  color: tokens.home.mutedText,
                ),
              ),
            ].divide(SizedBox(height: tokens.spacing.md)),
          ),
        ),
      ),
    );
  }
}
