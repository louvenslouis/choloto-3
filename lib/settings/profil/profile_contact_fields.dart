import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/settings/parametres/account_editor_sheet.dart';
import '/settings/parametres/settings_tile.dart';
import 'edit_profil_texts/edit_profil_texts_widget.dart';

class ProfileContactFields extends StatelessWidget {
  const ProfileContactFields({super.key, required this.profile});
  final UserRecord? profile;

  @override
  Widget build(BuildContext context) {
    final t = FFLocalizations.of(context);
    final tokens = FlutterFlowTheme.of(context).designToken;
    final owner = profile;
    final phone = owner?.phoneNumber.isNotEmpty == true
        ? owner!.phoneNumber
        : currentUser?.phoneNumber ?? '';
    final birthday = owner?.birthday;
    final date = birthday == null ? null : birthdayCalendarDate(birthday);
    return Column(children: [
      SettingsTile(
        tileKey: const ValueKey('profile-phone-tile'),
        icon: Icons.phone_outlined,
        title: t.getText('profile_phone_label'),
        detail: phone.isEmpty ? t.getText('profile_phone_add') : phone,
        actionIcon: phone.isEmpty ? Icons.add_rounded : Icons.edit_outlined,
        onTap: owner == null
            ? null
            : () => showAccountEditor(
                context,
                EditProfilTextsWidget(
                  champ: 3,
                  initialValue: phone,
                  onPhoneSaved: (value) => updateOwnProfile(
                      owner, createUserRecordData(phoneNumber: value)),
                )),
      ),
      Divider(
          height: 1,
          indent: tokens.spacing.md,
          endIndent: tokens.spacing.md,
          color: tokens.home.panelEdge),
      SettingsTile(
        icon: Icons.cake_outlined,
        title: t.getText('profile_birthday'),
        detail: date == null
            ? null
            : dateTimeFormat('yMMMd', date, locale: t.languageCode),
        actionIcon: date == null ? Icons.add_rounded : Icons.edit_outlined,
        onTap: owner == null
            ? null
            : () => showAccountEditor(
                context,
                BirthdayEditor(
                  initial: date,
                  onSave: (value) => updateOwnProfile(
                      owner, createUserRecordData(birthday: value)),
                )),
      ),
    ]);
  }
}

// New date-only values use noon UTC; preserve the displayed local day of older timestamps.
DateTime birthdayCalendarDate(DateTime value) {
  final utc = value.toUtc();
  return utc == DateTime.utc(utc.year, utc.month, utc.day, 12)
      ? utc
      : value.toLocal();
}

bool isProfileBirthdayInAgeRange(DateTime birth, DateTime today) {
  var age = today.year - birth.year;
  if (today.month < birth.month ||
      (today.month == birth.month && today.day < birth.day)) {
    age--;
  }
  return age >= 18 && age <= 100;
}

class BirthdayEditor extends StatefulWidget {
  const BirthdayEditor({super.key, this.initial, required this.onSave});
  final DateTime? initial;
  final Future<void> Function(DateTime) onSave;
  @override
  State<BirthdayEditor> createState() => _BirthdayEditorState();
}

class _BirthdayEditorState extends State<BirthdayEditor> {
  late String day = widget.initial?.day.toString() ?? '';
  late String month = widget.initial?.month.toString() ?? '';
  late String year = widget.initial?.year.toString() ?? '';

  DateTime? _date() {
    final d = int.tryParse(day);
    final m = int.tryParse(month);
    final y = int.tryParse(year);
    if (d == null || m == null || y == null || y < 1 || year.length != 4) {
      return null;
    }
    final result = DateTime.utc(y, m, d, 12);
    final now = DateTime.now();
    if (result.month != m ||
        result.day != d ||
        result.year != y ||
        result.isAfter(DateTime.utc(now.year, now.month, now.day, 12))) {
      return null;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final t = FFLocalizations.of(context);
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    Widget field(String key, String value, ValueChanged<String> onChanged) =>
        TextFormField(
          key: ValueKey(key),
          initialValue: value,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          textInputAction:
              key == 'birth_year' ? TextInputAction.done : TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(key == 'birth_year' ? 4 : 2)
          ],
          style: theme.bodyLarge,
          decoration: InputDecoration(
              labelText: t.getText(key),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.primary, width: 2))),
        );
    final fields = [
      if (t.languageCode == 'en') field('birth_month', month, (v) => month = v),
      field('birth_day', day, (v) => day = v),
      if (t.languageCode != 'en') field('birth_month', month, (v) => month = v),
      field('birth_year', year, (v) => year = v),
    ];
    return AccountEditorSheet(
      title: t.getText('profile_birthday'),
      validationError: () {
        final birth = _date();
        if (birth == null) return t.getText('birth_invalid');
        return isProfileBirthdayInAgeRange(birth, DateTime.now())
            ? null
            : t.getText('birth_age_range');
      },
      onSave: () => widget.onSave(_date()!),
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth <
            280 * MediaQuery.textScalerOf(context).scale(16) / 16) {
          return Column(children: fields.divide(SizedBox(height: spacing.sm)));
        }
        return Row(
            children: fields
                .map<Widget>((f) => Expanded(child: f))
                .toList()
                .divide(SizedBox(width: spacing.sm)));
      }),
    );
  }
}
