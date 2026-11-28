import '/components/page_header_app_bar.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/settings/language/language_widget.dart';
import '/services/push_notification_service.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import '/settings/device_preferences.dart';
import 'settings_choice_sheet.dart';
import 'settings_tile.dart';
import 'member_notification_settings.dart';
import '/settings/profil/profile_contact_fields.dart';
import 'parametres_model.dart';
import 'subscription_settings_tile.dart';
export 'parametres_model.dart';

class ParametresWidget extends StatefulWidget {
  const ParametresWidget({super.key});

  static String routeName = 'Parametres';
  static String routePath = '/parametres';

  @override
  State<ParametresWidget> createState() => _ParametresWidgetState();
}

class _ParametresWidgetState extends State<ParametresWidget> {
  static const _maxContentWidth = 1040.0;
  late ParametresModel _model;
  late Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ParametresModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Parametres'});
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
      PushNotificationStatus.permissionDenied => localizations.getVariableText(
          frText:
              'Autorisation refusée. Modifiez les réglages de votre navigateur.',
          enText:
              'Permission denied. Update your browser notification settings.',
          crText:
              'Otorizasyon refize. Modifye paramèt notifikasyon navigatè ou a.',
        ),
      PushNotificationStatus.enabled => localizations.getVariableText(
          frText: 'Notifications activées.',
          enText: 'Notifications enabled.',
          crText: 'Notifikasyon yo aktive.',
        ),
      PushNotificationStatus.activationFailed => localizations.getVariableText(
          frText: 'Activation des notifications impossible.',
          enText: 'Notifications could not be enabled.',
          crText: 'Nou pa ka aktive notifikasyon yo.',
        ),
      PushNotificationStatus.disabled => localizations.getVariableText(
          frText: 'Notifications désactivées.',
          enText: 'Notifications disabled.',
          crText: 'Notifikasyon yo dezaktive.',
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

  Future<void> _choose<T>({
    required String title,
    required Map<T, String> options,
    required T selected,
    required Future<void> Function(T) save,
  }) async {
    final value = await showModalBottomSheet<T>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      builder: (sheetContext) => SettingsChoiceSheet<T>(
        title: title,
        options: options,
        selected: selected,
        onSelected: (value) => Navigator.pop(sheetContext, value),
      ),
    );
    if (value == null || value == selected) return;
    try {
      await save(value);
    } catch (_) {
      if (mounted) _showMessage('settings_save_error');
    }
  }

