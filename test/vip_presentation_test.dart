import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:choloto/app_state.dart';
import 'package:choloto/accomplissements/vip_badge.dart';
import 'package:choloto/accomplissements/member_vip_badge.dart';
import 'package:choloto/components/vip_page_header.dart';
import 'package:choloto/auth/base_auth_user_provider.dart';
import 'package:choloto/auth/firebase_auth/auth_util.dart'
    show currentUserDocument;
import 'package:choloto/backend/schema/user_record.dart';
import 'package:choloto/backend/schema/prediction_record.dart';
import 'package:choloto/components/vip_prediction_panel.dart';
import 'package:choloto/flutter_flow/flutter_flow_widgets.dart';
import 'package:choloto/components/vip_prediction_header.dart';
import 'package:choloto/components/vip_casino_card.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/vip/vip/vip_widget.dart';
import 'package:choloto/main.dart';
// Firestore's platform codec also encodes the receipt timestamps.
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    show FirebaseFirestoreHostApi;
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as font_testing;

import 'support/memory_firestore.dart';

const exportDirectory = String.fromEnvironment('VIP_VISUAL_DIR');
const interFont = String.fromEnvironment('VIP_INTER_FONT');
const portraitFile = String.fromEnvironment('VIP_AVATAR_IMAGE');
const photoUrl = 'https://example.invalid/vip/profile.jpg';

class _VipPresentationBinding extends AutomatedTestWidgetsFlutterBinding {
  // The default test binding renders shadows as hard rectangles. Capture
  // the same soft surfaces and artwork that users see on the member page.
  @override
  bool get disableShadows => false;
}

class _Member extends Fake implements BaseAuthUser {
  @override
  bool get loggedIn => true;
  @override
  bool get isAnonymous => false;
  @override
  String get uid => 'vip-local-member';
  @override
  String get photoUrl => '';
  @override
  String get displayName => '';
}

class _PreviewAuth extends FirebaseAuthPlatform {
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
}

class _TestFontManifest extends Fake implements AssetManifest {
  @override
  List<String> listAssets() => [
        '__test_fonts/Inter-Regular.ttf',
        '__test_fonts/Inter-Light.ttf',
        '__test_fonts/Inter-Medium.ttf',
        '__test_fonts/Inter-Black.ttf',
        '__test_fonts/Inter-SemiBold.ttf',
        '__test_fonts/Inter-Bold.ttf',
        '__test_fonts/Inter-ExtraBold.ttf',
      ];
}

final _example = PredictionRecord.getDocumentFromData({
  'date': DateTime(2026, 11, 24),
  'periode': 'Soir',
  'pourcentage': 85,
  'favori': {
    'name': 'FAVORI',
    'boul': ['07']
  },
  'soutni': {
    'name': 'SOUTNI',
    'boul': ['42', '65']
  },
  'boloto': {
    'name': 'BOLOTO',
    'boul': ['18', '72']
  },
  'mariage': {
    'name': 'MARIAGE',
    'boul': ['12 x 34']
  },
  'chif3': {
    'name': '3 CHIFFRES',
    'boul': ['123']
  },
  'chif4': {
    'name': '4 CHIFFRES',
    'boul': ['1234']
  },
  'extra': {
    'name': 'EXTRA',
    'boul': ['90']
  },
}, MemoryReference('prediction/local-example'));

PredictionRecord _selection(String fixture, Map<String, List<String>> values) {
  return PredictionRecord.getDocumentFromData({
    'date': DateTime(2026, 11, 24),
    'periode': 'Soir',
    'pourcentage': 85,
    for (final entry in values.entries) entry.key: {'boul': entry.value},
  }, MemoryReference('prediction/$fixture'));
}

// Published formats that put pressure on narrow cards and their illustrations.
const _fullSelection = {
  'favori': ['07', '81', '16', '42'],
  'soutni': ['03', '65', '28', '94'],
  'boloto': ['08', '19', '74', '56'],
  'mariage': ['12 x 34', '63 × 81', '07×09', '24 x 60'],
  'chif3': ['007', '308', '419', '720'],
  'chif4': ['0008', '4310', '9615', '0047'],
  'extra': ['02-19-40-76', '17', '036', '0589'],
};

// A separate, fictional evening draw for previews of the normal member page.
final _previewSelection = _selection('preview-evening-draw', {
  'favori': ['07', '81'],
  'soutni': ['42', '65'],
  'boloto': ['18', '72', '53'],
  'mariage': ['12 x 34', '07×09'],
  'chif3': ['048', '361'],
  'chif4': ['1706', '0087'],
  'extra': ['04-17-62'],
});

Widget _app(Widget page, {String language = 'fr', double textScale = 1}) {
  return ChangeNotifierProvider.value(
    value: FFAppState(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(language),
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
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: textScale > 1,
        ),
        child: child!,
      ),
      home: NavBarPage(initialPage: 'VIP', page: page),
    ),
  );
}

