import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'edit_profil_texts_model.dart';

export 'edit_profil_texts_model.dart';

typedef ProfilePhoneSave = Future<void> Function(String phoneNumber);

class EditProfilTextsWidget extends StatefulWidget {
  const EditProfilTextsWidget({
    super.key,
    required this.champ,
    this.initialValue,
    this.onPhoneSaved,
  });

  final int champ;
  final String? initialValue;
  final ProfilePhoneSave? onPhoneSaved;

  @override
  State<EditProfilTextsWidget> createState() => _EditProfilTextsWidgetState();
}

class _EditProfilTextsWidgetState extends State<EditProfilTextsWidget> {
  late EditProfilTextsModel _model;
  String? _validationMessage;
  bool _isSaving = false;

  bool get _isPhoneField => widget.champ == 3;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfilTextsModel());
    _model.emailTextController ??= TextEditingController(
      text: widget.initialValue ?? _currentValue(),
    );
    _model.textFieldFocusNode ??= FocusNode();
  }

  String _currentValue() => switch (widget.champ) {
        1 => currentUserDisplayName,
        2 => currentUserEmail,
        3 => currentPhoneNumber,
        _ => '',
      };

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  String _fieldLabel(FFLocalizations localizations) => switch (widget.champ) {
        2 => localizations.getText('prfemlhint'),
        3 => localizations.getText('profile_phone_label'),
        _ => localizations.getText('prfnamehint'),
      };

  String _fieldHint(FFLocalizations localizations) => _isPhoneField
      ? localizations.getText('profile_phone_hint')
      : _fieldLabel(localizations);

  TextInputType get _keyboardType => switch (widget.champ) {
        2 => TextInputType.emailAddress,
        3 => TextInputType.phone,
        _ => TextInputType.name,
      };

  Iterable<String>? get _autofillHints => switch (widget.champ) {
        2 => const [AutofillHints.email],
        3 => const [AutofillHints.telephoneNumber],
        _ => const [AutofillHints.nickname],
      };

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    final localizations = FFLocalizations.of(context);
    final enteredValue = _model.emailTextController.text.trim();
    var valueToSave = enteredValue;

    if (widget.champ == 2 && enteredValue.isEmpty) {
      setState(() => _validationMessage = localizations.getText('prfemailrq'));
      _model.textFieldFocusNode?.requestFocus();
      return;
    }

    if (_isPhoneField) {
      valueToSave = normalizeRegistrationPhoneNumber(enteredValue);
      if (valueToSave.isEmpty) {
        setState(
          () => _validationMessage =
              localizations.getText('profile_phone_required'),
        );
        _model.textFieldFocusNode?.requestFocus();
        return;
      }
      if (!isValidRegistrationPhoneNumber(valueToSave)) {
        setState(
          () => _validationMessage =
              localizations.getText('registration_phone_invalid'),
        );
        _model.textFieldFocusNode?.requestFocus();
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _validationMessage = null;
    });

    try {
      if (widget.champ == 1) {
        await currentUserReference!.update(
          createUserRecordData(displayName: valueToSave),
        );
      } else if (widget.champ == 2) {
        await authManager.updateEmail(email: valueToSave, context: context);
      } else if (_isPhoneField) {
        final savePhone = widget.onPhoneSaved;
        if (savePhone != null) {
          await savePhone(valueToSave);
        } else {
          await currentUserReference!.update(
            createUserRecordData(phoneNumber: valueToSave),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _validationMessage = localizations.getText('profile_save_error');
        });
      }
      return;
    }

    if (!mounted) {
      return;
    }
    TextInput.finishAutofillContext();
    final didClose = await Navigator.maybePop(context);
    if (!didClose && mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius.md),
      borderSide: BorderSide(color: theme.alternate),
    );

    return Material(
      color: theme.secondaryBackground,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(tokens.radius.lg),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.all(tokens.spacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _fieldLabel(localizations),
                    style: theme.titleLarge,
                  ),
                  SizedBox(height: tokens.spacing.md),
                  TextField(
                    key: ValueKey(
                      _isPhoneField ? 'profile-phone-field' : 'profile-field',
                    ),
                    controller: _model.emailTextController,
                    focusNode: _model.textFieldFocusNode,
                    autofocus: true,
                    enabled: !_isSaving,
                    keyboardType: _keyboardType,
                    textInputAction: TextInputAction.done,
                    autofillHints: _autofillHints,
                    onChanged: (_) {
                      if (_validationMessage != null) {
                        setState(() => _validationMessage = null);
                      }
                    },
                    onSubmitted: (_) => _save(),
                    style: theme.bodyLarge,
                    cursorColor: theme.primary,
                    decoration: InputDecoration(
                      labelText: _fieldLabel(localizations),
                      hintText: _fieldHint(localizations),
                      labelStyle:
                          theme.bodyMedium.copyWith(color: theme.secondaryText),
                      hintStyle:
                          theme.bodyMedium.copyWith(color: theme.secondaryText),
                      prefixIcon: _isPhoneField
                          ? Icon(Icons.phone_outlined, color: theme.primary)
                          : null,
                      filled: true,
                      fillColor: theme.primaryBackground,
                      enabledBorder: border,
                      disabledBorder: border,
                      focusedBorder: border.copyWith(
                        borderSide: BorderSide(
                          color: theme.primary,
                          width: 2.0,
                        ),
                      ),
                      errorBorder: border.copyWith(
                        borderSide: BorderSide(color: theme.error),
                      ),
                      contentPadding: EdgeInsets.all(tokens.spacing.md),
                    ),
                  ),
                  if (_validationMessage != null) ...[
                    SizedBox(height: tokens.spacing.sm),
                    Text(
                      _validationMessage!,
                      key: const ValueKey('profile-validation-message'),
                      style: theme.bodySmall.copyWith(color: theme.error),
                    ),
                  ],
                  SizedBox(height: tokens.spacing.lg),
                  FFButtonWidget(
                    key: const ValueKey('profile-save-button'),
                    onPressed: _isSaving ? null : _save,
                    text: localizations.getText('prfsavebtn'),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 52.0,
                      padding: EdgeInsets.zero,
                      color: theme.primary,
                      textStyle: theme.titleSmall.copyWith(
                        color: theme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(tokens.radius.full),
                      disabledColor: theme.alternate,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
