import '/auth/firebase_auth/auth_util.dart';
import '/auth/phone_number.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneAuthSheet extends StatefulWidget {
  const PhoneAuthSheet({super.key});

  @override
  State<PhoneAuthSheet> createState() => _PhoneAuthSheetState();
}

class _PhoneAuthSheetState extends State<PhoneAuthSheet> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();

  bool _codeSent = false;
  String? _phoneNumber;
  String? _validationMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _phoneFocusNode.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final localizations = FFLocalizations.of(context);
    final phoneNumber = normalizePhoneNumber(_phoneController.text);
    if (phoneNumber == null) {
      setState(() {
        _validationMessage = localizations.getText('phone_invalid_number');
      });
      _phoneFocusNode.requestFocus();
      return;
    }

    setState(() {
      _phoneNumber = phoneNumber;
      _validationMessage = null;
    });

    await authManager.beginPhoneAuth(
      context: context,
      phoneNumber: phoneNumber,
      onCodeSent: (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _codeSent = true;
          _validationMessage = null;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _codeFocusNode.requestFocus();
          }
        });
      },
      onAutoVerified: (_, user) {
        if (mounted) {
          Navigator.of(context).pop(user);
        }
      },
    );
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() {
        _validationMessage =
            FFLocalizations.of(context).getText('phone_invalid_code');
      });
      _codeFocusNode.requestFocus();
      return;
    }

    setState(() => _validationMessage = null);
    final user = await authManager.verifySmsCode(
      context: context,
      smsCode: code,
    );
    if (user != null && mounted) {
      Navigator.of(context).pop(user);
    }
  }

  void _changePhoneNumber() {
    setState(() {
      _codeSent = false;
      _codeController.clear();
      _validationMessage = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _phoneFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 670.0),
          padding: EdgeInsets.fromLTRB(
            tokens.spacing.md,
            tokens.spacing.md,
            tokens.spacing.md,
            tokens.spacing.lg,
          ),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(tokens.radius.lg),
            ),
            boxShadow: [tokens.shadow.lg],
          ),
          child: AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        localizations.getText('phone_sign_in_title'),
                        style: theme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: localizations.getText('phone_close'),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: theme.primaryText),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacing.sm),
                Text(
                  _codeSent
                      ? localizations
                          .getText('phone_code_description')
                          .replaceAll(
                            '{phoneNumber}',
                            _phoneNumber ?? '',
                          )
                      : localizations.getText('phone_number_description'),
                  style: theme.bodyMedium.copyWith(color: theme.secondaryText),
                ),
                SizedBox(height: tokens.spacing.md),
                if (!_codeSent)
                  TextFormField(
                    key: const ValueKey('phone-number-field'),
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    onFieldSubmitted: (_) => _requestCode(),
                    style: theme.bodyLarge,
                    decoration: _inputDecoration(
                      theme,
                      label: localizations.getText('phone_number_label'),
                      hint: '+509 37 00 00 00',
                      icon: Icons.phone_outlined,
                    ),
                  )
                else
                  TextFormField(
                    key: const ValueKey('sms-code-field'),
                    controller: _codeController,
                    focusNode: _codeFocusNode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onFieldSubmitted: (_) => _verifyCode(),
                    style: theme.bodyLarge.copyWith(letterSpacing: 8.0),
                    decoration: _inputDecoration(
                      theme,
                      label: localizations.getText('phone_code_label'),
                      hint: '000000',
                      icon: Icons.sms_outlined,
                    ),
                  ),
                if (_validationMessage != null) ...[
                  SizedBox(height: tokens.spacing.sm),
                  Text(
                    _validationMessage!,
                    key: const ValueKey('phone-validation-message'),
                    style: theme.bodySmall.copyWith(color: theme.error),
                  ),
                ],
                SizedBox(height: tokens.spacing.md),
                FFButtonWidget(
                  text: localizations.getText(
                    _codeSent ? 'phone_verify_code' : 'phone_send_code',
                  ),
                  onPressed: _codeSent ? _verifyCode : _requestCode,
                  icon: Icon(
                    _codeSent ? Icons.verified_outlined : Icons.sms_outlined,
                    color: theme.onPrimary,
                  ),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 56.0,
                    color: theme.primary,
                    iconColor: theme.onPrimary,
                    textStyle:
                        theme.titleMedium.copyWith(color: theme.onPrimary),
                    borderRadius: BorderRadius.circular(tokens.radius.full),
                    hoverColor: theme.warning,
                  ),
                ),
                if (_codeSent) ...[
                  SizedBox(height: tokens.spacing.sm),
                  TextButton(
                    onPressed: _changePhoneNumber,
                    child: Text(
                      localizations.getText('phone_change_number'),
                      style: theme.labelLarge.copyWith(color: theme.primary),
                    ),
                  ),
                  TextButton(
                    onPressed: _requestCode,
                    child: Text(
                      localizations.getText('phone_resend_code'),
                      style:
                          theme.labelLarge.copyWith(color: theme.primaryText),
                    ),
                  ),
                ],
                SizedBox(height: tokens.spacing.sm),
                Text(
                  localizations.getText('phone_sms_notice'),
                  textAlign: TextAlign.center,
                  style: theme.bodySmall.copyWith(color: theme.secondaryText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    FlutterFlowTheme theme, {
    required String label,
    required String hint,
    required IconData icon,
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
      prefixIcon: Icon(icon, color: theme.primary),
      filled: true,
      fillColor: theme.primaryBackground,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: theme.primary, width: 2.0),
      ),
      errorBorder: border.copyWith(borderSide: BorderSide(color: theme.error)),
      contentPadding: EdgeInsets.all(tokens.spacing.md),
    );
  }
}
