import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '/backend/backend.dart';
import '/components/cross_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'croix_page_layout.dart';
import 'croix_share.dart';
import 'croix_share_platform.dart';
export 'croix_model.dart';

class CroixWidget extends StatefulWidget {
  const CroixWidget({super.key, this.records});

  final Stream<List<CroixRecord>>? records;

  static String routeName = 'croix';
  static String routePath = '/croix';

  @override
  State<CroixWidget> createState() => _CroixWidgetState();
}

class _CroixWidgetState extends State<CroixWidget> {
  final _crossCaptureKey = GlobalKey();
  final _crossKey = GlobalKey<CrossWidgetState>();
  late Stream<List<CroixRecord>> _records;
  ModalRoute<dynamic>? _route;
  int _visit = 0;
  bool _isSharing = false;
  Completer<void>? _preparation;
  int _subscription = 0;
  Uint8List? _preparedJpegBytes;
  Object? _currentVisualSignature;

  Stream<List<CroixRecord>> _watchRecords() =>
      widget.records ??
      CroixRecord.collection
          .orderBy('date', descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map(CroixRecord.fromSnapshot).toList());

  @override
  void initState() {
    super.initState();
    _records = _watchRecords();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'croix'});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
    if (_route?.isCurrent == false) {
      // A pending tap belongs to this visit, even if a covering route is
      // dismissed again before rasterization finishes.
      _visit++;
      _cancelPreparation();
    }
  }

  @override
  void didUpdateWidget(CroixWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.records != oldWidget.records) _restartRecords();
  }

  void _restartRecords() {
    _prepareWhenNeeded(null);
    _records = _watchRecords();
    _subscription++;
  }

  @override
  void dispose() {
    _prepareWhenNeeded(null);
    super.dispose();
  }

  void _cancelPreparation() {
    _preparation?.complete();
    _preparation = null;
  }

  // Different records and layouts can arrive while an earlier JPEG is encoding.
  void _prepareWhenNeeded(Object? signature) {
    if (_currentVisualSignature != signature) {
      _currentVisualSignature = signature;
      _preparedJpegBytes = null;
      _cancelPreparation();
    }
    if (signature == null ||
        _route?.isCurrent == false ||
        _preparation != null ||
        _preparedJpegBytes != null) {
      return;
    }

    final preparation = _preparation = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_preparation == preparation) {
        unawaited(_prepareCroixVisual(preparation));
      }
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  Future<void> _prepareCroixVisual(Completer<void> preparation) async {
    try {
      await Future.any<void>([
        preparation.future,
        Future.wait([
          precacheImage(const AssetImage(CrossWidget.artworkAsset), context),
          precacheImage(const AssetImage(CrossWidget.textureAsset), context),
        ]),
      ]);
      while (mounted && _preparation == preparation) {
        final cross = _crossKey.currentState;
        if (cross == null || _route?.isCurrent == false) return;
        if (cross.waveIsAnimating) {
          await Future.any([cross.waveSettled, preparation.future]);
          if (_preparation != preparation) return;
        }

        // The controller can settle before the resting frame reaches the layer.
        final binding = WidgetsBinding.instance;
        final painted = binding.endOfFrame;
        binding.scheduleFrame();
        await Future.any([painted, preparation.future]);
        if (_preparation != preparation || _route?.isCurrent == false) return;
        if (_crossKey.currentState != cross || cross.waveIsAnimating) continue;

        final bytes = await _captureCroixJpeg();
        if (_preparation == preparation) _preparedJpegBytes = bytes;
        return;
      }
    } catch (error, stackTrace) {
      debugPrint('Croix preparation failed: $error\n$stackTrace');
    } finally {
      if (_preparation == preparation) {
        _preparation = null;
        preparation.complete();
      }
    }
  }

  Future<Uint8List> _captureCroixJpeg() async {
    final boundary = _crossCaptureKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('The cross visual is not ready to share.');
    }

    const pixelRatio = 3.0;
    final theme = FlutterFlowTheme.of(context);
    final domain = FFLocalizations.of(context).getText('croix_share_domain');
    final poster = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      final image = _signedPoster(poster, pixelRatio, theme, domain);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        if (data == null) throw StateError('The cross could not be captured.');
        return pngToJpeg(Uint8List.sublistView(data));
      } finally {
        image.dispose();
      }
    } finally {
      poster.dispose();
    }
  }

  ui.Image _signedPoster(ui.Image poster, double pixelRatio,
      FlutterFlowTheme theme, String domain) {
    final tokens = theme.designToken;
    final width = poster.width / pixelRatio;
    final padding = tokens.spacing.sm + tokens.spacing.xs;
    final signature = TextPainter(
      text: TextSpan(
        text: domain,
        style: tokens.vip.typography
            .category(compact: true)
            .copyWith(color: tokens.vip.goldLight),
      ),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    try {
      signature.layout(maxWidth: width);
      final footerHeight =
          ((signature.height + padding * 2) * pixelRatio).ceil();
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder)
        ..drawColor(tokens.background.home, BlendMode.src)
        ..drawImage(poster, Offset.zero, Paint())
        ..scale(pixelRatio);
      signature.paint(
          canvas,
          Offset((width - signature.width) / 2,
              poster.height / pixelRatio + padding));
      final picture = recorder.endRecording();
      try {
        return picture.toImageSync(poster.width, poster.height + footerHeight);
      } finally {
        picture.dispose();
      }
    } finally {
      signature.dispose();
    }
  }

  Future<void> _shareCroix(BuildContext shareContext) async {
    if (_isSharing ||
        _route?.isCurrent == false ||
        _currentVisualSignature == null) {
      return;
    }
    _isSharing = true;
    final visit = _visit;
    bool canShare() =>
        mounted &&
        shareContext.mounted &&
        _route?.isCurrent != false &&
        _visit == visit &&
        _currentVisualSignature != null;
    try {
      logFirebaseEvent('CROIX_PAGE_share_ICN_ON_TAP');
      _prepareWhenNeeded(_currentVisualSignature);
      // Keep the ready path synchronous up to navigator.share. If a new
      // layout or publication replaces a pending capture, join its preparation.
      while (_preparation != null) {
        await _preparation!.future;
        if (!canShare()) return;
      }
      if (!canShare()) return;
      final jpegBytes = _preparedJpegBytes;
      if (jpegBytes == null) {
        throw StateError('The cross could not be captured.');
      }
      if (!shareContext.mounted) return;
      final box = shareContext.findRenderObject() as RenderBox;
      final viewport = Offset.zero & MediaQuery.sizeOf(shareContext);
      final anchor =
          (box.localToGlobal(Offset.zero) & box.size).intersect(viewport);
      final localizations = FFLocalizations.of(shareContext);
      bool stillCurrent() =>
          canShare() && identical(jpegBytes, _preparedJpegBytes);
      final downloaded = await deliverPreparedCroixJpeg(
        jpegBytes,
        fileName: 'croix-de-la-chance.jpg',
        subject: localizations.getText('croixsharetitle'),
        sharePositionOrigin: anchor.isEmpty
            ? Rect.fromCenter(center: viewport.center, width: 1, height: 1)
            : anchor,
        isCurrent: stillCurrent,
      );
      if (downloaded && stillCurrent() && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(localizations.getText('croixsharedownload'))));
      }
    } catch (error, stackTrace) {
      debugPrint('Croix sharing failed: $error\n$stackTrace');
      if (canShare() && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(FFLocalizations.of(context).getText('croixshareerror')),
        ));
      }
    } finally {
      _isSharing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final strings = FFLocalizations.of(context);
    return StreamBuilder<List<CroixRecord>>(
      key: ValueKey(_subscription),
      stream: _records,
      builder: (context, snapshot) {
        final record = snapshot.hasError ? null : snapshot.data?.firstOrNull;
        Widget content;
        if (record == null) {
          _prepareWhenNeeded(null);
          final error = snapshot.hasError;
          final showStatus = error ||
              snapshot.hasData ||
              snapshot.connectionState == ConnectionState.done;
          content = CroixStatusCard(
              child: showStatus
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            strings.getText(
                                error ? 'croix_unavailable' : 'croix_empty'),
                            textAlign: TextAlign.center,
                            style: theme.bodyLarge
                                .copyWith(color: theme.onPrimary)),
                        if (error) ...[
                          SizedBox(height: theme.designToken.spacing.sm),
                          TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: theme.onPrimary),
                            onPressed: () => setState(_restartRecords),
                            child: Text(strings.getText('viphstrty')),
                          ),
                        ],
                      ],
                    )
                  : null);
        } else {
          content = LayoutBuilder(builder: (context, constraints) {
            _prepareWhenNeeded((
              record.reference.path,
              record.date,
              jsonEncode(record.numeros.take(9).toList()),
              strings.languageCode,
              constraints.maxWidth,
              MediaQuery.devicePixelRatioOf(context),
              MediaQuery.textScalerOf(context),
              MediaQuery.boldTextOf(context),
            ));
            return RepaintBoundary(
              key: _crossCaptureKey,
              child: CrossWidget(
                  key: _crossKey, numbers: record.numeros, date: record.date),
            );
          });
        }
        return CroixPageLayout(
          onBack: () {
            logFirebaseEvent('CROIX_PAGE_arrow_back_rounded_ICN_ON_TAP');
            logFirebaseEvent('IconButton_navigate_back');
            context.safePop();
          },
          action: record == null
              ? null
              : CroixShareButton(onPressed: (context) => _shareCroix(context)),
          child: content,
        );
      },
    );
  }
}