  void _showMessage(String key) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(FFLocalizations.of(context).getText(key))),
    );
  }

  Future<void> _copyVersion(String version) async {
    try {
      await Clipboard.setData(ClipboardData(text: version));
      if (mounted) _showMessage('settings_version_copied');
    } catch (_) {
      if (mounted) _showMessage('settings_copy_error');
    }
  }

  Future<void> _sessionAction() async {
    if (loggedIn) {
      logFirebaseEvent('PARAMETRES_PAGE_ListTile_dk7j98yf_ON_TAP');
      logFirebaseEvent('ListTile_auth');
      GoRouter.of(context).prepareAuthEvent();
      await authManager.signOut();
      if (!mounted) return;
      GoRouter.of(context).clearRedirectLocation();
      context.goNamedAuth(AuthentificationWidget.routeName, context.mounted);
    } else {
      logFirebaseEvent('PARAMETRES_PAGE_ListTile_6g44pgqo_ON_TAP');
      logFirebaseEvent('ListTile_navigate_to');
      context.goNamed(AuthentificationWidget.routeName, extra: {
        '__transition_info__': const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.bottomToTop,
        ),
      });
    }
  }

  Widget _webNotifications() => AnimatedBuilder(
        animation: PushNotificationService.instance,
        builder: (context, _) {
          final theme = FlutterFlowTheme.of(context);
          final strings = FFLocalizations.of(context);
          final service = PushNotificationService.instance;
          final subtitle = service.busy
              ? strings.getVariableText(
                  frText: 'Mise à jour en cours…',
                  enText: 'Updating…',
                  crText: 'Mizajou ap fèt…')
              : _notificationStatusText(service.status);
          return SwitchListTile(
            activeThumbColor: theme.primary,
            activeTrackColor: theme.primary.withValues(alpha: 0.45),
            secondary:
                Icon(Icons.notifications_active_outlined, color: theme.primary),
            title: Text(
                strings.getText(
                    hasFirebaseSession ? 'push_browser' : 'push_browser_bingo'),
                style: theme.titleMedium),
            subtitle: subtitle == null
                ? null
                : Text(subtitle,
                    style: theme.bodyMedium
                        .copyWith(color: theme.designToken.home.mutedText)),
            value: service.enabled,
            onChanged: service.supported && !service.busy
                ? _toggleWebNotifications
                : null,
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final strings = FFLocalizations.of(context);
    final t = strings.getText;
    final spacing = theme.designToken.spacing;
    final device = FFAppState().devicePreferences;

    final preferences = ListenableBuilder(
      listenable: device,
      builder: (context, _) {
        final markets = {
          HomeDrawMarket.ny: t('home_draw_new_york'),
          HomeDrawMarket.fl: t('home_draw_florida')
        };
        final sizes = {
          ReadingSize.system: t('settings_system'),
          ReadingSize.large: t('settings_large'),
          ReadingSize.extraLarge: t('settings_extra_large')
        };
        final motion = {
          false: t('settings_system'),
          true: t('settings_reduced')
        };
        return _SettingsSection(title: t('settings_preferences'), rows: [
          SettingsTile(
            icon: Icons.language_rounded,
            title: t('9w72tojm'),
            detail: t(LanguageWidget.names[strings.languageCode]!),
            onTap: () {
              logFirebaseEvent('PARAMETRES_PAGE_ListTile_ne6zmaae_ON_TAP');
              logFirebaseEvent('ListTile_bottom_sheet');
              showModalBottomSheet<void>(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                backgroundColor: theme.secondaryBackground,
                builder: (_) => const LanguageWidget(),
              );
            },
          ),
          SettingsTile(
            icon: Icons.confirmation_number_outlined,
            title: t('settings_market'),
            detail: markets[device.market],
            onTap: () => _choose(
                title: t('settings_market'),
                options: markets,
                selected: device.market,
                save: device.setMarket),
          ),
          SettingsTile(
            icon: Icons.format_size_rounded,
            title: t('settings_size'),
            detail: sizes[device.size],
            onTap: () => _choose(
                title: t('settings_size'),
                options: sizes,
                selected: device.size,
                save: device.setSize),
          ),
          SettingsTile(
            icon: Icons.motion_photos_on_outlined,
            title: t('settings_motion'),
            detail: motion[device.reduceMotion],
            onTap: () => _choose(
                title: t('settings_motion'),
                options: motion,
                selected: device.reduceMotion,
                save: device.setReduceMotion),
          ),
          if (kIsWeb) _webNotifications(),
        ]);
      },
    );

    final session = SettingsTile(
      icon: loggedIn ? Icons.logout_rounded : Icons.login_rounded,
      title: t(loggedIn ? '7yrcsutm' : 'f9ixk3ux'),
      onTap: _sessionAction,
    );
    final account = loggedIn
        ? AuthUserStreamWidget(builder: (context) {
            final record = currentUserDocument;
            final owner =
                record != null && record.reference.id == currentUserUid
                    ? record
                    : null;
            final email = owner?.email ?? currentUser?.email ?? '';
            return _SettingsSection(title: t('settings_account'), rows: [
              SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: t('ey6ffs78'),
                  detail: email.isEmpty ? null : email,
                  onTap: () {
                    logFirebaseEvent(
                        'PARAMETRES_PAGE_ListTile_3v5e333s_ON_TAP');
                    logFirebaseEvent('ListTile_navigate_to');
                    context.pushNamed(ProfilWidget.routeName);
                  }),
              ProfileContactFields(profile: owner),
              MemberNotificationSettings(profile: owner),
              SubscriptionSettingsTile(
                  expiration: owner?.endSub,
                  onTap: () {
                    logFirebaseEvent(
                        'PARAMETRES_PAGE_ListTile_b68hxm1x_ON_TAP');
                    logFirebaseEvent('ListTile_navigate_to');
                    context.pushNamed(UpgradeWidget.routeName);
                  }),
              session,
            ]);
          })
        : _SettingsSection(title: t('settings_account'), rows: [session]);
    final help = _SettingsSection(title: t('settings_help'), rows: [
      SettingsTile(
          icon: Icons.support_agent_rounded,
          title: t('i3ozq7ax'),
          onTap: () {
            logFirebaseEvent('PARAMETRES_PAGE_ListTile_qwoflxy8_ON_TAP');
            logFirebaseEvent('ListTile_navigate_to');
            context.pushNamed(CustomerserviceWidget.routeName);
          }),
      SettingsTile(
          icon: Icons.description_outlined,
          title: t('6ho9r1de'),
          onTap: () {
            logFirebaseEvent('PARAMETRES_PAGE_ListTile_5rdkedy2_ON_TAP');
            logFirebaseEvent('ListTile_navigate_to');
            context.pushNamed(ConditionsWidget.routeName, extra: {
              '__transition_info__': const TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.topToBottom),
            });
          }),
      FutureBuilder<PackageInfo>(
        future: _packageInfo,
        builder: (context, snapshot) {
          final info = snapshot.data;
          if (info == null || info.version.isEmpty) {
            final pending = snapshot.connectionState != ConnectionState.done;
            return SettingsTile(
                icon: Icons.info_outline_rounded,
                title: t('3vvyx19f'),
                detail: pending
                    ? null
                    : t(snapshot.hasError
                        ? 'ach_retry'
                        : 'settings_unavailable'),
                actionIcon: Icons.refresh_rounded,
                onTap: !snapshot.hasError
                    ? null
                    : () => setState(
                        () => _packageInfo = PackageInfo.fromPlatform()));
          }
          final version = info.buildNumber.isEmpty
              ? info.version
              : '${info.version} (${info.buildNumber})';
          return Semantics(
              hint: MaterialLocalizations.of(context).copyButtonLabel,
              child: SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: t('3vvyx19f'),
                  detail: version,
                  actionIcon: Icons.copy_rounded,
                  onTap: () => _copyVersion(version)));
        },
      ),
    ]);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: PageHeaderAppBar(
        automaticallyImplyLeading: false,
        title: Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Row(children: [
            BackButton(onPressed: () => context.safePop()),
            SizedBox(width: spacing.sm),
            Expanded(child: Text(t('oadu0jrq'), style: theme.headlineMedium)),
          ]),
        )),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.md),
          child: Center(
              child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: LayoutBuilder(builder: (_, bounds) {
              final wide = bounds.maxWidth >=
                  720 * MediaQuery.textScalerOf(context).scale(16) / 16;
              final other = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    account,
                    SizedBox(height: spacing.lg),
                    help,
                  ]);
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (wide)
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: preferences),
                            SizedBox(width: spacing.lg),
                            Expanded(child: other),
                          ])
                    else ...[preferences, SizedBox(height: spacing.lg), other],
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: spacing.lg),
                        child: Text(t('z4f6qhpj'),
                            textAlign: TextAlign.center,
                            style: theme.bodySmall
                                .copyWith(color: theme.secondaryText))),
                  ]);
            }),
          )),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.rows});
  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Semantics(header: true, child: Text(title, style: theme.titleLarge)),
      SizedBox(height: tokens.spacing.sm),
      Material(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        clipBehavior: Clip.antiAlias,
        child: Ink(
            decoration: tokens.home.panel,
            child: Column(children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                      height: 1,
                      color: tokens.home.panelEdge,
                      indent: tokens.spacing.md,
                      endIndent: tokens.spacing.md),
                rows[i],
              ],
            ])),
      ),
    ]);
  }
}
