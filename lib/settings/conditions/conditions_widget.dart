import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'conditions_model.dart';
export 'conditions_model.dart';

class ConditionsWidget extends StatefulWidget {
  const ConditionsWidget({super.key});

  static String routeName = 'conditions';
  static String routePath = '/conditions';

  @override
  State<ConditionsWidget> createState() => _ConditionsWidgetState();
}

class _ConditionsWidgetState extends State<ConditionsWidget> {
  late ConditionsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ConditionsModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'conditions'});

    // Keep the generated model's controllers initialized until that model is
    // regenerated without the former placeholder expandable sections.
    _model.expandableExpandableController1 = ExpandableController();
    _model.expandableExpandableController2 = ExpandableController();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final localizations = FFLocalizations.of(context);
    final terms = FFAppConstants.termesEtConditionsForLocale(
      localizations.languageCode,
    );

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: Icon(
            Icons.close_rounded,
            color: theme.primaryText,
            size: 30.0,
          ),
          onPressed: () {
            logFirebaseEvent('CONDITIONS_PAGE_close_rounded_ICN_ON_TAP');
            logFirebaseEvent('IconButton_navigate_back');
            context.pop();
          },
        ),
        title: Text(
          localizations.getText('z4scavsi'),
          style: theme.titleLarge.override(
            fontFamily: 'Google sans flex',
            color: theme.primaryText,
            letterSpacing: 0.0,
          ),
        ),
        centerTitle: false,
        elevation: 2.0,
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 32.0),
            child: MarkdownBody(
              data: terms,
              selectable: true,
              styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: theme.bodyMedium.override(
                  color: theme.primaryText,
                  letterSpacing: 0.0,
                  lineHeight: 1.5,
                ),
                h2: theme.titleLarge.override(
                  fontFamily: 'Google sans flex',
                  color: theme.primaryText,
                  letterSpacing: 0.0,
                ),
                listBullet: theme.bodyMedium.override(
                  color: theme.primaryText,
                  letterSpacing: 0.0,
                ),
                a: theme.bodyMedium.override(
                  color: theme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                  decoration: TextDecoration.underline,
                ),
                blockSpacing: 14.0,
                listIndent: 24.0,
              ),
              onTapLink: (_, url, __) {
                if (url != null) {
                  launchURL(url);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
