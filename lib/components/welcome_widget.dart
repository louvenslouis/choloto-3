import '/auth/firebase_auth/auth_util.dart';
import '/auth/email_address.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'dart:ui' show ImageFilter;
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
    final userId = user?.uid;
    if (userId == null || userId.isEmpty) {
      return;
    }

    final userReference = UserRecord.collection.doc(userId);

    try {
      final userDocument = await UserRecord.getDocumentOnce(userReference);
      currentUserDocument = userDocument;

      if (userDocument.onboardingPending) {
        if (mounted) {
          context.goNamedAuth(RegistrationCompletionWidget.routeName, true);
        }
        return;
      }

      if (userDocument.endSub == null) {
        logFirebaseEvent('Button_backend_call');
        await userReference.update({
          ...mapToFirestore(
            {'end_sub': FieldValue.serverTimestamp()},
          ),
        });
      }

      logFirebaseEvent('Button_backend_call');
      await userReference.update(
        mapToFirestore({'device': _currentDeviceName()}),
      );

      if (mounted) {
        context.goNamedAuth(HomeWidget.routeName, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                FFLocalizations.of(context).getText('registration_save_error'),
              ),
            ),
          );
      }
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final useSplitLayout = constraints.maxWidth >= 900.0 ||
            constraints.maxWidth > constraints.maxHeight * 1.25;
        if (useSplitLayout) {
          return _buildSplitLayout(
            context,
            constraints: constraints,
            theme: theme,
          );
        }
        return _buildPortraitLayout(
          context,
          constraints: constraints,
          theme: theme,
        );
      },
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context, {
    required BoxConstraints constraints,
    required FlutterFlowTheme theme,
  }) {
    final tokens = theme.designToken;
    final actionsHeight = constraints.maxHeight < 640.0
        ? 248.0
        : constraints.maxHeight < 760.0
            ? 264.0
            : 288.0;

    return ColoredBox(
      color: theme.primaryBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540.0),
          child: SizedBox(
            width: double.infinity,
            height: constraints.maxHeight,
            child: Column(
              children: [
                Expanded(
                  child: _OnboardingHero(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(tokens.radius.lg),
                      bottomRight: Radius.circular(tokens.radius.lg),
                    ),
                  ),
                ),
                SizedBox(
                  height: actionsHeight,
                  child: _buildOnboardingActions(
                    context,
                    theme: theme,
                    horizontalPadding: tokens.spacing.lg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitLayout(
    BuildContext context, {
    required BoxConstraints constraints,
    required FlutterFlowTheme theme,
  }) {
    final tokens = theme.designToken;
    final outerPadding =
        constraints.maxHeight < 600.0 ? tokens.spacing.sm : tokens.spacing.xl;
    final availableHeight = constraints.maxHeight - (outerPadding * 2);
    final panelHeight = availableHeight > 820.0
        ? 820.0
        : availableHeight < 0.0
            ? 0.0
            : availableHeight;

    return ColoredBox(
      color: theme.primaryBackground,
      child: Padding(
        padding: EdgeInsets.all(outerPadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180.0),
            child: SizedBox(
              width: double.infinity,
              height: panelHeight,
              child: Container(
                key: const ValueKey('onboarding-wide-panel'),
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
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(tokens.radius.lg),
                          bottomLeft: Radius.circular(tokens.radius.lg),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: _buildOnboardingActions(
                        context,
                        theme: theme,
                        horizontalPadding: constraints.maxHeight < 600.0
                            ? tokens.spacing.md
                            : tokens.spacing.xl,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingActions(
    BuildContext context, {
    required FlutterFlowTheme theme,
    required double horizontalPadding,
  }) {
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);
    final supportingTextColor = theme.primaryText.withValues(alpha: 0.72);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 360.0;
        final buttonHeight = compact ? 48.0 : 56.0;
        final guestButtonHeight = compact ? 44.0 : 48.0;
        final verticalPadding = compact ? tokens.spacing.sm : tokens.spacing.lg;

        return Padding(
          key: const ValueKey('onboarding-content'),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    localizations.getText('onboarding_continue_title'),
                    maxLines: 1,
                    style: (compact ? theme.titleSmall : theme.titleMedium)
                        .copyWith(color: theme.primaryText),
                  ),
                ),
              ),
              SizedBox(
                height: compact ? tokens.spacing.sm : tokens.spacing.md,
              ),
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
                  height: buttonHeight,
                  padding: EdgeInsets.zero,
                  iconPadding:
                      EdgeInsetsDirectional.only(end: tokens.spacing.sm),
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
                  height: buttonHeight,
                  padding: EdgeInsets.zero,
                  iconPadding:
                      EdgeInsetsDirectional.only(end: tokens.spacing.sm),
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
              SizedBox(height: compact ? tokens.spacing.xs : tokens.spacing.sm),
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
                  height: guestButtonHeight,
                  padding: EdgeInsets.zero,
                  iconPadding:
                      EdgeInsetsDirectional.only(end: tokens.spacing.sm),
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
              SizedBox(height: compact ? tokens.spacing.xs : tokens.spacing.md),
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
      },
    );
  }
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({required this.borderRadius});

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);

    return ClipRRect(
      borderRadius: borderRadius,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxHeight < 380.0 || constraints.maxWidth < 360.0;
          final generous =
              constraints.maxHeight >= 600.0 && constraints.maxWidth >= 500.0;
          final contentPadding =
              compact ? tokens.spacing.md : tokens.spacing.lg;
          final logoSize = compact ? 56.0 : 72.0;
          final titleStyle = generous
              ? theme.headlineLarge
              : compact
                  ? theme.headlineSmall
                  : theme.headlineMedium;

          return SizedBox.expand(
            key: const ValueKey('onboarding-hero'),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/choloto_onboarding_hero.png',
                  fit: BoxFit.cover,
                  alignment: compact
                      ? const Alignment(0.0, 0.20)
                      : const Alignment(0.0, -0.12),
                  excludeFromSemantics: true,
                ),
                PositionedDirectional(
                  top: contentPadding,
                  start: contentPadding,
                  child: Semantics(
                    label: localizations.getText('onboarding_logo_label'),
                    image: true,
                    child: Container(
                      width: logoSize,
                      height: logoSize,
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
                PositionedDirectional(
                  start: 0.0,
                  end: 0.0,
                  bottom: 0.0,
                  child: ClipRect(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ShaderMask(
                            key: const ValueKey(
                              'onboarding-blur-opacity-mask',
                            ),
                            blendMode: BlendMode.dstIn,
                            shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.onPrimary.withValues(alpha: 0.0),
                                theme.onPrimary.withValues(alpha: 0.72),
                                theme.onPrimary,
                              ],
                              stops: const [0.0, 0.34, 0.62],
                            ).createShader(bounds),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: compact ? 8.0 : 12.0,
                                sigmaY: compact ? 8.0 : 12.0,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                        Container(
                          key: const ValueKey('onboarding-copy-overlay'),
                          padding: EdgeInsets.fromLTRB(
                            contentPadding,
                            compact ? tokens.spacing.lg : tokens.spacing.xl,
                            contentPadding,
                            contentPadding,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.onPrimary.withValues(alpha: 0.0),
                                theme.onPrimary.withValues(
                                  alpha: compact ? 0.54 : 0.66,
                                ),
                                theme.onPrimary.withValues(
                                  alpha: compact ? 0.86 : 0.92,
                                ),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: tokens.spacing.sm,
                                  vertical: tokens.spacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primary,
                                  borderRadius: BorderRadius.circular(
                                    tokens.radius.full,
                                  ),
                                ),
                                child: Text(
                                  localizations.getText('onboarding_eyebrow'),
                                  style: theme.labelSmall.copyWith(
                                    color: theme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(height: tokens.spacing.sm),
                              Text(
                                localizations.getText('onboarding_title'),
                                key: const ValueKey('onboarding-title'),
                                style: titleStyle.copyWith(
                                  color: theme.onDecorative,
                                  height: 1.05,
                                ),
                              ),
                              SizedBox(height: tokens.spacing.xs),
                              Text(
                                localizations.getText('onboarding_description'),
                                maxLines: compact ? 3 : 4,
                                overflow: TextOverflow.ellipsis,
                                style: (compact
                                        ? theme.bodySmall
                                        : theme.bodyMedium)
                                    .copyWith(
                                  color: theme.onDecorative
                                      .withValues(alpha: 0.82),
                                  height: 1.30,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
