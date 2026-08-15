import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_manager.dart';
import '../../flutter_flow/flutter_flow_util.dart';

import '/backend/backend.dart';
import 'anonymous_auth.dart';
import 'apple_auth.dart';
import 'email_auth.dart';
import 'firebase_user_provider.dart';
import 'google_auth.dart';
import 'jwt_token_auth.dart';
import 'github_auth.dart';
import 'sign_in_profile.dart';

export '../base_auth_user_provider.dart';

String _localizedFirebaseAuthError(
  BuildContext context,
  FirebaseAuthException error,
) {
  final localizations = FFLocalizations.of(context);

  return switch (error.code) {
    'email-already-in-use' => localizations.getVariableText(
        frText: 'Cette adresse e-mail est déjà utilisée par un autre compte.',
        enText: 'This email address is already used by another account.',
        crText: 'Gen yon lòt kont ki deja sèvi ak adrès imèl sa a.',
      ),
    'INVALID_LOGIN_CREDENTIALS' ||
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' =>
      localizations.getVariableText(
        frText: 'L’adresse e-mail ou le mot de passe est incorrect.',
        enText: 'The email address or password is incorrect.',
        crText: 'Adrès imèl la oswa modpas la pa kòrèk.',
      ),
    'invalid-email' => localizations.getVariableText(
        frText: 'Veuillez saisir une adresse e-mail valide.',
        enText: 'Please enter a valid email address.',
        crText: 'Tanpri antre yon adrès imèl ki valab.',
      ),
    'invalid-phone-number' ||
    'missing-phone-number' =>
      localizations.getVariableText(
        frText: 'Veuillez saisir un numéro de téléphone valide.',
        enText: 'Please enter a valid phone number.',
        crText: 'Tanpri antre yon nimewo telefòn ki valab.',
      ),
    'invalid-verification-code' => localizations.getVariableText(
        frText: 'Le code de vérification est incorrect.',
        enText: 'The verification code is incorrect.',
        crText: 'Kòd verifikasyon an pa kòrèk.',
      ),
    'session-expired' ||
    'missing-verification-id' =>
      localizations.getVariableText(
        frText: 'Ce code a expiré. Demandez un nouveau code.',
        enText: 'This code has expired. Request a new code.',
        crText: 'Kòd sa a ekspire. Mande yon nouvo kòd.',
      ),
    'quota-exceeded' => localizations.getVariableText(
        frText:
            'La limite d’envoi de SMS est atteinte. Veuillez réessayer plus tard.',
        enText:
            'The SMS sending limit has been reached. Please try again later.',
        crText: 'Limit voye SMS la rive. Tanpri eseye ankò pita.',
      ),
    'operation-not-allowed' => localizations.getVariableText(
        frText: 'La connexion par téléphone n’est pas encore disponible.',
        enText: 'Phone sign-in is not available yet.',
        crText: 'Koneksyon ak telefòn poko disponib.',
      ),
    'weak-password' => localizations.getVariableText(
        frText: 'Ce mot de passe est trop faible.',
        enText: 'This password is too weak.',
        crText: 'Modpas sa a twò fèb.',
      ),
    'network-request-failed' => localizations.getVariableText(
        frText: 'Vérifiez votre connexion Internet, puis réessayez.',
        enText: 'Check your internet connection, then try again.',
        crText: 'Verifye koneksyon entènèt ou, epi eseye ankò.',
      ),
    'too-many-requests' => localizations.getVariableText(
        frText: 'Trop de tentatives. Veuillez réessayer plus tard.',
        enText: 'Too many attempts. Please try again later.',
        crText: 'Gen twòp tantativ. Tanpri eseye ankò pita.',
      ),
    'user-disabled' => localizations.getVariableText(
        frText: 'Ce compte a été désactivé.',
        enText: 'This account has been disabled.',
        crText: 'Kont sa a dezaktive.',
      ),
    _ => _localizedUnexpectedAuthError(context, error.message),
  };
}

String _localizedUnexpectedAuthError(
  BuildContext context,
  String? firebaseMessage,
) {
  final localizations = FFLocalizations.of(context);
  final detail = firebaseMessage?.trim();
  final summary = localizations.getVariableText(
    frText: 'Une erreur d’authentification est survenue.',
    enText: 'An authentication error occurred.',
    crText: 'Yon erè otantifikasyon rive.',
  );
  if (detail == null || detail.isEmpty) {
    return summary;
  }

  final detailLabel = localizations.getVariableText(
    frText: 'Détail',
    enText: 'Details',
    crText: 'Detay',
  );
  return '$summary\n$detailLabel: $detail';
}

