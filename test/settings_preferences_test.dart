import 'package:choloto/app_state.dart';
import 'package:choloto/auth/firebase_auth/auth_util.dart'
    show currentUserDocument;
import 'package:choloto/backend/schema/user_record.dart';
import 'package:choloto/settings/parametres/member_notification_settings.dart';
import 'package:choloto/settings/profil/profile_contact_fields.dart';
import 'package:choloto/settings/profil/profil/profil_widget.dart';
import 'package:choloto/settings/profil/edit_profil_texts/edit_profil_texts_widget.dart';
import 'support/memory_firestore.dart';
import 'package:choloto/auth/base_auth_user_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/settings/device_preferences.dart';
import 'package:choloto/main.dart' show MyApp;
import 'package:choloto/settings/parametres/parametres_widget.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Reuse the offline Firestore adapter to inspect individual field updates.
// ignore: subtype_of_sealed_class
class _ProfileReference extends MemoryReference {
  _ProfileReference(super.path);
  final writes = <Map<Object, Object?>>[];
  @override
  Future<void> update(Map<Object, Object?> data) async => writes.add(data);
}

class _PhoneMember extends Fake implements BaseAuthUser {
  @override
  String get uid => 'member';
  @override
  bool get loggedIn => true;
  @override
  bool get isAnonymous => false;
  @override
  String? get email => null;
  @override
  String get phoneNumber => '+1 555 0100';
}

class _NamedMember extends _PhoneMember {
  @override
  String get displayName => 'Marie Jean';
  @override
  String get email => 'marie.jean@example.com';
}

