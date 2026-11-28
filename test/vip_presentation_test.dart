import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:choloto/vip/universal_v_i_p/universal_v_i_p_widget.dart';
import 'package:choloto/vip/v_i_pboloto/v_i_pboloto_widget.dart';
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

PredictionRecord _selection(String fixture, Map<String, List<String>> values,
    {Map<String, String> titles = const {}}) {
  return PredictionRecord.getDocumentFromData({
    'date': DateTime(2026, 11, 24),
    'periode': 'Soir',
    'pourcentage': 85,
    for (final entry in values.entries)
      entry.key: {
        'boul': entry.value,
        if (titles.containsKey(entry.key)) 'name': titles[entry.key]
      },
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
      onHistory: onHistory ?? _noAction,
      onTip: onTip ?? _noAction,
      headerBuilder: (inset) => VipBadgeView(
        tiers: defaultVipBadges,
        time: (elapsed: const Duration(days: 90), days: 90, partial: false),
        active: true,
        showCollection: false,
        expandedBuilder: (badgeName, medal) => VipPageHeader(
          inset: inset,
          memberName: name,
          avatar:
              VipHeaderAvatar(name: name, photoUrl: hasPhoto ? photoUrl : ''),
          badgeName: badgeName,
          memberMedal: medal,
          onProfile: onProfile ?? _noAction,
          onBack: onBack,
        ),
      ),
      content: VipPredictionPanel(prediction: prediction ?? _example),
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

const _singleRows = [1, 1, 1, 1, 1, 1, 1];
const _compactRows = [2, 2, 2, 1];
const _wideRows = [2, 2, 3];

void _expectPredictionGrid(WidgetTester tester, List<int> rowSizes) {
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
  final panel = tester.getRect(find.byType(VipPredictionPanel));
  var index = 0;
  for (final count in rowSizes) {
    final row = cards.sublist(index, index + count);
    expect(row.first.left, closeTo(panel.left, 1));
    expect(row.last.right, closeTo(panel.right, 1));
    if (index > 0) expect(row.first.top, greaterThan(cards[index - 1].bottom));
    for (var i = 1; i < row.length; i++) {
      expect(row[i].left, greaterThan(row[i - 1].right));
      expect(row[i].top, closeTo(row.first.top, 1));
      expect(row[i].bottom, closeTo(row.first.bottom, 1));
      expect(row[i].width, closeTo(row.first.width, 1));
    }
    index += count;
  }
  expect(index, cards.length);
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

String _visibleText(Text widget) =>
    widget.data ?? widget.textSpan!.toPlainText(includeSemanticsLabels: false);

Finder _publishedValue(String value) {
  if (RegExp(r'^\d+\s*[xX×]\s*\d+$').hasMatch(value)) {
    return find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == value);
  }
  return find.text(value);
}

Future<void> _expectIllustrationContrast(
    WidgetTester tester, RenderRepaintBoundary boundary,
    {Map<String, String> titles = const {}}) async {
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
    final title = titles[category.field] ?? strings.getText(category.label);
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
      if (text == title && titles.containsKey(category.field)) {
        expect(boxes.map((box) => box.top).toSet().length, greaterThan(1),
            reason: 'The entire custom title should wrap');
        final merged =
            find.descendant(of: card, matching: find.byType(MergeSemantics));
        final announcement = tester.getSemantics(merged).label.split('\n');
        expect(announcement.first, title);
        expect(announcement.where((label) => label == title), hasLength(1));
      }
      if (text != title) {
        expect(tester.getRect(find.byWidget(widget)).bottom,
            lessThanOrEqualTo(captionRect.top),
            reason: '${category.id} · $text');
      }
      samples.add((
        description: '${category.id} · $text',
        color: paragraph.text.style!.color!,
        paragraph: paragraph,
        original: paragraph.text,
        lines: [
          for (final box in boxes)
            MatrixUtils.transformRect(transform, box.toRect())
        ],
      ));
    }
  }

  // Black ink makes a coverage mask even when a light glyph coincides with
  // a bright highlight. Invisible ink then exposes the actual backdrop under
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
          // The green channel separates the white and gold ink from black.
          // Ignore only the faint antialiasing at the glyph's edge.
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

  Completer<void>? delayMarketFont;
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
      if (path.startsWith('__test_fonts/')) {
        if (path.endsWith('Inter-SemiBold.ttf') && delayMarketFont != null) {
          await delayMarketFont!.future;
        }
        if (interFont.isNotEmpty) {
          final variant =
              File('${File(interFont).parent.path}/${path.split('/').last}');
          if (variant.existsSync()) {
            return ByteData.sublistView(variant.readAsBytesSync());
          }
        }
        return fontBytes;
      }
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

  testWidgets('cold VIP market columns follow the loaded font in place',
      (tester) async {
    _setViewport(tester, const Size(390, 844), Brightness.dark);
    delayMarketFont = Completer<void>();
    try {
      await tester.pumpWidget(_app(Scaffold(
        body: SingleChildScrollView(
            child: VipPredictionPanel(prediction: _example)),
      )));
    } finally {
      delayMarketFont!.complete();
      delayMarketFont = null;
    }
    final card = find.byKey(const ValueKey('vip-prediction-favorite'));
    final mounted = tester.element(card);
    await tester.pump();
    await tester.runAsync(() => GoogleFonts.pendingFonts());
    await tester.pump();

    final market = find.descendant(of: card, matching: find.text('FLO-NY'));
    final number = find.descendant(of: card, matching: find.text('07'));
    final label = tester.renderObject<RenderParagraph>(market);
    final gap = FlutterFlowTheme.of(mounted).designToken.spacing.sm;
    final measured = TextPainter(
        text: label.text,
        textDirection: ui.TextDirection.ltr,
        textScaler: label.textScaler)
      ..layout();
    final expectedOffset = measured.width.ceilToDouble() + gap;
    measured.dispose();
    expect(tester.element(card), same(mounted));
    expect(tester.getTopLeft(number).dx - tester.getTopLeft(market).dx,
        closeTo(expectedOffset, .1));
  });

  testWidgets(
      'VIP header fades vertically from amethyst to the page background',
      (tester) async {
    _setViewport(tester, const Size(390, 844), Brightness.dark);
    final key = GlobalKey();
    final tokens = DarkModeTheme().designToken;
    final background = tokens.background.home;
    await tester.pumpWidget(_app(Scaffold(
      backgroundColor: background,
      body: RepaintBoundary(
        key: key,
        child: ColoredBox(
          color: background,
          child: const VipPageHeader(
            inset: 16,
            memberName: 'Mika Jean',
            avatar: VipHeaderAvatar(name: 'Mika Jean', photoUrl: ''),
            onProfile: _noAction,
          ),
        ),
      ),
    )));
    await tester.pumpAndSettle();
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final pixels = await _readPixels(tester, boundary);
    final header = tester.getRect(find.byType(VipPageHeader));
    Color pixelAt(Offset point) {
      final local = boundary.globalToLocal(point);
      final offset = (local.dy.floor() * pixels.width + local.dx.floor()) * 4;
      return Color.fromARGB(
        pixels.rgba.getUint8(offset + 3),
        pixels.rgba.getUint8(offset),
        pixels.rgba.getUint8(offset + 1),
        pixels.rgba.getUint8(offset + 2),
      );
    }

    final x = header.left + 2;
    final start = pixelAt(Offset(x, header.top + 1));
    final middle = pixelAt(Offset(x, header.center.dy));
    final end = pixelAt(Offset(x, header.bottom - 1));
    // Raster dithering can vary a channel by one level across the same row.
    expect(pixelAt(Offset(header.right - 2, header.top + 1)),
        isSameColorAs(start, threshold: .005));
    expect(pixelAt(Offset(header.right - 2, header.center.dy)),
        isSameColorAs(middle, threshold: .005));
    expect(start.b, greaterThan(start.r));
    expect(start.r, greaterThan(start.g));
    expect(start.computeLuminance(), greaterThan(middle.computeLuminance()));
    expect(middle.computeLuminance(), greaterThan(end.computeLuminance()));
    expect(
        end.computeLuminance(), closeTo(background.computeLuminance(), .001));
  });

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
        final label = tester.widget<Text>(
            find.text('Probabilité : mercredi 30 septembre 2026 Soir'));
        final tokens = FlutterFlowTheme.of(
                tester.element(find.byType(VipPredictionHeader)))
            .designToken
            .vip;
        expect(
            label.style!.fontFamily, tokens.typography.supporting.fontFamily);
        if (percentage != null) {
          final percent = tester.widget<Text>(find.text(percentage));
          expect(percent.style,
              tokens.typography.numeral(18).copyWith(color: tokens.numberText));
        }
      });
    }
  }

  testWidgets(
      'VIP action pills stay in opposite corners while the final card scrolls clear',
      (tester) async {
    _setViewport(tester, const Size(320, 568), Brightness.dark);
    final opened = <String>[];
    await tester.pumpWidget(_app(_member(
      onHistory: () => opened.add('history'),
      onTip: () => opened.add('tip'),
    )));
    await tester.pumpAndSettle();
    final history = find.byKey(const ValueKey('vip-history-button'));
    final tip = find.byKey(const ValueKey('vip-tip-button'));
    final left = tester.getRect(history);
    final right = tester.getRect(tip);
    final nav = tester.getRect(find.byType(BottomNavigationBar));
    expect(tester.getRect(find.text('Historique')).center.dx,
        lessThan(nav.center.dx));
    expect(tester.getRect(find.text('Pourboire')).center.dx,
        greaterThan(nav.center.dx));
    expect(left.left, closeTo(16, 1));
    expect(right.right, closeTo(nav.right - 16, 1));
    expect(left.bottom, closeTo(right.bottom, .01));
    expect(left.bottom, closeTo(nav.top - kFloatingActionButtonMargin, 1));
    await tester.drag(
        find.byKey(const PageStorageKey('vip-scroll')), const Offset(0, -1600));
    await tester.pumpAndSettle();
    expect(tester.getRect(history), left);
    expect(tester.getRect(tip), right);
    final last =
        tester.getRect(find.byKey(const ValueKey('vip-prediction-extra')));
    expect(last.bottom, lessThan(left.top));
    await tester.tap(history);
    await tester.tap(tip);
    expect(opened, ['history', 'tip']);
    expect(tester.takeException(), isNull);
  });

  const viewports = [
    Size(320, 568),
    Size(390, 844),
    Size(810, 1080),
    Size(1440, 900)
  ];
  for (final language in ['fr', 'en', 'cr']) {
    final strings = FFLocalizations(Locale(language));
    final badgeLabel = strings.getVariableText(
        frText: 'Membre Discipliné',
        enText: 'Disciplined Member',
        crText: 'Manm Disipline');
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
            final title =
                find.text(member ? 'Mika Jean' : strings.getText('gfj3b9xn'));
            expect(title, findsOneWidget);
            expect(Theme.of(tester.element(title)).brightness, Brightness.dark);
            expect(find.byKey(const ValueKey('vip-page-medal')),
                member ? findsNothing : findsOneWidget);
            final frame = find.byKey(const ValueKey('vip-medal-frame'));
            final medal = find.descendant(
                of: frame,
                matching: find.byKey(ValueKey(
                  member ? 'vip-medal-3' : 'vip-page-medal',
                )));
            expect(medal, findsOneWidget);
            expect(tester.getCenter(frame), tester.getCenter(medal));
            expect(tester.getSize(frame).width,
                greaterThan(tester.getSize(medal).width));
            if (member) {
              final badge = find.text(badgeLabel);
              expect(badge, findsOneWidget);
              expect(tester.getRect(badge).top,
                  greaterThan(tester.getRect(title).bottom));
              expect(find.text(strings.getText('gfj3b9xn')), findsNothing);
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
            final header = tester.getRect(find.byType(VipPageHeader));
            final section = tester.getRect(member
                ? find.byType(VipPredictionPanel)
                : find.byKey(const ValueKey('vip-monthly-offer-card')));
            if (size.width >= 810) {
              expect(header.right, lessThan(section.left));
              expect(section.top, inInclusiveRange(header.top, header.bottom));
            } else {
              expect(header.bottom, lessThan(section.top));
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
                expect(_publishedValue(value), findsOneWidget);
              }
              expect(favorite, findsOneWidget);
              expect(soutni, findsOneWidget);

              _expectPredictionGrid(
                  tester, size.width == 1440 ? _wideRows : _compactRows);
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
      final badgeTitle = find.text(badgeLabel);
      expect(
          tester.getRect(badgeTitle).top,
          greaterThan(tester
              .getRect(find.text('Marie-Claire Jean-Baptiste Desrosiers'))
              .bottom));
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
      expect(
          find.descendant(
              of: find.byType(BottomSheet),
              matching:
                  find.text(vipBadgeName(strings, defaultVipBadges[2].name))),
          findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('close-vip-medal')));
      await tester.pumpAndSettle();
      _expectPredictionGrid(tester, _singleRows);
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

  testWidgets('the 152-pixel historical VIP cards use the same type roles',
      (tester) async {
    _setViewport(tester, const Size(390, 844), Brightness.dark);
    await tester.pumpWidget(_app(const Center(
      child: Wrap(children: [
        SizedBox.square(
            dimension: 152,
            child: UniversalVIPWidget(
                name: 'FAVORI', chiffre: ['07'], icon: Icon(Icons.star))),
        SizedBox.square(
            dimension: 152,
            child: UniversalVIPWidget(
                name: 'SOUTNI', chiffre: ['04', '68'], icon: Icon(Icons.star))),
        SizedBox.square(
            dimension: 152,
            child: VIPbolotoWidget(name: 'BOLOTO', chiffre: ['87'])),
      ]),
    )));
    await tester.pump();
    final theme = FlutterFlowTheme.of(
        tester.element(find.byType(UniversalVIPWidget).first));
    final vip = theme.designToken.vip;
    final type = vip.typography;
    for (final (number, color) in [
      ('07', vip.numberText),
      ('04', vip.numberText),
      ('87', theme.onPrimary)
    ]) {
      final value =
          find.byWidgetPredicate((w) => w is AutoSizeText && w.data == number);
      final base = type.numeral(32).copyWith(color: color);
      expect(tester.widget<AutoSizeText>(value).style,
          number == '87' ? base : base.copyWith(height: 1));
      final rendered = tester.widget<Text>(find.text(number));
      expect(rendered.style!.fontSize, inInclusiveRange(25, 32));
      expect(rendered.style!.fontFeatures,
          contains(const ui.FontFeature.tabularFigures()));
    }
    for (final label in ['FAVORI', 'SOUTNI', 'BOLOTO']) {
      final rendered = tester.widget<Text>(find.text(label)).style!;
      final role = type.category(compact: true);
      expect(rendered.fontSize, role.fontSize);
      expect(rendered.letterSpacing, role.letterSpacing);
      expect(rendered.fontVariations, role.fontVariations);
    }
    for (final market in ['GG-NY', 'FLO-NY']) {
      final labels = tester.widgetList<Text>(find.text(market)).toList();
      expect(labels, hasLength(market == 'GG-NY' ? 1 : 2));
      for (final label in labels) {
        expect(label.style, type.market);
      }
    }
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final (size, scale) in [
    (const Size(390, 844), 1.0),
    (const Size(320, 568), 2.0),
    (const Size(1440, 900), 1.0),
  ]) {
    testWidgets(
        'VIP typography preserves figure widths at ${size.width} × $scale',
        (tester) async {
      _setViewport(tester, size, Brightness.dark);
      final prediction = _selection('tabular-figures', {
        'favori': ['07', '81'],
        'soutni': ['42', '65'],
        'chif4': ['1111', '8888', '0087'],
      });
      final page = _app(_member(prediction: prediction), textScale: scale);
      await tester.pumpWidget(page);
      await tester.runAsync(() => GoogleFonts.pendingFonts());
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      RenderParagraph paragraph(String content) =>
          tester.renderObject<RenderParagraph>(find.descendant(
              of: find.text(content), matching: find.byType(RichText)));
      final type =
          FlutterFlowTheme.of(tester.element(find.byType(VipPredictionPanel)))
              .designToken
              .vip
              .typography;
      void expectRole(TextStyle rendered, TextStyle role) {
        expect(rendered.fontFamily, role.fontFamily);
        expect(rendered.fontSize, role.fontSize);
        expect(rendered.fontWeight, role.fontWeight);
        expect(rendered.fontVariations, role.fontVariations);
        expect(rendered.letterSpacing, role.letterSpacing);
      }

      for (final heading in ['Mika Jean', 'Mardi 24 novembre']) {
        final style = paragraph(heading).text.style!;
        expectRole(style, type.heading(style.fontSize!));
      }
      final panel = find.byType(VipPredictionPanel);
      final poster =
          type.posterTitle(compact: tester.getSize(panel).width / scale < 640);
      final strings = FFLocalizations.of(tester.element(panel));
      for (final category in _categories) {
        final caption = paragraph(strings.getText(category.label)).text.style!;
        expectRole(caption, poster);
        expect(caption.color, poster.color);
      }
      final numbers = ['1111', '8888', '0087'];
      final advances = <double>[];
      for (final value in numbers) {
        final rendered = paragraph(value);
        final style = rendered.text.style!;
        expectRole(style, type.numeral(style.fontSize!));
        expect(style.fontFamily?.toLowerCase(), 'google sans flex');
        expect(style.fontFeatures,
            contains(const ui.FontFeature.tabularFigures()));
        expect(rendered.didExceedMaxLines, isFalse);
        final glyphs = [
          for (var i = 0; i < value.length; i++)
            rendered
                .getBoxesForSelection(
                    TextSelection(baseOffset: i, extentOffset: i + 1))
                .single
                .toRect(),
        ];
        final em = rendered.textScaler.scale(style.fontSize!);
        for (final glyph in glyphs) {
          expect(glyph.width, greaterThan(em * .3), reason: value);
          expect(glyph.width, closeTo(glyphs.first.width, .05), reason: value);
          expect(glyph.top, closeTo(glyphs.first.top, .05), reason: value);
        }
        for (var i = 1; i < glyphs.length; i++) {
          expect(glyphs[i].left, closeTo(glyphs[i - 1].right, .05));
        }
        advances.add(glyphs.last.right - glyphs.first.left);
      }
      expect(advances[1], closeTo(advances.first, .05));
      expect(advances[2], closeTo(advances.first, .05));
      final market = paragraph('GG-NY').text.style!;
      expectRole(market, type.market);
      expect(market.fontFamily, startsWith('Inter'));
      expect(market.fontWeight, FontWeight.w600);
      expect(market.fontSize, greaterThanOrEqualTo(12));
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [320.0, 639.0, 640.0, 1100.0]) {
    testWidgets('prediction cards fill their rows at $width', (tester) async {
      _setViewport(tester, Size(width, 900), Brightness.dark);
      await tester.pumpWidget(_app(Scaffold(
          body: SingleChildScrollView(
        child: VipPredictionPanel(prediction: _previewSelection),
      ))));
      await tester.pumpAndSettle();
      _expectPredictionGrid(tester, width < 640 ? _compactRows : _wideRows);
      final first = tester.getRect(find.text('18'));
      final second = tester.getRect(find.text('72'));
      final third = tester.getRect(find.text('53'));
      expect(second.top, closeTo(first.top, 1));
      expect(second.left, greaterThan(first.right));
      if (width == 320) {
        expect(third.top, greaterThan(first.bottom));
        expect(third.left, closeTo(first.left, 1));
      } else {
        expect(third.top, closeTo(first.top, 1));
        expect(third.left, greaterThan(second.right));
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('decorative prediction separators follow visible data groups',
      (tester) async {
    const selections = {
      'favori': ['07', '81', '16', '42'],
      'soutni': [' ', '65'],
      'boloto': ['08', '19', '74', '56'],
      'mariage': ['12 x 34', '07×09'],
      'chif3': ['007', '308', '419'],
      'chif4': ['0087'],
      'extra': <String>[],
    };
    final strings = FFLocalizations(const Locale('fr'));
    for (final (width, scale) in [(390.0, 1.0), (1440.0, 1.0), (320.0, 2.0)]) {
      _setViewport(tester, Size(width, 900), Brightness.dark);
      await tester.pumpWidget(_app(
          _member(prediction: _selection('separators', selections)),
          textScale: scale));
      await tester.pumpAndSettle();
      for (final category in _categories) {
        final card = find.byKey(ValueKey('vip-prediction-${category.id}'));
        Finder within(Finder matcher) =>
            find.descendant(of: card, matching: matcher);
        Rect valueRect(String value) =>
            tester.getRect(within(find.text(value)));
        final entries = selections[category.field]!
            .where((v) => v.trim().isNotEmpty)
            .toList();
        final spoken = switch (category.id) {
          'favorite' => ['FLO-NY', '07', 'FLO-NY', '81', '16', '42'],
          'soutni' => ['FLO-NY', '65'],
          'extra' => [strings.getText('viphstnos')],
          _ => entries,
        };
        final merged = within(find.byType(MergeSemantics));
        expect(tester.getSemantics(merged).label.split('\n'),
            [strings.getText(category.label), ...spoken],
            reason: category.id);

        final horizontal = within(find.byType(Divider));
        expect(horizontal, findsNWidgets(category.id == 'favorite' ? 2 : 0));
        if (category.id == 'favorite') {
          final markets = within(find.text('FLO-NY'));
          for (final (index, above, below) in [
            (0, '07', '81'),
            (1, '81', '16')
          ]) {
            final line = tester.getRect(horizontal.at(index));
            expect(line.left, closeTo(tester.getRect(markets.first).left, 1));
            expect(line.right, lessThanOrEqualTo(valueRect(above).right + 1));
            expect(line.center.dy, greaterThan(valueRect(above).bottom));
            expect(line.center.dy, lessThan(valueRect(below).top));
          }
        }

        final freeValues = switch (category.id) {
          'favorite' => entries.skip(2),
          'mariage' || 'soutni' => <String>[],
          _ => entries,
        };
        final values = freeValues.map(valueRect).toList();
        final vertical = within(find.byType(VerticalDivider));
        var count = 0;
        for (var i = 1; i < values.length; i++) {
          final left = values[i - 1];
          final right = values[i];
          if ((right.top - left.top).abs() > 1) continue;
          final line = tester.getRect(vertical.at(count++));
          expect(line.center.dx, greaterThan(left.right));
          expect(line.center.dx, lessThan(right.left));
          expect(line.center.dy, inInclusiveRange(right.top, right.bottom));
        }
        expect(vertical, findsNWidgets(count), reason: category.id);
      }
    }
  });

  for (final scenario in [
    (width: 390.0, scale: 1.0, rows: _compactRows, emptyExtra: false),
    (width: 320.0, scale: 2.0, rows: _singleRows, emptyExtra: false),
    (width: 320.0, scale: 2.0, rows: _singleRows, emptyExtra: true),
    (width: 880.0, scale: 1.0, rows: _wideRows, emptyExtra: false),
  ]) {
    testWidgets(
        'prediction ink stays legible on all illustrations at ${scenario.width} × ${scenario.scale} (empty Extra: ${scenario.emptyExtra})',
        (tester) async {
      _setViewport(tester, Size(scenario.width, 3600), Brightness.dark);
      final values = {
        ..._fullSelection,
        if (scenario.emptyExtra) 'extra': <String>[],
      };
      final titles = <String, String>{
        if (scenario.emptyExtra)
          'soutni': 'Sélection de la Floride et de New York',
      };
      final key = GlobalKey();
      final page = _app(
          Scaffold(
            body: SingleChildScrollView(
              child: RepaintBoundary(
                key: key,
                child: VipPredictionPanel(
                    prediction: _selection('density', values, titles: titles)),
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
      _expectPredictionGrid(tester, scenario.rows);
      final date = tester.getRect(find.text('Mardi 24 novembre'));
      final period = tester.getRect(find.text('Soir'));
      final probability = tester.getRect(find.text('Probabilité'));
      final percent = tester.getRect(find.text('85%'));
      expect(period.left, closeTo(date.left, 1));
      expect(period.top, greaterThanOrEqualTo(date.bottom - 1));
      expect(percent.top, greaterThanOrEqualTo(probability.bottom - 1));
      if (scenario.scale == 2) {
        expect(probability.top, greaterThan(period.bottom));
        expect(percent.left, closeTo(date.left, 1));
      } else {
        expect(probability.left, greaterThan(date.right));
        expect(probability.top, closeTo(date.top, 1));
        expect(percent.right, closeTo(probability.right, 1));
      }
      for (final category in _categories) {
        final card = find.byKey(ValueKey('vip-prediction-${category.id}'));
        final published = values[category.field]!;
        final expected = published.isEmpty ? ['—'] : published;
        for (final value in expected) {
          expect(find.descendant(of: card, matching: _publishedValue(value)),
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
        expect(tester.widgetList<Text>(markets).map(_visibleText),
            [category.id == 'soutni' ? 'GG-NY' : 'FLO-NY', 'FLO-NY']);
        expect(numbers[1].top, greaterThanOrEqualTo(numbers[0].bottom - 1));
        expect(numbers[1].left, closeTo(numbers[0].left, 1));
        final firstMarket = tester.getRect(markets.first);
        for (var i = 0; i < 2; i++) {
          final market = tester.getRect(markets.at(i));
          expect(market.left, closeTo(firstMarket.left, 1));
          expect(market.right, lessThan(numbers[i].left));
          expect(market.center.dy, closeTo(numbers[i].center.dy, 1));
          for (final unlabelled in numbers.skip(2)) {
            expect(unlabelled.top, greaterThan(numbers[1].bottom),
                reason: '${category.id}: unlabelled value under a market');
          }
        }
        expect(numbers[2].left, closeTo(firstMarket.left, 1));
        expect(numbers[3].top, closeTo(numbers[2].top, 1));
        expect(numbers[3].left, greaterThan(numbers[2].right));
      }
      for (final field in ['boloto', 'chif3']) {
        final rects = [
          for (final value in values[field]!) tester.getRect(find.text(value)),
        ];
        expect(rects[1].top, closeTo(rects[0].top, 1), reason: field);
        expect(rects[1].left, greaterThan(rects[0].right), reason: field);
        expect(rects[2].top, greaterThan(rects[0].bottom), reason: field);
        expect(rects[2].left, closeTo(rects[0].left, 1), reason: field);
        expect(rects[3].top, closeTo(rects[2].top, 1), reason: field);
        expect(rects[3].left, closeTo(rects[1].left, 1), reason: field);
      }
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await _expectIllustrationContrast(tester, boundary, titles: titles);
      if (exportDirectory.isNotEmpty && titles.isNotEmpty) {
        await _save(tester, key, 'titre-personnalise-200');
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final (width, scale) in [(320.0, 1.0), (390.0, 1.0), (320.0, 2.0)]) {
    testWidgets(
        'long market values and four-digit selections fit at $width × $scale',
        (tester) async {
      _setViewport(tester, Size(width, 844), Brightness.dark);
      const longValues = ['0000000007', '01-23-45-6'];
      final prediction = _selection('long-markets', {
        'favori': longValues,
        'soutni': longValues.reversed.toList(),
        'chif4': _fullSelection['chif4']!,
        'mariage': ['0000000007×09'],
      });
      await tester
          .pumpWidget(_app(_member(prediction: prediction), textScale: scale));
      await tester.pumpAndSettle();
      _expectPredictionGrid(tester, scale == 2 ? _singleRows : _compactRows);
      for (final category in ['favorite', 'soutni']) {
        final card = find.byKey(ValueKey('vip-prediction-$category'));
        final labels =
            find.descendant(of: card, matching: find.textContaining('-NY'));
        final expected =
            category == 'favorite' ? longValues : longValues.reversed.toList();
        for (final (index, value) in expected.indexed) {
          final findValue =
              find.descendant(of: card, matching: find.text(value));
          final number = tester.getRect(findValue);
          final market = tester.getRect(labels.at(index));
          final inline = market.right <= number.left &&
              (market.center.dy - number.center.dy).abs() <= 1;
          final stacked = market.bottom <= number.top + 1 &&
              (market.left - number.left).abs() <= 1;
          expect(inline || stacked, isTrue,
              reason: '$category · $value · $market → $number');
        }
      }
      final numbers = [
        for (final value in _fullSelection['chif4']!)
          tester.getRect(find.text(value)),
      ];
      expect(_publishedValue('0000000007×09'), findsOneWidget);
      expect(tester.widget<Text>(find.text('0008')).style!.fontSize,
          width == 390 ? 28 : 32);
      if (width == 390) {
        expect(numbers[1].top, closeTo(numbers[0].top, 1));
        expect(numbers[1].left, greaterThan(numbers[0].right));
        expect(numbers[2].top, greaterThan(numbers[0].bottom));
        expect(numbers[3].left, closeTo(numbers[1].left, 1));
        expect(numbers[3].top, closeTo(numbers[2].top, 1));
      } else {
        for (var i = 1; i < numbers.length; i++) {
          expect(numbers[i].top, greaterThan(numbers[i - 1].bottom));
          expect(numbers[i].left, closeTo(numbers[0].left, 1));
        }
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'fragmented marriages keep each published pair and unpaired number',
      (tester) async {
    _setViewport(tester, const Size(390, 844), Brightness.dark);
    final prediction = _selection('fragmented-marriages', {
      'mariage': [
        '63×81',
        '12',
        'x',
        '34',
        '07',
        '×',
        '09',
        '18 x',
        '20',
        '45',
        '60'
      ],
    });
    await tester.pumpWidget(_app(_member(prediction: prediction)));
    await tester.pumpAndSettle();
    final card = find.byKey(const ValueKey('vip-prediction-mariage'));
    final firstTerms = <Rect>[];
    final secondTerms = <Rect>[];
    final signs = <Rect>[];
    final type =
        FlutterFlowTheme.of(tester.element(card)).designToken.vip.typography;
    const published = ['63×81', '12 x 34', '07 × 09', '18 x 20'];
    for (final (i, raw) in published.indexed) {
      final pair = find.descendant(
          of: card, matching: find.byKey(ValueKey('vip-marriage-pair-$i')));
      expect(tester.widget<Semantics>(pair).properties.label, raw);
      expect(find.bySemanticsLabel(RegExp(RegExp.escape(raw))), findsOneWidget);
      final fields = RegExp(r'^(\d+)\s*([x×])\s*(\d+)$').firstMatch(raw)!;
      final terms = [
        for (var part = 1; part <= 3; part++)
          find.descendant(of: pair, matching: find.text(fields[part]!)),
      ];
      final first = tester.getRect(terms[0]);
      final sign = tester.getRect(terms[1]);
      final second = tester.getRect(terms[2]);
      expect(sign.left, greaterThan(first.right));
      expect(second.left, greaterThan(sign.right));
      expect(sign.left - first.right, closeTo(second.left - sign.right, 2));
      final numeric = tester.widget<Text>(terms[0]).style!;
      expect(
          tester.widget<Text>(terms[2]).style!.fontWeight, numeric.fontWeight);
      expect(tester.widget<Text>(terms[1]).style!.fontWeight,
          type.pairSeparator(numeric).fontWeight);
      firstTerms.add(first);
      secondTerms.add(second);
      signs.add(sign);
    }
    for (var i = 1; i < published.length; i++) {
      expect(firstTerms[i].top, greaterThanOrEqualTo(firstTerms[i - 1].bottom));
      expect(signs[i].center.dx, closeTo(signs.first.center.dx, 1));
      expect(secondTerms[i].left, closeTo(secondTerms.first.left, 1));
    }
    for (final unpaired in ['45', '60']) {
      expect(find.descendant(of: card, matching: find.text(unpaired)),
          findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  if (exportDirectory.isNotEmpty) {
    for (final size in [const Size(390, 844), const Size(1440, 900)]) {
      testWidgets(
          'export representative VIP typography at 200% and ${size.width}',
          (tester) async {
        _setViewport(tester, size, Brightness.dark);
        final key = GlobalKey();
        await tester.pumpWidget(RepaintBoundary(
          key: key,
          child: _app(_member(prediction: _previewSelection, hasPhoto: true),
              textScale: 2),
        ));
        await tester.pumpAndSettle();
        final firstCard = find.byKey(const ValueKey('vip-prediction-favorite'));
        await Scrollable.ensureVisible(tester.element(firstCard));
        await tester.pumpAndSettle();
        final screen = size.width == 390 ? 'mobile' : 'web';
        await _save(tester, key, 'composition-$screen-200');
        expect(
            find
                .descendant(of: firstCard, matching: find.text('07'))
                .hitTestable(),
            findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
    for (final preview in [
      (
        name: 'composition',
        data: _previewSelection,
        values: ['12 x 34', '07×09', '048', '0087', '04-17-62']
      ),
      (
        name: 'stress',
        data: _selection('preview-full', _fullSelection),
        values: ['12 x 34', '07×09', '007', '0008', '02-19-40-76']
      ),
    ]) {
      for (final size in [const Size(390, 844), const Size(1440, 900)]) {
        testWidgets('export ${preview.name} VIP page at ${size.width}',
            (tester) async {
          _setViewport(tester, size, Brightness.dark);
          final key = GlobalKey();
          await tester.pumpWidget(RepaintBoundary(
            key: key,
            child: _app(_member(prediction: preview.data, hasPhoto: true)),
          ));
          await tester.pumpAndSettle();
          for (final value in preview.values) {
            expect(_publishedValue(value), findsOneWidget);
          }
          final mobile = size.width == 390;
          final device = mobile ? 'mobile' : 'web';
          await _save(tester, key, '${preview.name}-$device');
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
            await _save(tester, key, '${preview.name}-mobile-complete');
          }
        });
      }
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
    final card = find.byKey(const ValueKey('vip-prediction-soutni'));
    final label =
        tester.getRect(find.descendant(of: card, matching: find.text(market)));
    final value = tester.getRect(find.text('007'));
    expect(label.right, lessThan(value.left));
    expect(label.center.dy, closeTo(value.center.dy, 1));
    expect(tester.getRect(find.text('08')).top, greaterThan(value.bottom));
    for (final number in ['05', '16', '27', '38', '08', '09']) {
      expect(find.text(number), findsOneWidget);
    }
    _expectPredictionGrid(tester, _singleRows);
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
    expect(find.text('Compte VIP'), findsNothing);
    expect(find.text('Nouveau Membre'), findsNothing);
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
              for (final t in defaultVipBadges)
                {
                  'name': t.days == 30 ? 'Club Soleil CHOLOTO' : t.name,
                  'days': t.days
                }
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
    expect(find.text('Nouveau Membre'), findsOneWidget);
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
    expect(find.text('Nouveau Membre'), findsNothing);
    expect(tester.getRect(find.text('Club Soleil')).top,
        greaterThan(tester.getRect(find.text('Member Intake')).bottom));
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