void _showAuthSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class FirebasePhoneAuthManager extends ChangeNotifier {
  bool? _triggerOnCodeSent;
  FirebaseAuthException? phoneAuthError;
  // Set when using phone verification (after phone number is provided).
  String? phoneAuthVerificationCode;
  // Set when using phone sign in in web mode (ignored otherwise).
  ConfirmationResult? webPhoneAuthConfirmationResult;
  // Used for handling verification codes for phone sign in.
  void Function(BuildContext)? _onCodeSent;

  bool get triggerOnCodeSent => _triggerOnCodeSent ?? false;
  set triggerOnCodeSent(bool val) => _triggerOnCodeSent = val;

  void Function(BuildContext) get onCodeSent =>
      _onCodeSent == null ? (_) {} : _onCodeSent!;
  set onCodeSent(void Function(BuildContext) func) => _onCodeSent = func;

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }
}

class FirebaseAuthManager extends AuthManager
    with
        EmailSignInManager,
        GoogleSignInManager,
        AppleSignInManager,
        AnonymousSignInManager,
        JwtSignInManager,
        GithubSignInManager,
        PhoneSignInManager {
  FirebasePhoneAuthManager phoneAuthManager = FirebasePhoneAuthManager();

  @override
  Future signOut() {
    logFirebaseEvent("SIGN_OUT");
    return FirebaseAuth.instance.signOut();
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      if (!loggedIn) {
        print('Error: delete user attempted with no logged in user!');
        return;
      }
      logFirebaseEvent("DELETE_USER");
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'requires-recent-login'
          ? FFLocalizations.of(context).getVariableText(
              frText:
                  'Votre dernière connexion est trop ancienne. Reconnectez-vous avant de supprimer votre compte.',
              enText:
                  'Your last sign-in was too long ago. Sign in again before deleting your account.',
              crText:
                  'Dènye koneksyon ou a twò ansyen. Konekte ankò anvan ou efase kont ou.',
            )
          : _localizedFirebaseAuthError(context, e);
      _showAuthSnackBar(context, message);
    }
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        print('Error: update email attempted with no logged in user!');
        return;
      }
      await currentUser?.updateEmail(email);
      await updateUserDocument(email: email);
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'requires-recent-login'
          ? FFLocalizations.of(context).getVariableText(
              frText:
                  'Votre dernière connexion est trop ancienne. Reconnectez-vous avant de modifier votre adresse e-mail.',
              enText:
                  'Your last sign-in was too long ago. Sign in again before updating your email address.',
              crText:
                  'Dènye koneksyon ou a twò ansyen. Konekte ankò anvan ou chanje adrès imèl ou.',
            )
          : _localizedFirebaseAuthError(context, e);
      _showAuthSnackBar(context, message);
    }
  }

  @override
  Future updatePassword({
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        print('Error: update password attempted with no logged in user!');
        return;
      }
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'requires-recent-login'
          ? FFLocalizations.of(context).getVariableText(
              frText:
                  'Votre dernière connexion est trop ancienne. Reconnectez-vous avant de modifier votre mot de passe.',
              enText:
                  'Your last sign-in was too long ago. Sign in again before updating your password.',
              crText:
                  'Dènye koneksyon ou a twò ansyen. Konekte ankò anvan ou chanje modpas ou.',
            )
          : _localizedFirebaseAuthError(context, e);
      _showAuthSnackBar(context, message);
    }
  }

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _showAuthSnackBar(context, _localizedFirebaseAuthError(context, e));
      return null;
    }
    _showAuthSnackBar(
      context,
      FFLocalizations.of(context).getVariableText(
        frText: 'L’e-mail de réinitialisation du mot de passe a été envoyé.',
        enText: 'The password reset email has been sent.',
        crText: 'Nou voye imèl pou reyinisyalize modpas la.',
      ),
    );
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailSignInFunc(email, password),
        'EMAIL',
      );

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailCreateAccountFunc(email, password),
        'EMAIL',
      );

  @override
  Future<BaseAuthUser?> signInAnonymously(
    BuildContext context,
  ) =>
      _signInOrCreateAccount(context, anonymousSignInFunc, 'ANONYMOUS');

  @override
  Future<BaseAuthUser?> signInWithApple(BuildContext context) =>
      _signInOrCreateAccount(context, appleSignIn, 'APPLE');

  @override
  Future<BaseAuthUser?> signInWithGoogle(BuildContext context) =>
      _signInOrCreateAccount(context, googleSignInFunc, 'GOOGLE');

  @override
  Future<BaseAuthUser?> signInWithGithub(BuildContext context) =>
      _signInOrCreateAccount(context, githubSignInFunc, 'GITHUB');

  @override
  Future<BaseAuthUser?> signInWithJwtToken(
    BuildContext context,
    String jwtToken,
  ) =>
      _signInOrCreateAccount(context, () => jwtTokenSignIn(jwtToken), 'JWT');

  void handlePhoneAuthStateChanges(BuildContext context) {
    phoneAuthManager.addListener(() {
      if (!context.mounted) {
        return;
      }

      if (phoneAuthManager.triggerOnCodeSent) {
        phoneAuthManager.onCodeSent(context);
        phoneAuthManager
            .update(() => phoneAuthManager.triggerOnCodeSent = false);
      } else if (phoneAuthManager.phoneAuthError != null) {
        final e = phoneAuthManager.phoneAuthError!;
        _showAuthSnackBar(context, _localizedFirebaseAuthError(context, e));
        phoneAuthManager.update(() => phoneAuthManager.phoneAuthError = null);
      }
    });
  }

  @override
  Future<bool> beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
    void Function(BuildContext, BaseAuthUser)? onAutoVerified,
  }) async {
    try {
      if (kIsWeb) {
        phoneAuthManager.webPhoneAuthConfirmationResult =
            await FirebaseAuth.instance.signInWithPhoneNumber(phoneNumber);
        if (context.mounted) {
          onCodeSent(context);
        }
        return true;
      }

      final completer = Completer<bool>();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (phoneAuthCredential) async {
          final user = await _signInOrCreateAccount(
            context,
            () =>
                FirebaseAuth.instance.signInWithCredential(phoneAuthCredential),
            'PHONE',
          );
          if (!completer.isCompleted) {
            completer.complete(user != null);
          }
          if (user != null && context.mounted) {
            onAutoVerified?.call(context, user);
          }
        },
        verificationFailed: (e) {
          if (context.mounted) {
            _showAuthSnackBar(context, _localizedFirebaseAuthError(context, e));
          }
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
        codeSent: (verificationId, _) {
          phoneAuthManager.phoneAuthVerificationCode = verificationId;
          if (context.mounted) {
            onCodeSent(context);
          }
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          phoneAuthManager.phoneAuthVerificationCode = verificationId;
        },
      );

      return completer.future;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _showAuthSnackBar(context, _localizedFirebaseAuthError(context, e));
      }
      return false;
    }
  }

  @override
  Future<BaseAuthUser?> verifySmsCode({
    required BuildContext context,
    required String smsCode,
  }) async {
    if (kIsWeb) {
      final confirmationResult =
          phoneAuthManager.webPhoneAuthConfirmationResult;
      if (confirmationResult == null) {
        _showAuthSnackBar(
          context,
          _localizedFirebaseAuthError(
            context,
            FirebaseAuthException(code: 'missing-verification-id'),
          ),
        );
        return null;
      }
      return _signInOrCreateAccount(
        context,
        () => confirmationResult.confirm(smsCode),
        'PHONE',
      );
    } else {
      final verificationId = phoneAuthManager.phoneAuthVerificationCode;
      if (verificationId == null) {
        _showAuthSnackBar(
          context,
          _localizedFirebaseAuthError(
            context,
            FirebaseAuthException(code: 'missing-verification-id'),
          ),
        );
        return null;
      }
      final authCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return _signInOrCreateAccount(
        context,
        () => FirebaseAuth.instance.signInWithCredential(authCredential),
        'PHONE',
      );
    }
  }

  /// Tries to sign in or create an account using Firebase Auth.
  /// Returns the User object if sign in was successful.
  Future<BaseAuthUser?> _signInOrCreateAccount(
    BuildContext context,
    Future<UserCredential?> Function() signInFunc,
    String authProvider,
  ) async {
    try {
      final userCredential =
          await signInAndEnsureUserProfile<UserCredential, User>(
        authenticate: signInFunc,
        userFromCredential: (credential) => credential.user,
        ensureUserProfile: maybeCreateUser,
      );
      logFirebaseAuthEvent(userCredential?.user, authProvider);
      return userCredential == null
          ? null
          : CholotoFirebaseUser.fromUserCredential(userCredential);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _showAuthSnackBar(context, _localizedFirebaseAuthError(context, e));
      }
      return null;
    }
  }
}
