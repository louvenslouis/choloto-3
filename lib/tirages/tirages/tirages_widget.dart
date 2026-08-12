import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/tirages/fl/fl_widget.dart';
import '/tirages/new_yorkk/new_yorkk_widget.dart';
import 'package:flutter/material.dart';
import 'tirages_model.dart';

export 'tirages_model.dart';

class TiragesWidget extends StatefulWidget {
  const TiragesWidget({super.key});

  static String routeName = 'Tirages';
  static String routePath = '/resultats';

  @override
  State<TiragesWidget> createState() => _TiragesWidgetState();
}

class _TiragesWidgetState extends State<TiragesWidget> {
  late TiragesModel _model;
  late Future<List<ResultatsRecord>> _tiragesFuture;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TiragesModel());
    _tiragesFuture = _loadTirages();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Tirages'});
  }

  Future<List<ResultatsRecord>> _loadTirages() async {
    final results = await queryResultatsRecordOnce(
      queryBuilder: (resultatsRecord) =>
          resultatsRecord.orderBy('date', descending: true),
    );

    return results
        .where((result) => result.tirage == 'ny' || result.tirage == 'fl')
        .toList();
  }

  Future<void> _refreshTirages() async {
    logFirebaseEvent('TIRAGES_RefreshLotteryResults_ON_TAP');
    final refreshedResults = _loadTirages();
    safeSetState(() => _tiragesFuture = refreshedResults);
    await refreshedResults;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          title: Text(
            FFLocalizations.of(context).getText(
              'hfwdp6xo' /* Tirages */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Google sans flex',
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [
            FlutterFlowIconButton(
              buttonSize: 40.0,
              icon: Icon(
                Icons.refresh,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 24.0,
              ),
              onPressed: _refreshTirages,
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: FutureBuilder<List<ResultatsRecord>>(
            future: _tiragesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _TiragesMessage(
                  icon: Icons.cloud_off_outlined,
                  message: FFLocalizations.of(context).getVariableText(
                    frText: 'Impossible de charger les tirages.',
                    enText: 'Unable to load draw results.',
                    crText: 'Nou pa ka chaje rezilta tiraj yo.',
                  ),
                  onRetry: _refreshTirages,
                );
              }

              final tirages = snapshot.data ?? const <ResultatsRecord>[];
              if (tirages.isEmpty) {
                return _TiragesMessage(
                  icon: Icons.inbox_outlined,
                  message: FFLocalizations.of(context).getVariableText(
                    frText: 'Aucun tirage disponible pour le moment.',
                    enText: 'No draw results are available right now.',
                    crText: 'Pa gen rezilta tiraj ki disponib kounye a.',
                  ),
                  onRetry: _refreshTirages,
                );
              }

              return RefreshIndicator(
                color: FlutterFlowTheme.of(context).primary,
                onRefresh: _refreshTirages,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 24.0),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: tirages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final tirage = tirages[index];
                    if (tirage.tirage == 'ny') {
                      return NewYorkkWidget(infos: tirage);
                    }
                    return FlWidget(infos: tirage);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TiragesMessage extends StatelessWidget {
  const _TiragesMessage({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: FlutterFlowTheme.of(context).primary,
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
          Icon(
            icon,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 44.0,
          ),
          const SizedBox(height: 12.0),
          Text(
            message,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Google sans flex',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }
}
