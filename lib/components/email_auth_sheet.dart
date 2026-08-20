import '/auth/base_auth_user_provider.dart';
import '/auth/email_address.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef EmailAuthenticationAction = Future<BaseAuthUser?> Function(
  String email,
  String password,
);
typedef EmailPasswordResetAction = Future<void> Function(String email);

class EmailAuthSheet extends StatefulWidget {
  const EmailAuthSheet({
    super.key,
    required this.onSignIn,
    required this.onCreateAccount,
    required this.onResetPassword,
  });

  final EmailAuthenticationAction onSignIn;
  final EmailAuthenticationAction onCreateAccount;
  final EmailPasswordResetAction onResetPassword;

  @override
  State<EmailAuthSheet> createState() => _EmailAuthSheetState();
}

class _EmailAuthSheetState extends State<EmailAuthSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isCreatingAccount = true;
  bool _isSubmitting = false;
  bool _showPassword = false;
  bool _showConfirmation = false;
  String? _validationMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final localizations = FFLocalizations.of(context);
    final email = normalizeEmailAddress(_emailController.text);
    if (email == null) {
      setState(() {
        _validationMessage = localizations.getText('email_invalid');
      });
      _emailFocusNode.requestFocus();
      return;
    }

    final password = _passwordController.text;
    if (password.length < 6) {
      setState(() {
        _validationMessage = localizations.getText('email_password_too_short');
      });
      _passwordFocusNode.requestFocus();
      return;
    }

    if (_isCreatingAccount && password != _confirmPasswordController.text) {
      setState(() {
        _validationMessage = localizations.getText('email_password_mismatch');
      });
      _confirmPasswordFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _validationMessage = null;
    });

    final user = _isCreatingAccount
        ? await widget.onCreateAccount(email, password)
        : await widget.onSignIn(email, password);

    if (user != null && mounted) {
      TextInput.finishAutofillContext();
      Navigator.of(context).pop(user);
      return;
    }
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_isSubmitting) {
      return;
    }

    final email = normalizeEmailAddress(_emailController.text);
    if (email == null) {
      setState(() {
        _validationMessage =
            FFLocalizations.of(context).getText('email_invalid');
      });
      _emailFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _validationMessage = null;
    });
    await widget.onResetPassword(email);
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  void _setMode({required bool createAccount}) {
    if (_isSubmitting || _isCreatingAccount == createAccount) {
      return;
    }
    setState(() {
      _isCreatingAccount = createAccount;
      _validationMessage = null;
      _confirmPasswordController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _emailController.text.trim().isEmpty
            ? _emailFocusNode.requestFocus()
            : _passwordFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);

    return SingleChildScrollView(
      key: const ValueKey('email-auth-scroll-view'),
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
                        localizations.getText(
                          _isCreatingAccount
                              ? 'email_create_title'
                              : 'email_sign_in_title',
                        ),
                        style: theme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: localizations.getText('email_close'),
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: theme.primaryText),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacing.sm),
                Material(
                  color: theme.primaryBackground,
                  borderRadius: BorderRadius.circular(tokens.radius.full),
                  child: Container(
                    padding: EdgeInsets.all(tokens.spacing.xs),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.alternate.withValues(alpha: 0.45),
                      ),
                      borderRadius: BorderRadius.circular(tokens.radius.full),
                    ),
                    child: Row(
                      children: [
                        _buildModeButton(
                          theme,
                          key: const ValueKey('email-create-mode'),
                          label: localizations.getText('email_create_mode'),
                          selected: _isCreatingAccount,
                          onTap: () => _setMode(createAccount: true),
                        ),
                        _buildModeButton(
                          theme,
                          key: const ValueKey('email-sign-in-mode'),
                          label: localizations.getText('email_sign_in_mode'),
                          selected: !_isCreatingAccount,
                          onTap: () => _setMode(createAccount: false),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: tokens.spacing.md),
                Text(
                  localizations.getText(
                    _isCreatingAccount
                        ? 'email_create_description'
                        : 'email_sign_in_description',
                  ),
                  style: theme.bodyMedium.copyWith(color: theme.secondaryText),
                ),
                SizedBox(height: tokens.spacing.md),
                TextFormField(
                  key: const ValueKey('email-field'),
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  autofocus: true,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                  style: theme.bodyLarge,
                  decoration: _inputDecoration(
                    theme,
                    label: localizations.getText('email_label'),
                    hint: 'nom@exemple.com',
                    icon: Icons.email_outlined,
                  ),
                ),
                SizedBox(height: tokens.spacing.md),
                TextFormField(
                  key: const ValueKey('email-password-field'),
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  enabled: !_isSubmitting,
                  obscureText: !_showPassword,
                  textInputAction: _isCreatingAccount
                      ? TextInputAction.next
                      : TextInputAction.done,
                  autofillHints: [
                    _isCreatingAccount
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  onFieldSubmitted: (_) => _isCreatingAccount
                      ? _confirmPasswordFocusNode.requestFocus()
                      : _submit(),
                  style: theme.bodyLarge,
                  decoration: _inputDecoration(
                    theme,
                    label: localizations.getText('email_password_label'),
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      tooltip: localizations.getText(
                        _showPassword
                            ? 'email_hide_password'
                            : 'email_show_password',
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                ),
                if (_isCreatingAccount) ...[
                  SizedBox(height: tokens.spacing.md),
                  TextFormField(
                    key: const ValueKey('email-confirm-password-field'),
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    enabled: !_isSubmitting,
                    obscureText: !_showConfirmation,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    onFieldSubmitted: (_) => _submit(),
                    style: theme.bodyLarge,
                    decoration: _inputDecoration(
                      theme,
                      label:
                          localizations.getText('email_confirm_password_label'),
                      icon: Icons.lock_reset_outlined,
                      suffixIcon: IconButton(
                        tooltip: localizations.getText(
                          _showConfirmation
                              ? 'email_hide_password'
                              : 'email_show_password',
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : () => setState(
                                  () => _showConfirmation = !_showConfirmation,
                                ),
                        icon: Icon(
                          _showConfirmation
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: theme.secondaryText,
                        ),
                      ),
                    ),
                  ),
                ],
                if (_validationMessage != null) ...[
                  SizedBox(height: tokens.spacing.sm),
                  Text(
                    _validationMessage!,
                    key: const ValueKey('email-validation-message'),
                    style: theme.bodySmall.copyWith(color: theme.error),
                  ),
                ],
                if (!_isCreatingAccount)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      key: const ValueKey('email-reset-password-button'),
                      onPressed: _isSubmitting ? null : _resetPassword,
                      child: Text(
                        localizations.getText('email_forgot_password'),
                        style: theme.labelLarge.copyWith(color: theme.primary),
                      ),
                    ),
                  )
                else
                  SizedBox(height: tokens.spacing.md),
                FFButtonWidget(
                  key: const ValueKey('email-submit-button'),
                  text: _isSubmitting
                      ? localizations.getText('email_loading')
                      : localizations.getText(
                          _isCreatingAccount
                              ? 'email_create_account'
                              : 'email_sign_in',
                        ),
                  onPressed: _isSubmitting ? null : _submit,
                  icon: Icon(
                    _isCreatingAccount
                        ? Icons.person_add_alt_outlined
                        : Icons.login_outlined,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
    FlutterFlowTheme theme, {
    required Key key,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final tokens = theme.designToken;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          key: key,
          onTap: _isSubmitting ? null : onTap,
          borderRadius: BorderRadius.circular(tokens.radius.full),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.sm,
              vertical: tokens.spacing.sm,
            ),
            decoration: BoxDecoration(
              color: selected ? theme.primary : theme.primaryBackground,
              borderRadius: BorderRadius.circular(tokens.radius.full),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
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

  InputDecoration _inputDecoration(
    FlutterFlowTheme theme, {
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
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
      suffixIcon: suffixIcon,
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