class _OfflineAuth extends FirebaseAuthPlatform {
  @override
  FirebaseAuthPlatform delegateFor(
          {required FirebaseApp app, Persistence? persistence}) =>
      this;
  @override
  FirebaseAuthPlatform setInitialValues(
          {Object? currentUser, String? languageCode}) =>
      this;
  @override
  Stream<UserPlatform?> authStateChanges() => const Stream.empty();
  @override
  Stream<UserPlatform?> idTokenChanges() => const Stream.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
    FirebaseAuthPlatform.instance = _OfflineAuth();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi.logEvent',
      (_) async => const StandardMessageCodec().encodeMessage([null]),
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    PackageInfo.setMockInitialValues(
        appName: 'CHOLOTO',
        packageName: 'demo',
        version: '2.1',
        buildNumber: '42',
        buildSignature: '');
  });

  test('ages 18 through 100 are inclusive and change on the birthday', () {
    final today = DateTime(2026, 11, 28);
    for (final entry in {
      DateTime.utc(2008, 11, 29, 12): false,
      DateTime.utc(2008, 11, 28, 12): true,
      DateTime.utc(2008, 11, 27, 12): true,
      DateTime.utc(1926, 11, 28, 12): true,
      DateTime.utc(1925, 11, 29, 12): true,
      DateTime.utc(1925, 11, 28, 12): false,
      DateTime.utc(1925, 11, 27, 12): false,
    }.entries) {
      expect(isProfileBirthdayInAgeRange(entry.key, today), entry.value,
          reason: entry.key.toIso8601String());
    }
    final leapDay = DateTime.utc(2008, 2, 29, 12);
    expect(
        isProfileBirthdayInAgeRange(leapDay, DateTime(2026, 2, 28)), isFalse);
    expect(isProfileBirthdayInAgeRange(leapDay, DateTime(2026, 3, 1)), isTrue);
  });

  test('unrecognized stored options use device defaults', () async {
    SharedPreferences.setMockInitialValues({
      'settings.homeDrawMarket': 'removed',
      'settings.readingSize': 2,
      'settings.reduceMotion': 'old',
    });
    await FFAppState().initializePersistedState();
    final prefs = FFAppState().devicePreferences;
    expect(prefs.market, HomeDrawMarket.ny);
    expect(prefs.size, ReadingSize.system);
    expect(prefs.reduceMotion, isFalse);
    const system = MediaQueryData(
        disableAnimations: true, textScaler: TextScaler.linear(1.8));
    expect(prefs.applyTo(system).disableAnimations, isTrue);
    await prefs.setSize(ReadingSize.large);
    expect(prefs.applyTo(system).textScaler.scale(10), 18);
  });

  Future<void> open(
      WidgetTester tester, String lang, double width, Brightness brightness,
      {Widget page = const ParametresWidget()}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, width < 600 ? 640 : 900);
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final device = FFAppState().devicePreferences;
    if (brightness == Brightness.light) {
      await device.setSize(ReadingSize.extraLarge);
    }
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => ListenableBuilder(
        listenable: device,
        builder: (context, _) => MediaQuery(
            data: device.applyTo(MediaQuery.of(context)), child: child!),
      ),
      locale: Locale(lang),
      supportedLocales: const [Locale('fr'), Locale('en'), Locale('cr')],
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      theme: DarkModeTheme().materialTheme,
      home: page,
    ));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'members see their profile and subscription even without an email',
      (tester) async {
    currentUser = _PhoneMember();
    addTearDown(() => currentUser = null);
    await open(tester, 'fr', 320, Brightness.dark);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('+1 555 0100'), findsOneWidget);
    expect(find.byKey(const ValueKey('subscription-settings-menu')),
        findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);
  });

  for (final lang in ['fr', 'en', 'cr']) {
    for (final width in [320.0, 1440.0]) {
      for (final brightness in Brightness.values) {
        testWidgets('profile identity panel $lang $width ${brightness.name}',
            (tester) async {
          final member = _NamedMember();
          currentUser = member;
          addTearDown(() => currentUser = null);
          await open(tester, lang, width, brightness,
              page: const ProfilWidget());

          final panel = find.byWidgetPredicate((widget) =>
              widget is DecoratedBox &&
              widget.decoration == DarkModeTheme().designToken.home.panel);
          final rows =
              find.descendant(of: panel, matching: find.byType(ListTile));
          expect(rows, findsNWidgets(2));
          final nameBounds = tester.getRect(rows.first);
          final emailBounds = tester.getRect(rows.last);
          expect(nameBounds.bottom, emailBounds.top);
          expect(nameBounds.width, width);
          for (final (index, value)
              in [member.displayName, member.email].indexed) {
            final row = rows.at(index);
            final text = find.descendant(of: row, matching: find.text(value));
            final edit =
                find.descendant(of: row, matching: find.byIcon(Icons.create));
            expect(tester.getTopLeft(text).dx, 12);
            expect(tester.getTopRight(edit).dx, width - 12);
            await tester.tap(edit);
            await tester.pumpAndSettle();
            final editor = tester.widget<EditProfilTextsWidget>(
                find.byType(EditProfilTextsWidget));
            expect(editor.champ, index + 1);
            expect(editor.initialValue, value);
            Navigator.of(tester.element(find.byType(EditProfilTextsWidget)))
                .pop();
            await tester.pumpAndSettle();
          }
          expect(tester.takeException(), isNull);
        });

        testWidgets('account editors $lang $width ${brightness.name}',
            (tester) async {
          final ref = _ProfileReference('user/member');
          currentUser = _PhoneMember();
          currentUserDocument = UserRecord.getDocumentFromData({
            'birthday': DateTime.utc(2000, 2, 29, 12),
            'web_push_preferences': {'assistant_reply': false},
          }, ref);
          addTearDown(() {
            currentUser = null;
            currentUserDocument = null;
          });
          await open(tester, lang, width, brightness);
          final t = FFLocalizations(Locale(lang)).getText;
          Future<void> tap(Finder finder) async {
            await tester.ensureVisible(finder);
            await tester.tap(finder);
            await tester.pumpAndSettle();
          }

          await tap(find.text(t('profile_phone_label')));
          await tester.enterText(
              find.byKey(const ValueKey('profile-phone-field')),
              '+509 (37) 00-00-00');
          await tap(find.byKey(const ValueKey('profile-save-button')));
          expect(ref.writes.single, {'phone_number': '+50937000000'});

          await tap(find.text(t('profile_birthday')));
          final year = find.byKey(const ValueKey('birth_year'));
          expect(find.text('2000'), findsOneWidget);
          await tester.enterText(year, '2001');
          await tap(find.text(t('prfsavebtn')));
          expect(find.text(t('birth_invalid')), findsOneWidget);
          await tester.enterText(year, '2096');
          await tap(find.text(t('prfsavebtn')));
          expect(ref.writes, hasLength(1));
          await tester.enterText(year, '1804');
          await tap(find.text(t('prfsavebtn')));
          expect(find.text(t('birth_age_range')), findsOneWidget);
          expect(ref.writes, hasLength(1));
          await tester.enterText(year, '1996');
          await tap(find.text(t('prfsavebtn')));
          expect(ref.writes.last, {'birthday': DateTime.utc(1996, 2, 29, 12)});

          await tap(find.text(t('push_categories')));
          final replies = find.byKey(const ValueKey(MemberNotification.reply));
          final bingo = find.byKey(const ValueKey(MemberNotification.bingo));
          expect(tester.widget<SwitchListTile>(replies).value, isFalse);
          expect(tester.widget<SwitchListTile>(bingo).value, isTrue);
          await tap(replies);
          await tap(bingo);
          await tap(find.text(t('prfsavebtn')));
          expect(ref.writes.last, {
            'web_push_preferences.assistant_reply': true,
            'web_push_preferences.new_bingo': false
          });
          expect(ref.writes, hasLength(3));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets(
      'an editor cannot save into another session and keeps the input on failure',
      (tester) async {
    final ref = _ProfileReference('user/member');
    final member = _PhoneMember();
    currentUser = member;
    currentUserDocument = UserRecord.getDocumentFromData({}, ref);
    addTearDown(() {
      currentUser = null;
      currentUserDocument = null;
    });
    await open(tester, 'fr', 1440, Brightness.dark);
    expect(find.text('5 sur 5'), findsOneWidget);
    await tester.tap(find.text('Date de naissance'));
    await tester.pumpAndSettle();
    for (final entry in {
      'birth_day': '12',
      'birth_month': '8',
      'birth_year': '1990'
    }.entries) {
      await tester.enterText(find.byKey(ValueKey(entry.key)), entry.value);
    }
    currentUser = null;
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(ref.writes, isEmpty);
    expect(
        find.text(
            FFLocalizations(const Locale('fr')).getText('profile_save_error')),
        findsOneWidget);
    currentUser = member;
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(ref.writes.single, {'birthday': DateTime.utc(1990, 8, 12, 12)});
  });

  testWidgets('choosing a language updates the app and its saved locale',
      (tester) async {
    await FFLocalizations.initialize();
    await FFLocalizations.storeLocale('fr');
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator).first).push(
          MaterialPageRoute<void>(builder: (_) => const ParametresWidget()),
        );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Langue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kreyòl ayisyen'));
    await tester.pumpAndSettle();
    expect(find.text('Paramèt'), findsOneWidget);
    expect(find.text('Kreyòl ayisyen'), findsOneWidget);
    expect(FFLocalizations.getStoredLocale(), const Locale('cr'));
  });

  for (final lang in ['fr', 'en', 'cr']) {
    for (final width in [320.0, 1440.0]) {
      for (final brightness in Brightness.values) {
        testWidgets('settings $lang ${width.toInt()} ${brightness.name}',
            (tester) async {
          await open(tester, lang, width, brightness);
          final t = FFLocalizations(Locale(lang)).getText;
          final pref = tester.getTopLeft(find.text(t('settings_preferences')));
          final account = tester.getTopLeft(find.text(t('settings_account')));
          if (width == 320) {
            expect(account.dy, greaterThan(pref.dy));
          } else {
            expect(account.dy, pref.dy);
            expect(account.dx, greaterThan(pref.dx));
          }
          expect(find.text(t('f9ixk3ux')), findsOneWidget);
          expect(find.text(t('eywbwq85')), findsNothing);
          expect(find.text('2.1 (42)'), findsOneWidget);
          await tester.tap(find.text(t('9w72tojm')));
          await tester.pumpAndSettle();
          final selected = tester
              .widgetList<ListTile>(find.byType(ListTile))
              .singleWhere((tile) => tile.selected);
          expect((selected.title! as Text).data, t('settings_language_$lang'));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('settings choices apply and survive reopening the app',
      (tester) async {
    await open(tester, 'fr', 320, Brightness.dark);
    final prefs = FFAppState().devicePreferences;
    for (final entry in {
      'Premier tirage sur l’accueil': 'Floride',
      'Taille du texte': 'Très grand',
      'Animations': 'Réduites'
    }.entries) {
      await tester.ensureVisible(find.text(entry.key));
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.value));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
    }

    final version = find.text('2.1 (42)');
    await tester.ensureVisible(version);
    String? copied;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = call.arguments['text'] as String;
      }
      return null;
    });
    addTearDown(() =>
        messenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.tap(version);
    await tester.pumpAndSettle();
    expect(copied, '2.1 (42)');
    expect(find.text('Version copiée'), findsOneWidget);

    expect(prefs.applyTo(const MediaQueryData()).textScaler.scale(10), 14);
    expect(prefs.applyTo(const MediaQueryData()).disableAnimations, isTrue);
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    final restored = FFAppState().devicePreferences;
    expect(restored.market, HomeDrawMarket.fl);
    expect(restored.size, ReadingSize.extraLarge);
    expect(restored.reduceMotion, isTrue);
  });
}
