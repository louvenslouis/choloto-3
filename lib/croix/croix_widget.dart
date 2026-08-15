import '/backend/backend.dart';
import '/components/cross_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'croix_share.dart';
import 'croix_share_platform.dart';
import 'croix_model.dart';
export 'croix_model.dart';

class CroixWidget extends StatefulWidget {
  const CroixWidget({super.key});

  static String routeName = 'croix';
  static String routePath = '/croix';

  @override
  State<CroixWidget> createState() => _CroixWidgetState();
}

class _CroixWidgetState extends State<CroixWidget> {
  late CroixModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _crossCaptureKey = GlobalKey();
  bool _isSharing = false;
  Uint8List? _preparedJpegBytes;
  String? _preparedVisualSignature;
  String? _scheduledVisualSignature;
  String? _currentVisualSignature;

  void _scheduleVisualPreparation(String signature) {
    _currentVisualSignature = signature;
    if (_preparedVisualSignature == signature ||
        _scheduledVisualSignature == signature) {
      return;
    }

    _preparedJpegBytes = null;
    _scheduledVisualSignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scheduledVisualSignature == signature) {
        _prepareCroixVisual(signature);
      }
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  Future<void> _prepareCroixVisual(String signature) async {
    try {
      await precacheImage(
        const AssetImage('assets/images/xxx.jpg'),
        context,
      );
      if (!mounted || _scheduledVisualSignature != signature) {
        return;
      }

      final nextFrame = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((_) => nextFrame.complete());
      WidgetsBinding.instance.scheduleFrame();
      await nextFrame.future;

      if (!mounted || _scheduledVisualSignature != signature) {
        return;
      }
      final jpegBytes = await _captureCroixJpeg();
      if (!mounted || _scheduledVisualSignature != signature) {
        return;
      }

      setState(() {
        _preparedJpegBytes = jpegBytes;
        _preparedVisualSignature = signature;
        _scheduledVisualSignature = null;
      });
    } catch (error, stackTrace) {
      debugPrint('Croix preparation failed: $error\n$stackTrace');
      if (mounted && _scheduledVisualSignature == signature) {
        _scheduledVisualSignature = null;
      }
    }
  }

  Future<Uint8List> _captureCroixJpeg() async {
    final boundary = _crossCaptureKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null || boundary.debugNeedsPaint) {
      throw StateError('The cross visual is not ready to share.');
    }

    final capturedImage = await boundary.toImage(pixelRatio: 3.0);
    try {
      final byteData = await capturedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw StateError('The cross visual could not be captured.');
      }

      final pngBytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      return pngToJpeg(pngBytes);
    } finally {
      capturedImage.dispose();
    }
  }

  Future<void> _shareCroix(BuildContext shareContext) async {
    if (_isSharing) {
      return;
    }

    final localizations = FFLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final shareBox = shareContext.findRenderObject() as RenderBox?;
    final sharePositionOrigin = shareBox == null
        ? null
        : shareBox.localToGlobal(Offset.zero) & shareBox.size;
    final shareSubject = localizations.getText('croixsharetitle');
    final shareErrorMessage = localizations.getText('croixshareerror');
    final downloadMessage = localizations.getText('croixsharedownload');
    final preparingMessage = localizations.getText('croixsharepreparing');
    final jpegBytes = _preparedJpegBytes;

    if (jpegBytes == null) {
      final signature = _currentVisualSignature;
      if (signature != null) {
        _scheduleVisualPreparation(signature);
      }
      messenger.showSnackBar(
        SnackBar(content: Text(preparingMessage)),
      );
      return;
    }

    setState(() => _isSharing = true);
    try {
      const fileName = 'croix-de-la-chance.jpg';
      final downloaded = await deliverPreparedCroixJpeg(
        jpegBytes,
        fileName: fileName,
        subject: shareSubject,
        sharePositionOrigin: sharePositionOrigin,
      );
      if (downloaded && mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(downloadMessage)),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Croix sharing failed: $error\n$stackTrace');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(shareErrorMessage),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CroixModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'croix'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CroixRecord>>(
      stream: queryCroixRecord(
        queryBuilder: (croixRecord) =>
            croixRecord.orderBy('date', descending: true),
        singleRecord: true,
      ),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        List<CroixRecord> croixCroixRecordList = snapshot.data!;
        final croixCroixRecord =
            croixCroixRecordList.isNotEmpty ? croixCroixRecordList.first : null;

        if (croixCroixRecord != null) {
          final visualSignature = [
            croixCroixRecord.reference.path,
            croixCroixRecord.date?.millisecondsSinceEpoch,
            croixCroixRecord.numeros.join(','),
            FFLocalizations.of(context).languageCode,
            Theme.of(context).brightness.name,
          ].join('|');
          _scheduleVisualPreparation(visualSignature);
        }

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primary,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              automaticallyImplyLeading: false,
              leading: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 60.0,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 30.0,
                ),
                onPressed: () async {
                  logFirebaseEvent('CROIX_PAGE_arrow_back_rounded_ICN_ON_TAP');
                  logFirebaseEvent('IconButton_navigate_back');
                  context.pop();
                },
              ),
              title: Align(
                alignment: const AlignmentDirectional(-1.0, -1.0),
                child: Text(
                  FFLocalizations.of(context).getText(
                    '63dg2p5g' /* Croix de la Chance */,
                  ),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Google sans flex',
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 22.0,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              actions: const [],
              centerTitle: false,
              elevation: 2.0,
            ),
            body: SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        end:
                            FlutterFlowTheme.of(context).designToken.spacing.md,
                      ),
                      child: Builder(
                        builder: (shareButtonContext) => Tooltip(
                          message: FFLocalizations.of(context)
                              .getText('croixsharetitle'),
                          child: FlutterFlowIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: FlutterFlowTheme.of(context)
                                .designToken
                                .radius
                                .full,
                            buttonSize: 48.0,
                            fillColor: FlutterFlowTheme.of(context).onPrimary,
                            disabledIconColor:
                                FlutterFlowTheme.of(context).secondaryText,
                            icon: Icon(
                              Icons.share_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 24.0,
                            ),
                            onPressed: croixCroixRecord == null
                                ? null
                                : () async {
                                    logFirebaseEvent(
                                        'CROIX_PAGE_share_ICN_ON_TAP');
                                    await _shareCroix(shareButtonContext);
                                  },
                            showLoadingIndicator: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: RepaintBoundary(
                      key: _crossCaptureKey,
                      child: wrapWithModel(
                        model: _model.crossModel,
                        updateCallback: () => safeSetState(() {}),
                        child: CrossWidget(
                          numbers: croixCroixRecord?.numeros,
                          date: croixCroixRecord?.date,
                        ),
                      ),
                    ),
                  ),
                ]
                    .divide(const SizedBox(height: 25.0))
                    .addToStart(const SizedBox(height: 12.0)),
              ),
            ),
          ),
        );
      },
    );
  }
}