void _setViewport(WidgetTester tester, Size size, Brightness system) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.padding = FakeViewPadding(
    top: size.width < 600 ? 24 : 0,
    bottom: size.width == 390 ? 24 : 0,
  );
  tester.binding.platformDispatcher.platformBrightnessTestValue = system;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  addTearDown(
      tester.binding.platformDispatcher.clearPlatformBrightnessTestValue);
}

void _noAction() {}

Widget _member(
        {PredictionRecord? prediction,
        String name = 'Mika Jean',
        bool hasPhoto = false,
        VoidCallback? onProfile,
        VoidCallback? onHistory,
        VoidCallback? onTip,
        VoidCallback? onBack}) =>
    VipPageView(
      memberName: name,
      avatar: VipHeaderAvatar(name: name, photoUrl: hasPhoto ? photoUrl : ''),
      memberMedal: const VipBadgeView(
        tiers: defaultVipBadges,
        time: (elapsed: Duration(days: 90), days: 90, partial: false),
        active: true,
        showCollection: false,
        expandedMedal: true,
      ),
      content: VipPredictionPanel(prediction: prediction ?? _example),
      onProfile: onProfile ?? _noAction,
      onTip: onTip ?? _noAction,
      onBack: onBack,
      onHistory: onHistory ?? _noAction,
    );

const _categories = [
  (id: 'favorite', field: 'favori', label: 'viphstfav', asset: 'favorite'),
  (id: 'soutni', field: 'soutni', label: 'viphstsou', asset: 'soutni'),
  (id: 'boloto', field: 'boloto', label: 'viphstbol', asset: 'boloto'),
  (id: 'mariage', field: 'mariage', label: 'viphstmar', asset: 'mariage'),
  (
    id: 'threeDigits',
    field: 'chif3',
    label: 'viphstc3f',
    asset: 'three_digits'
  ),
  (id: 'fourDigits', field: 'chif4', label: 'viphstc4f', asset: 'four_digits'),
  (id: 'extra', field: 'extra', label: 'viphstext', asset: 'extra'),
];

void _expectPredictionGrid(WidgetTester tester, int columns) {
  final cards = <Rect>[];
  for (final category in _categories) {
    final tile = find.byKey(ValueKey('vip-prediction-${category.id}'));
    final art = find.descendant(
        of: tile, matching: find.byKey(ValueKey('vip-art-${category.id}')));
    final background = tester.widget<Image>(art);
    expect(background.image,
        AssetImage('assets/images/vip_predictions/${category.asset}.webp'));
    expect(background.excludeFromSemantics, isTrue);

    final bounds = tester.getRect(tile);
    cards.add(bounds);
    for (final element in find
        .descendant(of: tile, matching: find.byType(RichText))
        .evaluate()) {
      final paragraph = element.renderObject! as RenderParagraph;
      final label = paragraph.text.toPlainText();
      expect(paragraph.didExceedMaxLines, isFalse, reason: label);
      for (final box in paragraph.getBoxesForSelection(
          TextSelection(baseOffset: 0, extentOffset: label.length))) {
        final textRect = MatrixUtils.transformRect(
            paragraph.getTransformTo(null), box.toRect());
        expect(bounds.inflate(1).contains(textRect.topLeft), isTrue,
            reason: '$label: $textRect outside $bounds');
        expect(bounds.inflate(1).contains(textRect.bottomRight), isTrue,
            reason: '$label: $textRect outside $bounds');
      }
    }
  }
  for (var i = 0; i < cards.length; i++) {
    final card = cards[i];
    expect(card.width, closeTo(cards.first.width, 1));
    if (i % columns == 0) {
      expect(card.left, closeTo(cards.first.left, 1));
      if (i > 0) expect(card.top, greaterThan(cards[i - columns].bottom));
    } else {
      expect(card.top, closeTo(cards[i - 1].top, 1));
      expect(card.bottom, closeTo(cards[i - 1].bottom, 1));
      expect(card.left, greaterThan(cards[i - 1].right));
    }
  }
}

Future<void> _save(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    await Future.wait(find.byType(Image).evaluate().map(
        (element) => precacheImage((element.widget as Image).image, element)));
  });
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final picture = await boundary.toImage(pixelRatio: 2);
    final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
    await Directory(exportDirectory).create(recursive: true);
    await File('$exportDirectory/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    picture.dispose();
  });
}

Future<({int width, ByteData rgba})> _readPixels(
    WidgetTester tester, RenderRepaintBoundary boundary) async {
  return (await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      return (width: image.width, rgba: bytes!);
    } finally {
      image.dispose();
    }
  }))!;
}

