import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef RegistrationSubmission = Future<void> Function({
  required String phoneNumber,
  required String preferredLanguage,
  required String device,
});

class RegistrationCompletionWidget extends StatefulWidget {
  const RegistrationCompletionWidget({
    super.key,
    this.onSubmit,
    this.onLanguageSaved,
    this.onCompleted,
  });

  static String routeName = 'RegistrationCompletion';
  static String routePath = '/complete-registration';

  final RegistrationSubmission? onSubmit;
  final ValueChanged<String>? onLanguageSaved;
  final VoidCallback? onCompleted;

  @override
  State<RegistrationCompletionWidget> createState() =>
      _RegistrationCompletionWidgetState();
}

class _RegistrationCompletionWidgetState
    extends State<RegistrationCompletionWidget> {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

  String? _selectedLanguage;
  String? _validationMessage;
  bool _isSubmitting = false;
  bool _didPrefillPhone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentLanguage = FFLocalizations.of(context).languageCode;
    final savedLanguage = currentUserDocument?.preferredLanguage;
    _selectedLanguage ??= supportedRegistrationLanguages.contains(savedLanguage)
        ? savedLanguage
        : currentLanguage;

    if (!_didPrefillPhone) {
      _phoneController.text =
          currentUserDocument?.phoneNumber ?? currentPhoneNumber;
      _didPrefillPhone = true;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
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

  void _selectLanguage(String language) {
    if (_isSubmitting) {
      return;
    }
    setState(() {
      _selectedLanguage = language;
      _validationMessage = null;
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final localizations = FFLocalizations.of(context);
    final phoneNumber = normalizeRegistrationPhoneNumber(_phoneController.text);
    if (phoneNumber.isNotEmpty &&
        !isValidRegistrationPhoneNumber(phoneNumber)) {
      setState(() {
        _validationMessage =
            localizations.getText('registration_phone_invalid');
      });
      _phoneFocusNode.requestFocus();
      return;
    }

    final preferredLanguage = _selectedLanguage;
    if (preferredLanguage == null ||
        !supportedRegistrationLanguages.contains(preferredLanguage)) {
      setState(() {
        _validationMessage =
            localizations.getText('registration_language_required');
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _validationMessage = null;
    });

    try {
      await (widget.onSubmit ?? completeUserRegistration)(
        phoneNumber: phoneNumber,
        preferredLanguage: preferredLanguage,
        device: _currentDeviceName(),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _validationMessage = localizations.getText('registration_save_error');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }

    if (!mounted || _validationMessage != null) {
      return;
    }

    TextInput.finishAutofillContext();
    if (widget.onLanguageSaved != null) {
      widget.onLanguageSaved!(preferredLanguage);
    } else {
      try {
        setAppLanguage(context, preferredLanguage);
      } catch (_) {
        // Language preference is already persisted with the profile.
      }
    }
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    } else {
      context.go(HomeWidget.routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560.0),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.all(tokens.spacing.md),
              child: Container(
                key: const ValueKey('registration-completion-card'),
                padding: EdgeInsets.all(tokens.spacing.lg),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                  boxShadow: [tokens.shadow.lg],
                ),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        image: true,
                        label: localizations.getText('onboarding_logo_label'),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(tokens.radius.md),
                            child: Image.asset(
                              'assets/images/Logo_Choloto_509.png',
                              width: 56.0,
                              height: 56.0,
                              fit: BoxFit.cover,
                              excludeFromSemantics: true,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: tokens.spacing.lg),
                      Text(
                        localizations.getText('registration_eyebrow'),
                        style: theme.labelLarge.copyWith(
                          color: theme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: tokens.spacing.xs),
                      Text(
                        localizations.getText('registration_title'),
                        key: const ValueKey('registration-title'),
                        style: theme.headlineMedium,
                      ),
                      SizedBox(height: tokens.spacing.sm),
                      Text(
                        localizations.getText('registration_description'),
                        style: theme.bodyMedium.copyWith(
                          color: theme.secondaryText,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: tokens.spacing.xl),
                      Text(
                        localizations.getText('registration_language_label'),
                        style: theme.titleSmall,
                      ),
                      SizedBox(height: tokens.spacing.sm),
                      Wrap(
                        spacing: tokens.spacing.sm,
                        runSpacing: tokens.spacing.sm,
                        children: [
                          _LanguageOption(
                            key: const ValueKey('registration-language-fr'),
                            label: localizations
                                .getText('registration_language_fr'),
                            selected: _selectedLanguage == 'fr',
                            onPressed: () => _selectLanguage('fr'),
                          ),
                          _LanguageOption(
                            key: const ValueKey('registration-language-en'),
                            label: localizations
                                .getText('registration_language_en'),
                            selected: _selectedLanguage == 'en',
                            onPressed: () => _selectLanguage('en'),
                          ),
                          _LanguageOption(
                            key: const ValueKey('registration-language-cr'),
                            label: localizations
                                .getText('registration_language_cr'),
                            selected: _selectedLanguage == 'cr',
                            onPressed: () => _selectLanguage('cr'),
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.spacing.lg),
                      TextField(
                        key: const ValueKey('registration-phone-field'),
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        enabled: !_isSubmitting,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        onChanged: (_) {
                          if (_validationMessage != null) {
                            setState(() => _validationMessage = null);
                          }
                        },
                        onSubmitted: (_) => _submit(),
                        style: theme.bodyLarge,
                        cursorColor: theme.primary,
                        decoration: _phoneInputDecoration(
                          theme,
                          label:
                              localizations.getText('registration_phone_label'),
                          hint:
                              localizations.getText('registration_phone_hint'),
                        ),
                      ),
                      if (_validationMessage != null) ...[
                        SizedBox(height: tokens.spacing.sm),
                        Text(
                          _validationMessage!,
                          key:
                              const ValueKey('registration-validation-message'),
                          style: theme.bodySmall.copyWith(color: theme.error),
                        ),
                      ],
                      SizedBox(height: tokens.spacing.lg),
                      FFButtonWidget(
                        key: const ValueKey('registration-submit-button'),
                        onPressed: _isSubmitting ? null : _submit,
                        text: localizations.getText('registration_validate'),
                        icon: Icon(
                          Icons.check_circle_outline_rounded,
                          color: theme.onPrimary,
                          size: 20.0,
                        ),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 52.0,
                          padding: EdgeInsets.zero,
                          iconPadding: EdgeInsetsDirectional.only(
                            end: tokens.spacing.sm,
                          ),
                          iconColor: theme.onPrimary,
                          color: theme.primary,
                          textStyle: theme.titleSmall.copyWith(
                            color: theme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          elevation: 0.0,
                          borderRadius:
                              BorderRadius.circular(tokens.radius.full),
                          disabledColor: theme.alternate,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _phoneInputDecoration(
    FlutterFlowTheme theme, {
    required String label,
    required String hint,
  }) {
    final tokens = theme.designToken;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius.md),
      borderSide: BorderSide(color: theme.alternate),
    );

    return InputDecoration(
      labelText: label,
      labelStyle: theme.bodyMedium.copyWith(color: theme.secondaryText),
      hintText: hint,
      hintStyle: theme.bodyMedium.copyWith(color: theme.secondaryText),
      prefixIcon: Icon(Icons.phone_outlined, color: theme.primary),
      filled: true,
      fillColor: theme.primaryBackground,
      enabledBorder: border,
      disabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: theme.primary, width: 2.0),
      ),
      errorBorder: border.copyWith(borderSide: BorderSide(color: theme.error)),
      contentPadding: EdgeInsets.all(tokens.spacing.md),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? theme.primary : theme.primaryBackground,
        borderRadius: BorderRadius.circular(tokens.radius.full),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(tokens.radius.full),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.md,
              vertical: tokens.spacing.sm,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? theme.primary : theme.alternate,
              ),
              borderRadius: BorderRadius.circular(tokens.radius.full),
            ),
            child: Text(
              label,
              style: theme.labelLarge.copyWith(
                color: selected ? theme.onPrimary : theme.primaryText,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
