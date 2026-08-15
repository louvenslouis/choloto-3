import '/auth/firebase_auth/auth_util.dart';
import '/auth/email_address.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'email_auth_sheet.dart';
import 'welcome_model.dart';
export 'welcome_model.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  late WelcomeModel _model;

  Future<void> _completeAuthenticatedSignIn(BaseAuthUser? user) async {
    if (user == null) {
      return;
    }

    final userReference = currentUserReference;
    if (userReference == null) {
      return;
    }

    if (currentUserDocument?.endSub == null) {
      logFirebaseEvent('Button_backend_call');
      await userReference.update({
        ...mapToFirestore(
          {'end_sub': FieldValue.serverTimestamp()},
        ),
      });
    }

    logFirebaseEvent('Button_backend_call');
    await userReference.update(
      createUserRecordData(device: _currentDeviceName()),
    );

    if (mounted) {
      context.goNamedAuth(HomeWidget.routeName, true);
    }
  }

  String _currentDeviceName() {
    if (isAndroid) {
      return 'Android';
    }
    if (isiOS) {
      return 'IOS';
    }
    if (isWeb) {
      return 'Web';
    }
    return '';
  }

  Future<void> _signInWithGoogle() async {
    GoRouter.of(context).prepareAuthEvent();
    final user = await authManager.signInWithGoogle(context);
    if (user == null && mounted) {
      GoRouter.of(context).appState.updateNotifyOnAuthChange(true);
      return;
    }
    await _completeAuthenticatedSignIn(user);
  }

  Future<void> _signInWithEmail() async {
    GoRouter.of(context).prepareAuthEvent();
    final user = await showModalBottomSheet<BaseAuthUser>(
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (sheetContext) => Padding(
        padding: MediaQuery.viewInsetsOf(sheetContext),
        child: EmailAuthSheet(
          onSignIn: (email, password) => authManager.signInWithEmail(
            sheetContext,
            email,
            password,
          ),
          onCreateAccount: (email, password) =>
              authManager.createAccountWithEmail(
            sheetContext,
            email,
            password,
          ),
          onResetPassword: (email) async {
            await authManager.resetPassword(
              email: email,
              context: sheetContext,
            );
          },
        ),
      ),
    );
    if (user == null && mounted) {
      GoRouter.of(context).appState.updateNotifyOnAuthChange(true);
      return;
    }
    await _completeAuthenticatedSignIn(user);
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WelcomeModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900.0;
        if (isWide) {
          return _buildWideLayout(
            context,
            constraints: constraints,
            theme: theme,
          );
        }
        return ColoredBox(
          color: theme.primaryBackground,
          child: Center(
            child: SingleChildScrollView(
              key: const ValueKey('onboarding-scroll'),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _OnboardingHero(
                      height: constraints.maxWidth < 360.0 ? 280.0 : 320.0,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(tokens.radius.lg),
                        bottomRight: Radius.circular(tokens.radius.lg),
                      ),
                    ),
                    _buildOnboardingContent(
                      context,
                      theme: theme,
                      horizontalPadding: tokens.spacing.lg,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(
    BuildContext context, {
    required BoxConstraints constraints,
    required FlutterFlowTheme theme,
  }) {
    final tokens = theme.designToken;
    final availableHeight = constraints.maxHeight - (tokens.spacing.xl * 2);
    final panelHeight = availableHeight < 620.0
        ? 620.0
        : availableHeight > 820.0
            ? 820.0
            : availableHeight;

    return ColoredBox(
      color: theme.primaryBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing.xl),
        child: Center(
          child: Container(
            key: const ValueKey('onboarding-wide-panel'),
            width: double.infinity,
            height: panelHeight,
            constraints: const BoxConstraints(maxWidth: 1180.0),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              boxShadow: [tokens.shadow.xl],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 6,
                  child: _OnboardingHero(
                    height: panelHeight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(tokens.radius.lg),
                      bottomLeft: Radius.circular(tokens.radius.lg),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      vertical: tokens.spacing.xl,
                    ),
                    child: _buildOnboardingContent(
                      context,
                      theme: theme,
                      horizontalPadding: tokens.spacing.xl,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingContent(
    BuildContext context, {
    required FlutterFlowTheme theme,
    required double horizontalPadding,
  }) {
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);
    final supportingTextColor = theme.primaryText.withValues(alpha: 0.72);

    return Padding(
      key: const ValueKey('onboarding-content'),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        tokens.spacing.xl,
        horizontalPadding,
        tokens.spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.md,
              vertical: tokens.spacing.sm,
            ),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(tokens.radius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 18.0,
                  color: theme.primary,
                ),
                SizedBox(width: tokens.spacing.sm),
                Flexible(
                  child: Text(
                    localizations.getText('onboarding_eyebrow'),
                    style: theme.labelMedium.copyWith(
                      color: theme.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            localizations.getText('onboarding_title'),
            key: const ValueKey('onboarding-title'),
            style: theme.headlineLarge.copyWith(
              color: theme.primaryText,
              height: 1.08,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            localizations.getText('onboarding_description'),
            style: theme.bodyLarge.copyWith(
              color: supportingTextColor,
              height: 1.45,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          Wrap(
            spacing: tokens.spacing.sm,
            runSpacing: tokens.spacing.sm,
            children: [
              _FeaturePill(
                icon: Icons.bolt_rounded,
                label: localizations.getText('onboarding_feature_results'),
              ),
              _FeaturePill(
                icon: Icons.grid_view_rounded,
                label: localizations.getText('onboarding_feature_tchala'),
              ),
              _FeaturePill(
                icon: Icons.workspace_premium_rounded,
                label: localizations.getText('onboarding_feature_vip'),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.lg),
          Divider(
            height: 1.0,
            color: theme.alternate.withValues(alpha: 0.35),
          ),
          SizedBox(height: tokens.spacing.lg),
          Text(
            localizations.getText('onboarding_continue_title'),
            style: theme.titleSmall.copyWith(color: theme.primaryText),
          ),
          SizedBox(height: tokens.spacing.md),
          FFButtonWidget(
            key: const ValueKey('onboarding-google-button'),
            onPressed: () async {
              logFirebaseEvent('WELCOME_CONTINUER_AVEC_GOOGLE_BTN_ON_TAP');
              logFirebaseEvent('Button_auth');
              await _signInWithGoogle();
            },
            text: localizations.getText('ser0033p'),
            icon: FaIcon(
              FontAwesomeIcons.google,
              size: 21.0,
              color: theme.onPrimary,
            ),
            options: FFButtonOptions(
              width: double.infinity,
              height: 56.0,
              padding: EdgeInsets.zero,
              iconPadding: EdgeInsetsDirectional.only(end: tokens.spacing.sm),
              iconColor: theme.onPrimary,
              color: theme.primary,
              textStyle: theme.titleSmall.copyWith(
                color: theme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
              elevation: 0.0,
              borderSide: BorderSide(color: theme.primary),
              borderRadius: BorderRadius.circular(tokens.radius.full),
              hoverColor: theme.warning,
              hoverTextColor: theme.onPrimary,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          FFButtonWidget(
            key: const ValueKey('onboarding-email-button'),
            onPressed: () async {
              logFirebaseEvent(emailAuthButtonAnalyticsEvent);
              await _signInWithEmail();
            },
            text: localizations.getText('email_continue'),
            icon: Icon(
              Icons.email_outlined,
              size: 21.0,
              color: theme.primaryText,
            ),
            options: FFButtonOptions(
              width: double.infinity,
              height: 56.0,
              padding: EdgeInsets.zero,
              iconPadding: EdgeInsetsDirectional.only(end: tokens.spacing.sm),
              iconColor: theme.primaryText,
              color: theme.secondaryBackground,
              textStyle: theme.titleSmall.copyWith(
                color: theme.primaryText,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0.0,
              borderSide: BorderSide(
                color: theme.alternate.withValues(alpha: 0.45),
              ),
              borderRadius: BorderRadius.circular(tokens.radius.full),
              hoverColor: theme.primary.withValues(alpha: 0.10),
              hoverTextColor: theme.primaryText,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          FFButtonWidget(
            key: const ValueKey('onboarding-guest-button'),
            onPressed: () async {
              logFirebaseEvent('WELCOME_CONNECTER_EN_TANT_QU_INVITER_BTN');
              logFirebaseEvent('Button_navigate_to');
              context.pushNamed(HomeWidget.routeName);
            },
            text: localizations.getText('7p5qctmz'),
            icon: Icon(
              Icons.person_outline_rounded,
              size: 21.0,
              color: supportingTextColor,
            ),
            options: FFButtonOptions(
              width: double.infinity,
              height: 48.0,
              padding: EdgeInsets.zero,
              iconPadding: EdgeInsetsDirectional.only(end: tokens.spacing.sm),
              iconColor: supportingTextColor,
              color: theme.primaryBackground.withValues(alpha: 0.0),
              textStyle: theme.labelLarge.copyWith(
                color: supportingTextColor,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(tokens.radius.full),
              hoverColor: theme.primary.withValues(alpha: 0.10),
              hoverTextColor: theme.primaryText,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          Align(
            alignment: Alignment.center,
            child: Text(
              localizations.getText('3vjw7hwm'),
              style: theme.labelSmall.copyWith(
                color: theme.primaryText.withValues(alpha: 0.56),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({
    required this.height,
    required this.borderRadius,
  });

  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        key: const ValueKey('onboarding-hero'),
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/choloto_onboarding_hero.png',
              fit: BoxFit.cover,
              alignment: const Alignment(0.0, -0.12),
              excludeFromSemantics: true,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.primaryBackground.withValues(alpha: 0.0),
                    theme.primaryBackground.withValues(alpha: 0.08),
                    theme.primaryBackground.withValues(alpha: 0.72),
                  ],
                  stops: const [0.45, 0.72, 1.0],
                ),
              ),
            ),
            PositionedDirectional(
              top: tokens.spacing.lg,
              start: tokens.spacing.lg,
              child: Semantics(
                label: FFLocalizations.of(context)
                    .getText('onboarding_logo_label'),
                image: true,
                child: Container(
                  width: 72.0,
                  height: 72.0,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(tokens.radius.md),
                    boxShadow: [tokens.shadow.lg],
                  ),
                  child: Image.asset(
                    'assets/images/Logo_Choloto_509.png',
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(tokens.radius.full),
        border: Border.all(
          color: theme.alternate.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.0, color: theme.primary),
          SizedBox(width: tokens.spacing.xs),
          Text(
            label,
            style: theme.labelSmall.copyWith(
              color: theme.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
