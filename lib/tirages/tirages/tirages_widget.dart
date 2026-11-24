import 'dart:async';
import 'package:collection/collection.dart' show ListExtensions;

import '/ads/draw_ad_banner.dart';
import '/backend/backend.dart';
import '/components/home_page_scaffold.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'tirage_result_row.dart';
import 'tirages_header.dart';
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
  Widget build(BuildContext context) => TiragesView(
        results: _tirages,
        loading: _loadingInitialPage,
        loadFailed: _loadFailed,
        hasMore: _hasMore,
        loadingMore: _loadingMore,
        onRefresh: _refreshTirages,
        onLoadMore: _loadMoreTirages,
      );
}

/// Presentation shared by the tab and the standalone results route.
class TiragesView extends StatelessWidget {
  const TiragesView({
    super.key,
    required this.results,
    required this.loading,
    required this.loadFailed,
    required this.hasMore,
    required this.loadingMore,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final List<ResultatsRecord> results;
  final bool loading;
  final bool loadFailed;
  final bool hasMore;
  final bool loadingMore;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final strings = FFLocalizations.of(context);
    final days = _groupTiragesByDay(results);
    final showResults = !loading && !loadFailed && days.isNotEmpty;
    return Scaffold(
      backgroundColor: tokens.background.home,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: tokens.background.homeGradient),
        child: SafeArea(
          child: Column(children: [
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final wide = constraints.maxWidth >= kBreakpointMedium;
                final gutter = wide ? spacing.lg : spacing.md;
                final inset = max(
                    gutter,
                    (constraints.maxWidth - HomePageScaffold.maxContentWidth) /
                        2);
                final daysPadding = EdgeInsets.symmetric(horizontal: inset);
                return RefreshIndicator(
                  color: theme.primary,
                  backgroundColor: tokens.home.surface.colors.last,
                  notificationPredicate: (notice) =>
                      !loading &&
                      !loadingMore &&
                      defaultScrollNotificationPredicate(notice),
                  onRefresh: onRefresh,
                  child: CustomScrollView(
                    key: const PageStorageKey('tirages-scroll'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(inset, gutter, inset,
                            wide ? spacing.xl : spacing.lg),
                        sliver: SliverToBoxAdapter(
                          child: TiragesHeader(
                              onRefresh: onRefresh,
                              loading: loading || loadingMore),
                        ),
                      ),
                      if (showResults) ...[
                        SliverPadding(
                          padding: daysPadding,
                          sliver: SliverList.builder(
                            itemCount: days.length,
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.only(bottom: spacing.lg),
                              child: _TiragesDay(group: days[index]),
                            ),
                          ),
                        ),
                        if (hasMore)
                          SliverToBoxAdapter(
                            child: Center(
                              child: FFButtonWidget(
                                key: const ValueKey('tirages-load-more'),
                                onPressed: loadingMore ? null : onLoadMore,
                                text: strings.getVariableText(
                                  frText: 'Charger plus',
                                  enText: 'Load more',
                                  crText: 'Chaje plis',
                                ),
                                icon: const Icon(Icons.expand_more_rounded,
                                    size: 20),
                                options: FFButtonOptions(
                                  height: kMinInteractiveDimension,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spacing.lg),
                                  color: tokens.home.surface.colors.last,
                                  disabledColor:
                                      tokens.home.surface.colors.last,
                                  textStyle: theme.labelLarge.copyWith(
                                      color: theme.primaryText,
                                      fontWeight: FontWeight.w600),
                                  borderSide:
                                      BorderSide(color: tokens.home.panelEdge),
                                  borderRadius:
                                      BorderRadius.circular(tokens.radius.full),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                      ] else
                        SliverPadding(
                          padding: daysPadding,
                          sliver: SliverToBoxAdapter(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: _TiragesStatus(
                                  loading: loading,
                                  loadFailed: loadFailed,
                                  onRetry: onRefresh),
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(child: SizedBox(height: spacing.lg)),
                    ],
                  ),
                );
              }),
            ),
            if (showResults &&
                Visibility.of(context) &&
                ModalRoute.isCurrentOf(context) == true)
              const DrawAdBanner(),
          ]),
        ),
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

class _TiragesDay extends StatelessWidget {
  const _TiragesDay({required this.group});

  final _TiragesDayGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final strings = FFLocalizations.of(context);
    final date = group.date;
    final formatted = date == null
        ? strings.getVariableText(
            frText: 'Date inconnue',
            enText: 'Unknown date',
            crText: 'Dat enkoni')
        : dateTimeFormat(
            strings.languageCode == 'en' ? 'EEEE, MMMM d, y' : 'EEEE d MMMM y',
            date,
            locale: strings.languageCode);
    final title = formatted[0].toUpperCase() + formatted.substring(1);
    return LayoutBuilder(builder: (context, constraints) {
      // A pair of results must still fit the names and four Florida chips.
      final wide = constraints.maxWidth >=
          2 * 440 * MediaQuery.textScalerOf(context).scale(16) / 16;
      final columns = wide && group.results.length > 1 ? 2 : 1;
      final separator = BorderSide(color: tokens.home.panelEdge);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Row(children: [
              Container(
                width: spacing.xs,
                height: wide ? spacing.lg : 20,
                decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(tokens.radius.full)),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                  child: Text(title,
                      style: theme.headlineSmall.override(
                          fontSize: wide ? 26 : 20,
                          fontWeight: FontWeight.w800,
                          lineHeight: 1.15))),
            ]),
          ),
          SizedBox(height: spacing.sm),
          Container(
            decoration: tokens.home.panel,
            padding: EdgeInsets.symmetric(horizontal: spacing.xs),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(
                  horizontalInside: separator, verticalInside: separator),
              children: [
                for (final row in group.results.slices(columns))
                  TableRow(children: [
                    for (final result in row)
                      TirageResultRow(
                        key: ValueKey(result.reference.path),
                        result: result,
                      ),
                    if (row.length < columns) const SizedBox.shrink(),
                  ]),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _TiragesStatus extends StatelessWidget {
  const _TiragesStatus({
    required this.loading,
    required this.loadFailed,
    required this.onRetry,
  });

  final bool loading;
  final bool loadFailed;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final strings = FFLocalizations.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      width: double.infinity,
      padding: EdgeInsets.all(spacing.xl),
      decoration: tokens.home.panel,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (loading)
          CircularProgressIndicator(
            key: const ValueKey('tirages-loading'),
            color: theme.primary,
            semanticsLabel: strings.getVariableText(
                frText: 'Chargement des tirages',
                enText: 'Loading draw results',
                crText: 'Rezilta tiraj yo ap chaje'),
          )
        else ...[
          Icon(
              loadFailed
                  ? Icons.cloud_off_rounded
                  : Icons.confirmation_number_outlined,
              color: tokens.home.mutedText,
              size: spacing.xl),
          SizedBox(height: spacing.md),
          Text(
              loadFailed
                  ? strings.getVariableText(
                      frText: 'Impossible de charger les tirages.',
                      enText: 'Unable to load draw results.',
                      crText: 'Nou pa ka chaje rezilta tiraj yo.')
                  : strings.getVariableText(
                      frText: 'Aucun tirage disponible pour le moment.',
                      enText: 'No draw results are available right now.',
                      crText: 'Pa gen rezilta tiraj ki disponib kounye a.'),
              style: theme.bodyMedium.copyWith(color: tokens.home.mutedText),
              textAlign: TextAlign.center),
          if (loadFailed) ...[
            SizedBox(height: spacing.sm),
            TextButton.icon(
              key: const ValueKey('tirages-retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(strings.getText('ach_retry')),
              style: TextButton.styleFrom(
                  foregroundColor: theme.primary,
                  minimumSize: const Size(
                      kMinInteractiveDimension, kMinInteractiveDimension),
                  textStyle: theme.labelLarge),
            ),
          ],
        ],
      ]),
    );
  }
}
