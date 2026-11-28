import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'page_header_app_bar.dart';

PageHeaderAppBar subscriptionPageHeader(BuildContext context) {
  final theme = FlutterFlowTheme.of(context);
  final tokens = theme.designToken;
  return PageHeaderAppBar(
    vip: true,
    automaticallyImplyLeading: false,
    leading: FlutterFlowIconButton(
      borderRadius: tokens.radius.sm,
      buttonSize: 40.0,
      icon: Icon(
        Icons.arrow_back_rounded,
        color: theme.primaryText,
        size: 24.0,
      ),
      onPressed: context.safePop,
    ),
    title: Text(
      FFLocalizations.of(context).getText('eywbwq85'),
      style: theme.headlineMedium.override(
        fontFamily: 'Google sans flex',
        color: theme.primaryText,
        fontSize: 22.0,
        letterSpacing: 0.0,
      ),
    ),
    centerTitle: false,
  );
}
