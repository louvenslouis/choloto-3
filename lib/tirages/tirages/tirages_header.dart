import 'package:flutter/material.dart';

import '/components/illustrated_page_header.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/internationalization.dart';

class TiragesHeader extends StatelessWidget {
  const TiragesHeader({
    super.key,
    required this.onRefresh,
    required this.loading,
  });

  final VoidCallback onRefresh;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);

    return IllustratedPageHeader(
      key: const ValueKey('tirages-header'),
      title: strings.getText('hfwdp6xo'),
      asset: 'assets/images/home/draw_ticket.webp',
      artworkKey: const ValueKey('tirages-header-ticket'),
      fallback: Icons.confirmation_number_rounded,
      action: Tooltip(
        message: strings.getText('home_draw_refresh'),
        child: FlutterFlowIconButton(
          key: const ValueKey('tirages-refresh'),
          buttonSize: kMinInteractiveDimension,
          borderRadius: tokens.radius.full,
          borderColor: tokens.home.edge,
          borderWidth: 1,
          fillColor: tokens.background.home.withValues(alpha: .65),
          disabledColor: tokens.background.home.withValues(alpha: .65),
          disabledIconColor: tokens.home.mutedText,
          hoverColor: tokens.home.surface.colors.first,
          hoverIconColor: theme.primary,
          focusBorderSide: BorderSide(color: theme.primary, width: 2),
          focusBorderRadius: BorderRadius.circular(tokens.radius.full),
          icon: Icon(Icons.refresh_rounded, color: theme.primaryText),
          onPressed: loading ? null : onRefresh,
        ),
      ),
    );
  }
}