InlineSpan _replaceInk(InlineSpan original, Color ink) {
  if (original is! TextSpan) return original;
  return TextSpan(
    text: original.text,
    style: (original.style ?? const TextStyle())
        .copyWith(foreground: Paint()..color = ink),
    children: original.children?.map((span) => _replaceInk(span, ink)).toList(),
  );
}

Future<void> _expectIllustrationContrast(
    WidgetTester tester, RenderRepaintBoundary boundary) async {
  final ink = await _readPixels(tester, boundary);
  final samples = <({
    String description,
    Color color,
    RenderParagraph paragraph,
    InlineSpan original,
    List<Rect> lines,
  })>[];
  final strings = FFLocalizations(const Locale('fr'));
  for (final category in _categories) {
    final card = find.byKey(ValueKey('vip-prediction-${category.id}'));
    final art = find.descendant(
        of: card, matching: find.byKey(ValueKey('vip-art-${category.id}')));
    final rawImage = find.descendant(of: art, matching: find.byType(RawImage));
    final raw = tester.widget<RawImage>(rawImage);
    expect(raw.image, isNotNull);
    final source =
        Size(raw.image!.width / raw.scale, raw.image!.height / raw.scale);
    final frame = tester.getRect(rawImage);
    final fitted = applyBoxFit(raw.fit ?? BoxFit.scaleDown, source, frame.size);
    final painted = raw.alignment
        .resolve(TextDirection.ltr)
        .inscribe(fitted.destination, frame);
    final title = strings.getText(category.label);
    final caption = find.descendant(of: card, matching: find.text(title));
    final captionRect = tester.getRect(caption);
    final cardRect = tester.getRect(card);
    expect(fitted.source.width, closeTo(source.width, 1), reason: category.id);
    expect(fitted.source.height, closeTo(source.height, 1),
        reason: category.id);
    expect(painted.bottom, closeTo(cardRect.bottom, 1), reason: category.id);
    expect(painted.right, closeTo(cardRect.right, 1), reason: category.id);
    expect(captionRect.center.dy, greaterThan(cardRect.center.dy));
    expect(captionRect.left, lessThan(cardRect.center.dx));
    for (final element
        in find.descendant(of: card, matching: find.byType(Text)).evaluate()) {
      final widget = element.widget as Text;
      final richText = find.descendant(
          of: find.byWidget(widget), matching: find.byType(RichText));
      final paragraph = tester.renderObject<RenderParagraph>(richText);
      final text = paragraph.text.toPlainText(includeSemanticsLabels: false);
      final transform = paragraph.getTransformTo(boundary);
      final boxes = paragraph.getBoxesForSelection(
          TextSelection(baseOffset: 0, extentOffset: text.length));
      if (text != title) {
        expect(tester.getRect(find.byWidget(widget)).bottom,
            lessThanOrEqualTo(captionRect.top),
            reason: '${category.id} · $text');
      }
      samples.add((
        description: '${category.id} · $text',
        color: widget.style!.color!,
        paragraph: paragraph,
        original: paragraph.text,
        lines: [
          for (final box in boxes)
            MatrixUtils.transformRect(transform, box.toRect())
        ],
      ));
    }
  }

  // Black ink makes a coverage mask even when a white glyph coincides with
  // a white highlight. Invisible ink then exposes the actual backdrop under
  // that mask without changing the illustration, its shade, or any line break.
  late ({int width, ByteData rgba}) blackInk;
  late ({int width, ByteData rgba}) backdrop;
  try {
    for (final sample in samples) {
      sample.paragraph.text = _replaceInk(sample.original, Colors.black);
    }
    await tester.pump();
    blackInk = await _readPixels(tester, boundary);
    for (final sample in samples) {
      sample.paragraph.text = _replaceInk(sample.original, Colors.transparent);
    }
    await tester.pump();
    backdrop = await _readPixels(tester, boundary);
  } finally {
    for (final sample in samples) {
      sample.paragraph.text = sample.original;
    }
    await tester.pump();
  }
  expect(backdrop.width, ink.width);
  expect(backdrop.rgba.lengthInBytes, ink.rgba.lengthInBytes);
  final poorContrast = <String>[];
  for (final sample in samples) {
    expect(sample.lines, isNotEmpty, reason: sample.description);
    for (final line in sample.lines) {
      var glyphPixels = 0;
      var lowestContrast = double.infinity;
      for (var y = line.top.floor(); y < line.bottom.ceil(); y++) {
        for (var x = line.left.floor(); x < line.right.ceil(); x++) {
          final offset = (y * ink.width + x) * 4;
          // For white text against black ink, one channel gives the glyph's
          // coverage. Ignore only faint antialiasing at its edge.
          final coverage = ink.rgba.getUint8(offset + 1) -
              blackInk.rgba.getUint8(offset + 1);
          if (coverage < 24) continue;
          glyphPixels++;
          final background = Color.fromARGB(
              255,
              backdrop.rgba.getUint8(offset),
              backdrop.rgba.getUint8(offset + 1),
              backdrop.rgba.getUint8(offset + 2));
          final foreground = Color.alphaBlend(sample.color, background);
          final contrast = (foreground.computeLuminance() + .05) /
              (background.computeLuminance() + .05);
          if (contrast < lowestContrast) lowestContrast = contrast;
        }
      }
      expect(glyphPixels, greaterThan(0),
          reason: '${sample.description} has no visible ink on $line');
      if (lowestContrast < 4.5) {
        poorContrast.add(
            '${sample.description} ${lowestContrast.toStringAsFixed(2)}:1');
      }
    }
  }
  expect(poorContrast, isEmpty, reason: 'Minimum contrast per printed line');
}

