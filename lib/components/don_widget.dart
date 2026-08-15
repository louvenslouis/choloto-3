import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// Bottom sheet that displays the CHOLOTO MonCash tip information.
class DonWidget extends StatelessWidget {
  const DonWidget({super.key});

  static const String _moncashNumber = '+509 43 56 06 33';

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
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
                child: FlutterFlowIconButton(
                  borderRadius: tokens.radius.sm,
                  buttonSize: 40.0,
                  icon: Icon(
                    Icons.close_outlined,
                    color: theme.primaryText,
                    size: 24.0,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Text(
                FFLocalizations.of(context).getText('don_moncash_title'),
                style: theme.headlineMedium,
              ),
              Text(
                FFLocalizations.of(context).getText('don_moncash_instruction'),
                style: theme.bodyMedium.override(
                  color: theme.secondaryText,
                ),
              ),
              Container(
                padding: EdgeInsets.all(tokens.spacing.md),
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                  border: Border.all(
                    color: theme.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: theme.primary,
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
                              color: theme.primary,
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
                  color: theme.secondaryText,
                ),
              ),
            ].divide(SizedBox(height: tokens.spacing.md)),
          ),
        ),
      ),
    );
  }
}
