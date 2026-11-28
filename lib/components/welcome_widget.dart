import '/auth/firebase_auth/auth_util.dart';
import '/auth/email_address.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'home_feature_card.dart';
import 'home_header_actions.dart';
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

    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final localizations = FFLocalizations.of(context);
    final supportingTextColor = tokens.home.mutedText;
    final textScale = MediaQuery.textScalerOf(context);
    final buttonHeight =
        52.0 + (textScale.scale(16) - 16).clamp(0, double.infinity) * 3;
    final brand = localizations.getText('loh576na');
    final welcome = Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: localizations.getText('onboarding_welcome_intro')),
            TextSpan(
              text: '\n$brand',
              style: theme.displaySmall.copyWith(
                color: theme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        key: const ValueKey('onboarding-title'),
        style: theme.headlineMedium.copyWith(
          color: theme.primaryText,
          fontWeight: FontWeight.w700,
          height: 1.08,
        ),
      ),
    );
    final content = Column(
      key: const ValueKey('onboarding-content'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        welcome,
        SizedBox(height: spacing.lg),
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
            maxLines: 2,
            textAlign: TextAlign.center,
            padding: EdgeInsets.zero,
            iconPadding: EdgeInsetsDirectional.only(end: tokens.spacing.sm),
            iconColor: theme.onPrimary,
            color: theme.primary,
            textStyle: theme.labelLarge.copyWith(
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
            maxLines: 2,
            textAlign: TextAlign.center,
            padding: EdgeInsets.zero,
            iconPadding: EdgeInsetsDirectional.only(end: tokens.spacing.sm),
            iconColor: theme.primaryText,
            color: theme.secondaryBackground,
            textStyle: theme.labelLarge.copyWith(
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
            height: buttonHeight,
            maxLines: 2,
            textAlign: TextAlign.center,
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
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(gradient: tokens.background.homeGradient),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final split = width >= 900 || (width >= 540 && width > height * 1.25);
          final inset = width < 360 || height < 400 ? spacing.md : spacing.lg;
          final drumHeight = split
              ? (height * .48).clamp(120.0, 390.0)
              : (height - 408).clamp(112.0, 300.0);
          final hero = Column(
            key: const ValueKey('onboarding-hero'),
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const HomeHeaderBrand(),
              SizedBox(height: spacing.md),
              Center(
                child: SizedBox(
                  height: drumHeight,
                  width: drumHeight * .8,
                  child: HomeRaisedArtwork(
                    asset: 'assets/images/home/lottery_drum.webp',
                    imageKey: const ValueKey('onboarding-drum'),
                    width: drumHeight * .8,
                    fallback: Icons.casino_outlined,
                    foreground: theme.primary,
                  ),
                ),
              ),
            ],
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: height * .64,
                  width: double.infinity,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.primaryText.withValues(alpha: .62),
                        theme.primaryText.withValues(alpha: 0),
                      ],
                    ).createShader(bounds),
                    child: Image.asset(
                      'assets/images/home/sapphire.webp',
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: height),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: split ? 1056 : 480),
                      padding: EdgeInsets.all(inset),
                      child: split
                          ? Row(
                              key: const ValueKey('onboarding-wide-panel'),
                              children: [
                                Expanded(child: hero),
                                SizedBox(width: inset * 2),
                                Expanded(child: content),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                hero,
                                SizedBox(height: spacing.lg),
                                content,
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