// Exercises the real guest VIP page and prediction widgets with local fixtures.
void main() {
  _VipPresentationBinding();
  setupFirebaseCoreMocks();

  late ui.Image portrait;
  setUpAll(() async {
    final bytes = portraitFile.isEmpty
        ? await rootBundle.load('assets/images/Logo_Choloto_509.png')
        : ByteData.sublistView(await File(portraitFile).readAsBytes());
    final codec = await ui.instantiateImageCodec(Uint8List.sublistView(bytes),
        targetWidth: 144);
    portrait = (await codec.getNextFrame()).image;
    codec.dispose();
    await Firebase.initializeApp();
    FirebaseAuthPlatform.instance = _PreviewAuth();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(
      'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi.logEvent',
      (_) async => const StandardMessageCodec().encodeMessage([null]),
    );
    final fontBytes = interFont.isNotEmpty
        ? ByteData.sublistView(await File(interFont).readAsBytes())
        : await rootBundle.load(
            'assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf');
    font_testing.assetManifest = _TestFontManifest();
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      final path = utf8.decode(message!.buffer.asUint8List());
      if (path.startsWith('__test_fonts/')) return fontBytes;
      return ByteData.sublistView(
          File('build/unit_test_assets/$path').readAsBytesSync());
    });
    final titleLoader = FontLoader('Google sans flex')
      ..addFont(rootBundle.load(
        'assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf',
      ));
    await titleLoader.load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
    await (FontLoader('packages/font_awesome_flutter/FontAwesomeSolid')
          ..addFont(rootBundle.load(
            'packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf',
          )))
        .load();
    await (FontLoader('packages/font_awesome_flutter/FontAwesomeRegular')
          ..addFont(rootBundle.load(
            'packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf',
          )))
        .load();
    if (interFont.isNotEmpty) {
      for (final family in ['Inter', 'Inter_regular']) {
        await (FontLoader(family)
              ..addFont(File(interFont).readAsBytes().then(
                    (bytes) => ByteData.sublistView(bytes),
                  )))
            .load();
      }
    }
  });

  tearDownAll(() => portrait.dispose());
  setUp(() {
    PaintingBinding.instance.imageCache.putIfAbsent(
      const CachedNetworkImageProvider(photoUrl),
      () => OneFrameImageStreamCompleter(
          Future.value(ImageInfo(image: portrait.clone()))),
    );
  });

  void expectPortrait(WidgetTester tester) {
    final avatar = find.byKey(const ValueKey('vip-profile-button'));
    final image =
        find.descendant(of: avatar, matching: find.byType(CachedNetworkImage));
    expect(tester.widget<CachedNetworkImage>(image).imageUrl, photoUrl);
    final pixels = find.descendant(of: image, matching: find.byType(RawImage));
    expect(tester.widget<RawImage>(pixels).image!.isCloneOf(portrait), isTrue);
  }

  for (final brightness in [Brightness.dark, Brightness.light]) {
    for (final percentage in [null, '100%']) {
      testWidgets(
          'prediction header $brightness $percentage with enlarged text',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(brightness: brightness),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(
              body: VipPredictionHeader(
            label: 'Probabilité : mercredi 30 septembre 2026 Soir',
            percentage: percentage,
          )),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Probabilité : mercredi 30 septembre 2026 Soir'),
            findsOneWidget);
        expect(find.byType(VipCasinoPlaque),
            percentage == null ? findsNothing : findsOneWidget);
        if (percentage != null) expect(find.text(percentage), findsOneWidget);
      });
    }
  }

  const viewports = [
    Size(320, 568),
    Size(390, 844),
    Size(810, 1080),
    Size(1440, 900)
  ];
  for (final language in ['fr', 'en', 'cr']) {
    final strings = FFLocalizations(Locale(language));
    for (final brightness in Brightness.values) {
      for (final size in viewports) {
        for (final member in [false, true]) {
          final name =
              '${member ? "member" : "offer"}-$language-${brightness.name}-${size.width.toInt()}';
          testWidgets('VIP $name', (tester) async {
            _setViewport(tester, size, brightness);
            final key = GlobalKey();
            final hasPhoto = size.width == 390 || size.width == 1440;
            await tester.pumpWidget(RepaintBoundary(
              key: key,
              child: _app(
                  member ? _member(hasPhoto: hasPhoto) : const VipWidget(),
                  language: language),
            ));
            await tester.pumpAndSettle();
            final title = find.text(strings.getText('gfj3b9xn'));
            expect(title, findsOneWidget);
            expect(Theme.of(tester.element(title)).brightness, Brightness.dark);
            expect(find.byKey(const ValueKey('vip-page-medal')),
                member ? findsNothing : findsOneWidget);
            if (member) {
              expect(find.text('Mika Jean'), findsOneWidget);
              if (hasPhoto) {
                expectPortrait(tester);
              } else {
                expect(find.text('MJ'), findsOneWidget);
              }
              expect(find.byKey(const ValueKey('vip-medal-3')).hitTestable(),
                  findsOneWidget);
            }
            for (final name in ['history', 'tip', 'profile']) {
              final button = find.byKey(ValueKey('vip-$name-button'));
              expect(button.hitTestable(), findsOneWidget);
              expect(tester.getSize(button).shortestSide,
                  greaterThanOrEqualTo(48));
            }
            final pass = tester.getRect(find.byType(VipPageHeader));
            final section = tester.getRect(member
                ? find.byType(VipPredictionPanel)
                : find.byKey(const ValueKey('vip-monthly-offer-card')));
            if (size.width >= 810) {
              expect(pass.right, lessThan(section.left));
              expect(pass.top, closeTo(section.top, 1));
            } else {
              expect(pass.bottom, lessThan(section.top));
            }
            if (size.width < 767) {
              final tabs = tester.widget<BottomNavigationBar>(
                  find.byType(BottomNavigationBar));
              expect(tabs.currentIndex, 2);
              expect(tabs.selectedItemColor,
                  DarkModeTheme().designToken.home.amethystGlow);
            } else {
              expect(find.byKey(const ValueKey('vip-desktop-navigation')),
                  findsOneWidget);
            }
            if (member) {
              final favorite = find.text(strings.getText('viphstfav'));
              final soutni = find.text(strings.getText('viphstsou'));
              expect(find.text(strings.getText('viphstext')), findsOneWidget);
              for (final value in [
                '85%',
                '07',
                '42',
                '65',
                '18',
                '72',
                '12 x 34',
                '123',
                '1234',
                '90'
              ]) {
                expect(find.text(value), findsOneWidget);
              }
              expect(favorite, findsOneWidget);
              expect(soutni, findsOneWidget);

              _expectPredictionGrid(
                  tester,
                  switch (size.width) {
                    1440 => 3,
                    _ => 2,
                  });
            } else {
              final price = find.text(strings.getText('r11k1q8q'));
              final action = find.byKey(const ValueKey('become-vip-button'));
              for (final key in ['99kfebqb', 'bl4kupme', 'juufc32a']) {
                expect(find.text(strings.getText(key)), findsOneWidget);
              }
              expect(tester.getBottomLeft(price).dy,
                  lessThanOrEqualTo(tester.getTopLeft(action).dy));
              expect(
                  find.byKey(
                      const ValueKey('open-subscription-support-legacy')),
                  findsOneWidget);
              final plan = tester.getRect(
                  find.byKey(const ValueKey('vip-monthly-offer-card')));
              final comparison = tester.getRect(
                  find.byKey(const ValueKey('vip-plan-comparison-card')));
              if (size.width <= 810) {
                expect(comparison.top, greaterThan(plan.bottom));
              } else {
                expect(comparison.left, greaterThan(plan.right));
              }
              final button = tester.widget<FFButtonWidget>(action);
              expect(button.text, strings.getText('i0zhxntw'));
              expect(button.onPressed, isNotNull);
              expect(button.options.color,
                  DarkModeTheme().designToken.home.amethystGlow);
            }
            if (exportDirectory.isNotEmpty) {
              await _save(tester, key, name);
              if (member &&
                  language == 'fr' &&
                  brightness == Brightness.dark &&
                  size.width == 390) {
                tester.view.physicalSize = const Size(390, 1000);
                await tester.pumpAndSettle();
                final last = tester.getRect(
                    find.byKey(const ValueKey('vip-prediction-extra')));
                final navigation =
                    tester.getRect(find.byType(BottomNavigationBar));
                expect(last.bottom, lessThan(navigation.top));
                await _save(tester, key, 'member-fr-mobile-complet');
              }
            }
            expect(tester.takeException(), isNull);
          });
        }
      }
    }

    testWidgets('VIP actions remain reachable with enlarged $language text',
        (tester) async {
      _setViewport(tester, const Size(320, 568), Brightness.light);
      final opened = <String>[];
      await tester.pumpWidget(_app(
          _member(
            name: 'Marie-Claire Jean-Baptiste Desrosiers',
            onProfile: () => opened.add('profile'),
            onBack: () => opened.add('back'),
            onHistory: () => opened.add('history'),
            onTip: () => opened.add('tip'),
          ),
          language: language,
          textScale: 2));
      await tester.pumpAndSettle();
      for (final name in ['history', 'tip', 'profile', 'back']) {
        final button = find.byKey(ValueKey('vip-$name-button'));
        await tester.ensureVisible(button);
        await tester.tap(button);
      }
      expect(opened, ['history', 'tip', 'profile', 'back']);
      final medal = find.byKey(const ValueKey('vip-medal-3'));
      await tester.ensureVisible(medal);
      await tester.tap(medal);
      await tester.pumpAndSettle();
      expect(find.text(vipBadgeName(strings, defaultVipBadges[2].name)),
          findsWidgets);
      await tester.tap(find.byKey(const ValueKey('close-vip-medal')));
      await tester.pumpAndSettle();
      _expectPredictionGrid(tester, 1);
      final number = find.text('1234');
      await tester.ensureVisible(number);
      expect(number.hitTestable(), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
          _app(const VipWidget(), language: language, textScale: 2));
      await tester.pumpAndSettle();
      final cta = find.byKey(const ValueKey('become-vip-button'));
      await tester.ensureVisible(cta);
      expect(cta.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a wide illustrated prediction panel displays four cards per row',
      (tester) async {
    _setViewport(tester, const Size(1100, 900), Brightness.dark);
    await tester.pumpWidget(_app(Scaffold(
        body: SingleChildScrollView(
      child: VipPredictionPanel(prediction: _example),
    ))));
    await tester.pumpAndSettle();
    _expectPredictionGrid(tester, 4);
    expect(tester.takeException(), isNull);
  });

  for (final scenario in [
    (width: 390.0, scale: 1.0, columns: 2, emptyExtra: false),
    (width: 320.0, scale: 2.0, columns: 1, emptyExtra: false),
    (width: 320.0, scale: 2.0, columns: 1, emptyExtra: true),
    (width: 880.0, scale: 1.0, columns: 3, emptyExtra: false),
  ]) {
    testWidgets(
        'prediction ink stays legible on all illustrations at ${scenario.width} × ${scenario.scale} (empty Extra: ${scenario.emptyExtra})',
        (tester) async {
      _setViewport(tester, Size(scenario.width, 3600), Brightness.dark);
      final values = {
        ..._fullSelection,
        if (scenario.emptyExtra) 'extra': <String>[],
      };
      final key = GlobalKey();
      final page = _app(
          Scaffold(
            body: SingleChildScrollView(
              child: RepaintBoundary(
                key: key,
                child: VipPredictionPanel(
                    prediction: _selection('density', values)),
              ),
            ),
          ),
          textScale: scenario.scale);
      await tester.pumpWidget(page);
      final panel = tester.element(find.byType(VipPredictionPanel));
      await tester.runAsync(() => Future.wait([
            GoogleFonts.pendingFonts(),
            for (final category in _categories)
              precacheImage(
                  AssetImage(
                      'assets/images/vip_predictions/${category.asset}.webp'),
                  panel),
          ]));
      // The first layout may already be cached with the runner's fallback
      // font. Mount a fresh panel so all three exposures share final metrics.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();
      _expectPredictionGrid(tester, scenario.columns);
      for (final category in _categories) {
        final card = find.byKey(ValueKey('vip-prediction-${category.id}'));
        final published = values[category.field]!;
        final expected = published.isEmpty ? ['—'] : published;
        for (final value in expected) {
          expect(find.descendant(of: card, matching: find.text(value)),
              findsOneWidget);
        }
      }
      for (final category in _categories.take(2)) {
        final card = find.byKey(ValueKey('vip-prediction-${category.id}'));
        final numbers = [
          for (final value in values[category.field]!)
            tester
                .getRect(find.descendant(of: card, matching: find.text(value))),
        ];
        final markets =
            find.descendant(of: card, matching: find.textContaining('-NY'));
        expect(tester.widgetList<Text>(markets).map((label) => label.data),
            [category.id == 'soutni' ? 'GG-NY' : 'FLO-NY', 'FLO-NY']);
        expect(numbers[1].top, closeTo(numbers[0].top, 1));
        for (var i = 0; i < 2; i++) {
          final market = tester.getRect(markets.at(i));
          expect(market.left, closeTo(numbers[i].left, 1));
          expect(market.top, greaterThanOrEqualTo(numbers[i].bottom - 1));
          for (final unlabelled in numbers.skip(2)) {
            expect(unlabelled.top, greaterThan(market.bottom),
                reason: '${category.id}: unlabelled value under a market');
          }
        }
      }
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await _expectIllustrationContrast(tester, boundary);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'fragmented marriages keep each published pair and unpaired number',
      (tester) async {
    _setViewport(tester, const Size(390, 844), Brightness.dark);
    final prediction = _selection('fragmented-marriages', {
      'mariage': ['12', 'x', '34', '07', '×', '09', '18 x', '20', '45', '60'],
    });
    await tester.pumpWidget(_app(_member(prediction: prediction)));
    await tester.pumpAndSettle();
    final card = find.byKey(const ValueKey('vip-prediction-mariage'));
    final labels = find.descendant(of: card, matching: find.byType(Text));
    final texts =
        tester.widgetList<Text>(labels).map((text) => text.data!).toList();
    expect(texts.map((t) => t.replaceAll(' ', '')),
        ['12x34', '07×09', '18x20', '45', '60', 'MARIAGE']);
    final pairs = labels
        .evaluate()
        .where((el) => RegExp(r'[x×]').hasMatch((el.widget as Text).data!))
        .toList();
    expect(pairs, hasLength(3));
    for (var i = 1; i < pairs.length; i++) {
      final previous = tester.getRect(find.byWidget(pairs[i - 1].widget));
      final current = tester.getRect(find.byWidget(pairs[i].widget));
      expect(current.top, greaterThanOrEqualTo(previous.bottom));
    }
    expect(tester.takeException(), isNull);
  });

  if (exportDirectory.isNotEmpty) {
    for (final size in [const Size(390, 844), const Size(1440, 900)]) {
      testWidgets('export representative VIP page at ${size.width}',
          (tester) async {
        _setViewport(tester, size, Brightness.dark);
        final key = GlobalKey();
        await tester.pumpWidget(RepaintBoundary(
          key: key,
          child: _app(_member(prediction: _previewSelection, hasPhoto: true)),
        ));
        await tester.pumpAndSettle();
        for (final value in ['12 x 34', '07×09', '048', '0087', '04-17-62']) {
          expect(find.text(value), findsOneWidget);
        }
        final mobile = size.width == 390;
        await _save(
            tester, key, mobile ? 'composition-mobile' : 'composition-web');
        if (mobile) {
          final last = find.byKey(const ValueKey('vip-prediction-extra'));
          final navigation = find.byType(BottomNavigationBar);
          final clipped =
              tester.getRect(last).bottom - tester.getRect(navigation).top;
          if (clipped > 0) {
            tester.view.physicalSize =
                Size(size.width, size.height + clipped.ceil() + 24);
            await tester.pumpAndSettle();
          }
          expect(tester.getRect(last).bottom,
              lessThanOrEqualTo(tester.getRect(navigation).top));
          await _save(tester, key, 'composition-mobile-complete');
        }
      });
    }
  }

  testWidgets(
      'published slots retain every number, its market and its custom label',
      (tester) async {
    _setViewport(tester, const Size(320, 568), Brightness.dark);
    final historical = PredictionRecord.getDocumentFromData({
      'favori': {
        'boul': ['05', '16', '27', '38']
      },
      'soutni': {
        'name': 'Sélection spéciale',
        'boul': [' ', '007', '08', '09']
      },
    }, MemoryReference('prediction/sparse'));
    await tester
        .pumpWidget(_app(_member(prediction: historical), textScale: 2));
    await tester.pumpAndSettle();
    expect(find.text('Sélection spéciale'), findsOneWidget);
    final market = FFLocalizations(const Locale('fr')).getText('xm4yj0vd');
    final valueWithMarket = find
        .ancestor(of: find.text('007'), matching: find.byType(Column))
        .first;
    expect(find.descendant(of: valueWithMarket, matching: find.text(market)),
        findsOneWidget);
    for (final number in ['05', '16', '27', '38', '08', '09']) {
      expect(find.text(number), findsOneWidget);
    }
    _expectPredictionGrid(tester, 1);
    expect(find.text('GG-NY'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'member waits for the profile, sees an empty feed and retries an interrupted feed',
      (tester) async {
    _setViewport(tester, const Size(390, 844), Brightness.dark);
    final messenger = tester.binding.defaultBinaryMessenger;
    const codec = StandardMethodCodec(
        FirebaseFirestoreHostApi.codec as StandardMessageCodec);
    const prefix = 'plugins.flutter.io/firebase_firestore/query/';
    final subscriptions = <String>[];
    final listeners = <String>{};
    messenger.setMockMessageHandler(
      'dev.flutter.pigeon.cloud_firestore_platform_interface.FirebaseFirestoreHostApi.querySnapshot',
      (_) async {
        final id = 'vip-test-${subscriptions.length}';
        subscriptions.add(id);
        messenger.setMockMethodCallHandler(MethodChannel('$prefix$id'),
            (call) async {
          if (call.method == 'listen') listeners.add(id);
          if (call.method == 'cancel') listeners.remove(id);
          return null;
        });
        return const StandardMessageCodec().encodeMessage([id]);
      },
    );
    const badgeId = 'vip-local-config';
    const badgeChannel =
        'plugins.flutter.io/firebase_firestore/document/$badgeId';
    messenger.setMockMessageHandler(
      'dev.flutter.pigeon.cloud_firestore_platform_interface.FirebaseFirestoreHostApi.documentReferenceSnapshot',
      (_) async => const StandardMessageCodec().encodeMessage([badgeId]),
    );
    messenger.setMockMethodCallHandler(
        const MethodChannel(badgeChannel), (_) async => null);
    currentUser = _Member();
    addTearDown(() {
      currentUser = null;
      currentUserDocument = null;
    });

    await tester.pumpWidget(_app(const VipWidget()));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(subscriptions, isEmpty);

    final now = DateTime.now();
    final expiry = now.add(const Duration(days: 30));
    currentUserDocument = UserRecord.getDocumentFromData({
      'end_sub': expiry,
      'member_time': 1,
      'display_name': 'Member Intake',
      'photo_url': photoUrl,
    }, MemoryReference('user/vip-local-member'));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_app(const VipWidget()));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // The active profile can read its renewal history, badge and prediction.
    expect(listeners.length, greaterThanOrEqualTo(2));
    expect(find.text('Member Intake'), findsOneWidget);
    expectPortrait(tester);
    Future<void> broadcast(Iterable<String> ids, ByteData event) async {
      for (final id in ids.toList()) {
        await messenger.handlePlatformMessage('$prefix$id', event, (_) {});
      }
      await tester.pump();
      await tester.pump();
    }

    await messenger.handlePlatformMessage(
        badgeChannel,
        codec.encodeSuccessEnvelope([
          'vip_badges/config',
          {
            'tiers': [
              for (final t in defaultVipBadges) {'name': t.name, 'days': t.days}
            ]
          },
          [false, false]
        ]),
        null);
    final emptyState = find.text('Aucune prédiction disponible.');
    String? predictionListener;
    for (final id in listeners.toList()) {
      final previouslyEmpty = emptyState.evaluate().isNotEmpty;
      await broadcast(
          [id],
          codec.encodeSuccessEnvelope([
            [],
            [],
            [false, false]
          ]));
      if (!previouslyEmpty && emptyState.evaluate().isNotEmpty) {
        predictionListener = id;
      }
    }
    expect(predictionListener, isNotNull);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    // Both receipt listeners receive the same confirmed payment. The badge uses
    // elapsed days, so this 45-day interval earns the 30-day tier.
    await broadcast(
        listeners.where((id) => id != predictionListener),
        codec.encodeSuccessEnvelope([
          [
            [
              'payment_transactions/local-receipt',
              {
                'user_uid': 'vip-local-member',
                'transaction_type': 'subscription',
                'created_at': now.subtract(const Duration(days: 45)),
                'new_end_sub': expiry,
                'member_time_before': 0,
                'member_time_after': 1,
              },
              [false, false],
            ],
          ],
          [],
          [false, false],
        ]));
    expect(find.byKey(const ValueKey('vip-medal-2')), findsOneWidget);
    await broadcast(
        [predictionListener!],
        codec.encodeErrorEnvelope(
            code: 'unavailable', message: 'local test disconnection'));
    final retry = find.byKey(const ValueKey('vip-prediction-retry'));
    expect(retry.hitTestable(), findsOneWidget);
    expect(find.text('local test disconnection'), findsNothing);
    final beforeRetry = subscriptions.toSet();
    await tester.tap(retry);
    await tester.pump();
    await tester.pump();
    final reconnected = listeners.difference(beforeRetry);
    expect(reconnected, hasLength(1));
    await broadcast(
        reconnected,
        codec.encodeSuccessEnvelope([
          [
            [
              'prediction/recovered',
              {
                'favori': {
                  'name': 'FAVORI',
                  'boul': ['047']
                },
              },
              [false, false],
            ],
          ],
          [],
          [false, false],
        ]));
    expect(find.text('047'), findsOneWidget);
    expect(retry, findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('prediction with no numbers omits probability when absent',
      (tester) async {
    _setViewport(tester, const Size(320, 568), Brightness.dark);
    final empty = PredictionRecord.getDocumentFromData({
      'favori': {
        'boul': ['']
      },
    }, MemoryReference('prediction/empty'));
    await tester.pumpWidget(_app(_member(prediction: empty)));
    await tester.pumpAndSettle();
    expect(find.text('—'), findsNWidgets(7));
    expect(find.text('0%'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
