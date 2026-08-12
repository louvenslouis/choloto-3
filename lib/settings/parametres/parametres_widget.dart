import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/settings/language/language_widget.dart';
import '/services/push_notification_service.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'parametres_model.dart';
export 'parametres_model.dart';

class ParametresWidget extends StatefulWidget {
  const ParametresWidget({super.key});

  static String routeName = 'Parametres';
  static String routePath = '/parametres';

  @override
  State<ParametresWidget> createState() => _ParametresWidgetState();
}

class _ParametresWidgetState extends State<ParametresWidget> {
  late ParametresModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ParametresModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Parametres'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  String _subscriptionStatusText(DateTime expiration) {
    final localizations = FFLocalizations.of(context);
    if (expiration <= getCurrentTimestamp) {
      return localizations.getVariableText(
        frText: 'Votre abonnement est expiré',
        enText: 'Your subscription has expired',
        crText: 'Abònman ou ekspire',
      );
    }

    final formattedDate = dateTimeFormat(
      'yMMMd',
      expiration,
      locale: localizations.languageShortCode ?? localizations.languageCode,
    );
    return localizations.getVariableText(
      frText: 'Votre abonnement expire le $formattedDate',
      enText: 'Your subscription expires on $formattedDate',
      crText: 'Abònman ou ap ekspire $formattedDate',
    );
  }

  String? _notificationStatusText(PushNotificationStatus? status) {
    if (status == null) {
      return null;
    }
    final localizations = FFLocalizations.of(context);
    return switch (status) {
      PushNotificationStatus.unsupported => localizations.getVariableText(
          frText:
              'Ce navigateur ne prend pas en charge les notifications push.',
          enText: 'This browser does not support push notifications.',
          crText: 'Navigatè sa a pa sipòte notifikasyon push.',
        ),
      PushNotificationStatus.initializationFailed =>
        localizations.getVariableText(
          frText: 'Initialisation des notifications impossible.',
          enText: 'Notifications could not be initialized.',
          crText: 'Nou pa ka demare notifikasyon yo.',
        ),
      PushNotificationStatus.synchronizationFailed =>
        localizations.getVariableText(
          frText: 'Synchronisation des notifications impossible.',
          enText: 'Notifications could not be synchronized.',
          crText: 'Nou pa ka senkronize notifikasyon yo.',
        ),
      PushNotificationStatus.signInRequired => localizations.getVariableText(
          frText: 'Connectez-vous avant d’activer les notifications.',
          enText: 'Sign in before enabling notifications.',
          crText: 'Konekte anvan ou aktive notifikasyon yo.',
        ),
      PushNotificationStatus.permissionDenied => localizations.getVariableText(
          frText:
              'Autorisation refusée. Modifiez les réglages de votre navigateur.',
          enText:
              'Permission denied. Update your browser notification settings.',
          crText:
              'Otorizasyon refize. Modifye paramèt notifikasyon navigatè ou a.',
        ),
      PushNotificationStatus.enabled => localizations.getVariableText(
          frText: 'Notifications de prédictions activées.',
          enText: 'Prediction notifications enabled.',
          crText: 'Notifikasyon prediksyon yo aktive.',
        ),
      PushNotificationStatus.activationFailed => localizations.getVariableText(
          frText: 'Activation des notifications impossible.',
          enText: 'Notifications could not be enabled.',
          crText: 'Nou pa ka aktive notifikasyon yo.',
        ),
      PushNotificationStatus.disabled => localizations.getVariableText(
          frText: 'Notifications de prédictions désactivées.',
          enText: 'Prediction notifications disabled.',
          crText: 'Notifikasyon prediksyon yo dezaktive.',
        ),
      PushNotificationStatus.deactivationFailed =>
        localizations.getVariableText(
          frText: 'Désactivation des notifications impossible.',
          enText: 'Notifications could not be disabled.',
          crText: 'Nou pa ka dezaktive notifikasyon yo.',
        ),
    };
  }

  Future<void> _toggleWebNotifications(bool enable) async {
    final service = PushNotificationService.instance;
    if (enable) {
      await service.enable();
    } else {
      await service.disable();
    }

    if (!mounted) {
      return;
    }
    final message = _notificationStatusText(service.status);
    if (message == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: true,
          leading: FlutterFlowIconButton(
            borderRadius: 8.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back,
              color: FlutterFlowTheme.of(context).info,
              size: 24.0,
            ),
            onPressed: () async {
              logFirebaseEvent('PARAMETRES_PAGE_arrow_back_ICN_ON_TAP');
              logFirebaseEvent('IconButton_navigate_back');
              context.safePop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText(
              'oadu0jrq' /* Paramètres */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Google sans flex',
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 6.0, 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (loggedIn && currentUserDocument?.endSub != null)
                    Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 50.0,
                        decoration: BoxDecoration(),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              17.0, 0.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.exclamation,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24.0,
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      19.0, 0.0, 0.0, 0.0),
                                  child: AuthUserStreamWidget(
                                    builder: (context) => Text(
                                      _subscriptionStatusText(
                                        currentUserDocument!.endSub!,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (kIsWeb)
                    AnimatedBuilder(
                      animation: PushNotificationService.instance,
                      builder: (context, _) {
                        final service = PushNotificationService.instance;
                        final subtitle = service.busy
                            ? FFLocalizations.of(context).getVariableText(
                                frText: 'Mise à jour en cours…',
                                enText: 'Updating…',
                                crText: 'Mizajou ap fèt…',
                              )
                            : service.enabled
                                ? FFLocalizations.of(context).getVariableText(
                                    frText:
                                        'Vous serez alerté à chaque nouvelle prédiction.',
                                    enText:
                                        'You will be alerted for every new prediction.',
                                    crText:
                                        'W ap resevwa alèt pou chak nouvo prediksyon.',
                                  )
                                : _notificationStatusText(service.status) ??
                                    FFLocalizations.of(context).getVariableText(
                                      frText:
                                          'Activez les alertes dans ce navigateur.',
                                      enText: 'Enable alerts in this browser.',
                                      crText: 'Aktive alèt nan navigatè sa a.',
                                    );

                        return Material(
                          color: Colors.transparent,
                          child: SwitchListTile(
                            secondary: Icon(
                              Icons.notifications_active_outlined,
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                            title: Text(
                              FFLocalizations.of(context).getVariableText(
                                frText: 'Nouvelles prédictions',
                                enText: 'New predictions',
                                crText: 'Nouvo prediksyon',
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    fontFamily: 'Google sans flex',
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            subtitle: Text(
                              subtitle,
                              style: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            value: service.enabled,
                            onChanged: service.supported && !service.busy
                                ? _toggleWebNotifications
                                : null,
                            tileColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            contentPadding:
                                const EdgeInsetsDirectional.fromSTEB(
                              12.0,
                              0.0,
                              12.0,
                              0.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        );
                      },
                    ),
                  if (currentUserEmail != null && currentUserEmail != '')
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        logFirebaseEvent(
                            'PARAMETRES_PAGE_ListTile_3v5e333s_ON_TAP');
                        logFirebaseEvent('ListTile_navigate_to');

                        context.pushNamed(ProfilWidget.routeName);
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: Icon(
                            Icons.person_outlined,
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                          title: Text(
                            FFLocalizations.of(context).getText(
                              'ey6ffs78' /* Profil */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: 'Google sans flex',
                                  letterSpacing: 0.0,
                                ),
                          ),
                          subtitle: Text(
                            currentUserEmail,
                            style: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).alternate,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                          ),
                          trailing: Icon(
                            Icons.create_outlined,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24.0,
                          ),
                          tileColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          dense: false,
                          contentPadding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  if (loggedIn)
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        logFirebaseEvent(
                            'PARAMETRES_PAGE_ListTile_b68hxm1x_ON_TAP');
                        logFirebaseEvent('ListTile_navigate_to');

                        context.pushNamed(UpgradeWidget.routeName);
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: FaIcon(
                            FontAwesomeIcons.award,
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                          title: Text(
                            FFLocalizations.of(context).getText(
                              'eywbwq85' /* Abonnement */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: 'Google sans flex',
                                  letterSpacing: 0.0,
                                ),
                          ),
                          trailing: Icon(
                            Icons.arrow_right_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24.0,
                          ),
                          tileColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          dense: false,
                          contentPadding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  if (loggedIn)
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        logFirebaseEvent(
                            'PARAMETRES_PAGE_ListTile_5rdkedy2_ON_TAP');
                        logFirebaseEvent('ListTile_navigate_to');

                        context.pushNamed(
                          ConditionsWidget.routeName,
                          extra: <String, dynamic>{
                            '__transition_info__': TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.topToBottom,
                            ),
                          },
                        );
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: Icon(
                            Icons.gpp_bad,
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                          title: Text(
                            FFLocalizations.of(context).getText(
                              '6ho9r1de' /* Termes et Conditions */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: 'Google sans flex',
                                  letterSpacing: 0.0,
                                ),
                          ),
                          trailing: Icon(
                            Icons.arrow_right_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24.0,
                          ),
                          tileColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          dense: false,
                          contentPadding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      logFirebaseEvent(
                          'PARAMETRES_PAGE_ListTile_qwoflxy8_ON_TAP');
                      logFirebaseEvent('ListTile_navigate_to');

                      context.pushNamed(CustomerserviceWidget.routeName);
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: Icon(
                          Icons.contact_support,
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                        title: Text(
                          FFLocalizations.of(context).getText(
                            'i3ozq7ax' /* Nous contacter */,
                          ),
                          style:
                              FlutterFlowTheme.of(context).titleLarge.override(
                                    fontFamily: 'Google sans flex',
                                    letterSpacing: 0.0,
                                  ),
                        ),
                        tileColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        dense: false,
                        contentPadding: EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      logFirebaseEvent(
                          'PARAMETRES_PAGE_ListTile_ne6zmaae_ON_TAP');
                      logFirebaseEvent('ListTile_bottom_sheet');
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) => Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: LanguageWidget(),
                        ),
                      );
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: Icon(
                          Icons.language,
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                        title: Text(
                          FFLocalizations.of(context).getText(
                            '9w72tojm' /* Langue */,
                          ),
                          style:
                              FlutterFlowTheme.of(context).titleLarge.override(
                                    fontFamily: 'Google sans flex',
                                    letterSpacing: 0.0,
                                  ),
                        ),
                        trailing: Icon(
                          Icons.create_outlined,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 24.0,
                        ),
                        tileColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        dense: false,
                        contentPadding: EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      secondary: Icon(
                        Icons.light_mode_outlined,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                      title: Text(
                        FFLocalizations.of(context).getVariableText(
                          frText: 'Thème clair',
                          enText: 'Light theme',
                          crText: 'Tèm klè',
                        ),
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              fontFamily: 'Google sans flex',
                              letterSpacing: 0.0,
                            ),
                      ),
                      value: Theme.of(context).brightness == Brightness.light,
                      onChanged: (enabled) => setDarkModeSetting(
                        context,
                        enabled ? ThemeMode.light : ThemeMode.dark,
                      ),
                      activeThumbColor: FlutterFlowTheme.of(context).primary,
                      tileColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      contentPadding: const EdgeInsetsDirectional.fromSTEB(
                        12.0,
                        0.0,
                        12.0,
                        0.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: Icon(
                        Icons.code,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                      title: Text(
                        FFLocalizations.of(context).getText(
                          '3vvyx19f' /* Version */,
                        ),
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              fontFamily: 'Google sans flex',
                              letterSpacing: 0.0,
                            ),
                      ),
                      subtitle: Text(
                        FFLocalizations.of(context).getText(
                          'cp8c72u7' /* 260715001 */,
                        ),
                        style:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).alternate,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                      ),
                      tileColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      dense: false,
                      contentPadding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  if (loggedIn)
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        logFirebaseEvent(
                            'PARAMETRES_PAGE_ListTile_dk7j98yf_ON_TAP');
                        logFirebaseEvent('ListTile_auth');
                        GoRouter.of(context).prepareAuthEvent();
                        await authManager.signOut();
                        GoRouter.of(context).clearRedirectLocation();

                        context.goNamedAuth(
                            AuthentificationWidget.routeName, context.mounted);
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: FaIcon(
                            FontAwesomeIcons.signOutAlt,
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                          title: Text(
                            FFLocalizations.of(context).getText(
                              '7yrcsutm' /* Se déconnecter */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: 'Google sans flex',
                                  letterSpacing: 0.0,
                                ),
                          ),
                          tileColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          dense: false,
                          contentPadding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  if (!loggedIn)
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        logFirebaseEvent(
                            'PARAMETRES_PAGE_ListTile_6g44pgqo_ON_TAP');
                        logFirebaseEvent('ListTile_navigate_to');

                        context.goNamed(
                          AuthentificationWidget.routeName,
                          extra: <String, dynamic>{
                            '__transition_info__': TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.bottomToTop,
                            ),
                          },
                        );
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: FaIcon(
                            FontAwesomeIcons.signOutAlt,
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                          title: Text(
                            FFLocalizations.of(context).getText(
                              'f9ixk3ux' /* Se connecter */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: 'Google sans flex',
                                  letterSpacing: 0.0,
                                ),
                          ),
                          tileColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          dense: false,
                          contentPadding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 32.0),
                    child: Container(
                      child: Container(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          FFLocalizations.of(context).getText(
                            'z4f6qhpj' /* Développeur : LOUVENS LOUIS */,
                          ),
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .fontStyle,
                              ),
                        ),
                      ),
                    ),
                  ),
                ]
                    .divide(SizedBox(height: 8.0))
                    .addToStart(SizedBox(height: 15.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
