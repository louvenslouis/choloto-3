import '/backend/backend.dart';
import '/components/cross_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'croix_download.dart';
import 'croix_share.dart';
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

    setState(() => _isSharing = true);
    try {
      await WidgetsBinding.instance.endOfFrame;

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
        final jpegBytes = pngToJpeg(pngBytes);

        const fileName = 'croix-de-la-chance.jpg';
        final delivery = await deliverCroixJpeg(
          share: () async {
            await Share.shareXFiles(
              [
                XFile.fromData(
                  jpegBytes,
                  mimeType: 'image/jpeg',
                ),
              ],
              subject: shareSubject,
              fileNameOverrides: [fileName],
              sharePositionOrigin: sharePositionOrigin,
            );
          },
          download: () => downloadCroixJpeg(
            jpegBytes,
            fileName: fileName,
          ),
          isWeb: kIsWeb,
        );
        if (delivery == CroixShareDelivery.downloaded && mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text(downloadMessage)),
          );
        }
      } finally {
        capturedImage.dispose();
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
