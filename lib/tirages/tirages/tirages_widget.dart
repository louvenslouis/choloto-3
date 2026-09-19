import 'dart:async';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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
  static const _pageSize = 64;
  static const _supportedLotteryCodes = {
    'ny',
    'fl',
    'tx',
    'md',
    'ga',
    'tn',
    'pa',
    'nj',
  };

  late TiragesModel _model;
  final List<ResultatsRecord> _tirages = [];
  QueryDocumentSnapshot? _nextPageMarker;
  bool _loadingInitialPage = true;
  bool _loadingMore = false;
  bool _loadFailed = false;
  bool _hasMore = true;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TiragesModel());
    unawaited(_refreshTirages(logEvent: false));

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Tirages'});
  }

  Future<FFFirestorePage<ResultatsRecord>> _loadTiragesPage({
    QueryDocumentSnapshot? after,
  }) =>
      queryCollectionPage<ResultatsRecord>(
        ResultatsRecord.collection,
        ResultatsRecord.fromSnapshot,
        queryBuilder: (resultatsRecord) => resultatsRecord
            .where(
              'tirage',
              whereIn: _supportedLotteryCodes.toList(growable: false),
            )
            .orderBy('date', descending: true),
        nextPageMarker: after,
        pageSize: _pageSize,
        isStream: false,
      );

  Future<void> _refreshTirages({bool logEvent = true}) async {
    if (logEvent) logFirebaseEvent('TIRAGES_RefreshLotteryResults_ON_TAP');
    safeSetState(() {
      _loadingInitialPage = true;
      _loadFailed = false;
      _hasMore = true;
      _nextPageMarker = null;
    });
    try {
      final page = await _loadTiragesPage();
      if (!mounted) return;
      safeSetState(() {
        _tirages
          ..clear()
          ..addAll(page.data);
        _nextPageMarker = page.nextPageMarker;
        _hasMore = page.data.length == _pageSize && page.nextPageMarker != null;
        _loadingInitialPage = false;
      });
    } catch (_) {
      if (!mounted) return;
      safeSetState(() {
        _loadingInitialPage = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _loadMoreTirages() async {
    if (_loadingMore || !_hasMore || _nextPageMarker == null) return;
    safeSetState(() => _loadingMore = true);
    try {
      final page = await _loadTiragesPage(after: _nextPageMarker);
      if (!mounted) return;
      final existingPaths =
          _tirages.map((result) => result.reference.path).toSet();
      safeSetState(() {
        _tirages.addAll(
          page.data.where(
            (result) => existingPaths.add(result.reference.path),
          ),
        );
        _nextPageMarker = page.nextPageMarker;
        _hasMore = page.data.length == _pageSize && page.nextPageMarker != null;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      safeSetState(() => _loadingMore = false);
    }
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
          child: _buildTiragesBody(context),
        ),
      ),
    );
  }

  Widget _buildTiragesBody(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final localizations = FFLocalizations.of(context);
    if (_loadingInitialPage) {
      return Center(
        child: CircularProgressIndicator(color: theme.primary),
      );
    }
    if (_loadFailed) {
      return _TiragesMessage(
        icon: Icons.cloud_off_outlined,
        message: localizations.getVariableText(
          frText: 'Impossible de charger les tirages.',
          enText: 'Unable to load draw results.',
          crText: 'Nou pa ka chaje rezilta tiraj yo.',
        ),
        onRetry: _refreshTirages,
      );
    }
    if (_tirages.isEmpty) {
      return _TiragesMessage(
        icon: Icons.inbox_outlined,
        message: localizations.getVariableText(
          frText: 'Aucun tirage disponible pour le moment.',
          enText: 'No draw results are available right now.',
          crText: 'Pa gen rezilta tiraj ki disponib kounye a.',
        ),
        onRetry: _refreshTirages,
      );
    }

    final tiragesByDay = _groupTiragesByDay(_tirages);
    return RefreshIndicator(
      color: theme.primary,
      onRefresh: _refreshTirages,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          theme.designToken.spacing.sm,
          theme.designToken.spacing.md,
          theme.designToken.spacing.sm,
          theme.designToken.spacing.lg,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: tiragesByDay.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == tiragesByDay.length) {
            return Padding(
              padding: EdgeInsets.only(top: theme.designToken.spacing.md),
              child: Center(
                child: FFButtonWidget(
                  onPressed: _loadingMore ? null : _loadMoreTirages,
                  text: localizations.getVariableText(
                    frText: 'Charger plus',
                    enText: 'Load more',
                    crText: 'Chaje plis',
                  ),
                  icon: const Icon(Icons.expand_more_rounded, size: 20),
                  options: FFButtonOptions(
                    height: 44,
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.designToken.spacing.md,
                    ),
                    color: theme.secondaryBackground,
                    disabledColor: theme.secondaryBackground,
                    textStyle: theme.labelLarge.copyWith(
                      color: theme.primaryText,
                    ),
                    borderRadius: BorderRadius.circular(
                      theme.designToken.radius.full,
                    ),
                    elevation: 0,
                  ),
                  showLoadingIndicator: true,
                ),
              ),
            );
          }

          final dayGroup = tiragesByDay[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == tiragesByDay.length - 1 && !_hasMore
                  ? 0.0
                  : theme.designToken.spacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TiragesDateSeparator(date: dayGroup.date),
                SizedBox(height: theme.designToken.spacing.sm),
                for (var resultIndex = 0;
                    resultIndex < dayGroup.results.length;
                    resultIndex++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: resultIndex == dayGroup.results.length - 1
                          ? 0.0
                          : theme.designToken.spacing.sm,
                    ),
                    child: dayGroup.results[resultIndex].tirage == 'fl'
                        ? FlWidget(infos: dayGroup.results[resultIndex])
                        : NewYorkkWidget(infos: dayGroup.results[resultIndex]),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

List<_TiragesDayGroup> _groupTiragesByDay(
  List<ResultatsRecord> tirages,
) {
  final groups = <_TiragesDayGroup>[];

  for (final tirage in tirages) {
    if (groups.isEmpty || !_isSameCalendarDay(groups.last.date, tirage.date)) {
      groups.add(_TiragesDayGroup(tirage.date));
    }
    groups.last.results.add(tirage);
  }

  return groups;
}

bool _isSameCalendarDay(DateTime? first, DateTime? second) {
  if (first == null || second == null) {
    return first == second;
  }

  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _TiragesDayGroup {
  _TiragesDayGroup(this.date);

  final DateTime? date;
  final List<ResultatsRecord> results = [];
}

class _TiragesDateSeparator extends StatelessWidget {
  const _TiragesDateSeparator({required this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final localizations = FFLocalizations.of(context);
    final dateText = date == null
        ? localizations.getVariableText(
            frText: 'Date inconnue',
            enText: 'Unknown date',
            crText: 'Dat enkoni',
          )
        : dateTimeFormat(
            'd MMM y',
            date,
            locale: localizations.languageCode,
          );

    return Row(
      children: [
        Expanded(
          child: Divider(
            height: 1.0,
            thickness: 0.7,
            color: theme.secondaryText.withValues(alpha: 0.35),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.designToken.spacing.sm,
          ),
          child: Text(
            dateText,
            style: theme.labelSmall.override(
              color: theme.secondaryText,
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            height: 1.0,
            thickness: 0.7,
            color: theme.secondaryText.withValues(alpha: 0.35),
          ),
        ),
      ],
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
