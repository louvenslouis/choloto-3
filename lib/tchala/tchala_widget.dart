import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';

import 'tchala_data_repository.dart';
export 'tchala_model.dart';

class TchalaWidget extends StatefulWidget {
  const TchalaWidget({super.key});

  static String routeName = 'Tchala';
  static String routePath = '/tchala';

  @override
  State<TchalaWidget> createState() => _TchalaWidgetState();
}

class _TchalaWidgetState extends State<TchalaWidget>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late final TabController _tabController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late Future<TchalaData> _data;

  String _query = '';
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Tchala'});
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChange);
    _searchController = TextEditingController()..addListener(_handleSearch);
    _searchFocusNode = FocusNode();
    _data = tchalaDataRepository.load();
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChange)
      ..dispose();
    _searchController
      ..removeListener(_handleSearch)
      ..dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging || _activeTab == _tabController.index) {
      return;
    }
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() => _activeTab = _tabController.index);
  }

  void _handleSearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query != _query) {
      setState(() => _query = query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
  }

  void _retryLoading() {
    setState(() => _data = tchalaDataRepository.reload());
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final localizations = FFLocalizations.of(context);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        automaticallyImplyLeading: false,
        title: Text(
          localizations.getText('z0x7hmij' /* tchala */),
          style: theme.headlineMedium.override(
            fontFamily: 'Google sans flex',
            color: theme.primaryText,
            fontSize: 22.0,
            letterSpacing: 0.0,
          ),
        ),
        centerTitle: false,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.md,
                    spacing.xs,
                    spacing.md,
                    spacing.sm,
                  ),
                  child: _SearchField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hintText: _activeTab == 0
                        ? localizations.getVariableText(
                            frText: 'Rechercher un symbole ou un numéro',
                            enText: 'Search for a symbol or number',
                            crText: 'Chèche yon senbòl oswa yon nimewo',
                          )
                        : localizations.getVariableText(
                            frText: 'Rechercher un saint ou un mois',
                            enText: 'Search for a saint or month',
                            crText: 'Chèche yon sen oswa yon mwa',
                          ),
                    onClear: _clearSearch,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.md),
                  child: Container(
                    height: 44.0,
                    padding: EdgeInsets.all(spacing.xs),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius:
                          BorderRadius.circular(theme.designToken.radius.sm),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(
                            theme.designToken.radius.sm - 2),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Theme.of(context).colorScheme.onPrimary,
                      unselectedLabelColor: theme.secondaryText,
                      labelStyle: theme.titleSmall.override(
                        fontFamily: 'Google sans flex',
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                      unselectedLabelStyle: theme.titleSmall.override(
                        fontFamily: 'Google sans flex',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.0,
                      ),
                      tabs: [
                        Tab(
                          text: localizations.getText('40q38tw9' /* Tchala */),
                        ),
                        Tab(
                          text: localizations.getText('d4x9buzb' /* Saints */),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: spacing.sm),
                Expanded(
                  child: FutureBuilder<TchalaData>(
                    future: _data,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Center(
                          child:
                              CircularProgressIndicator(color: theme.primary),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return _LoadError(onRetry: _retryLoading);
                      }

                      final data = snapshot.requireData;
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _TchalaList(entries: data.symbols, query: _query),
                          _SaintsList(months: data.saintMonths, query: _query),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final radius = theme.designToken.radius.sm;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.search,
      cursorColor: theme.primary,
      style: theme.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.bodyMedium.override(color: theme.secondaryText),
        prefixIcon: Icon(Icons.search_rounded, color: theme.secondaryText),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                onPressed: onClear,
                icon: Icon(Icons.close_rounded, color: theme.secondaryText),
              ),
        filled: true,
        fillColor: theme.secondaryBackground,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: theme.alternate.withValues(alpha: 0.45)),
          borderRadius: BorderRadius.circular(radius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primary, width: 1.5),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class _TchalaList extends StatelessWidget {
  const _TchalaList({required this.entries, required this.query});

  final List<TchalaEntry> entries;
  final String query;

  @override
  Widget build(BuildContext context) {
    final visibleEntries = query.isEmpty
        ? entries
        : entries.where((entry) {
            final numbers = entry.associatedNumbers.join(' ');
            return entry.creoleSymbol.toLowerCase().contains(query) ||
                entry.frenchTranslation.toLowerCase().contains(query) ||
                numbers.contains(query);
          }).toList(growable: false);

    if (visibleEntries.isEmpty) {
      return const _EmptySearchResult();
    }

    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    return ListView.separated(
      key: const PageStorageKey('tchala-list'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        spacing.md,
        spacing.xs,
        spacing.md,
        spacing.lg,
      ),
      itemCount: visibleEntries.length,
      separatorBuilder: (_, __) => SizedBox(height: spacing.sm),
      itemBuilder: (context, index) => _TchalaCard(
        key: ValueKey(visibleEntries[index].creoleSymbol),
        entry: visibleEntries[index],
      ),
    );
  }
}

class _TchalaCard extends StatelessWidget {
  const _TchalaCard({super.key, required this.entry});

  final TchalaEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final language = FFLocalizations.of(context).languageCode;
    final primaryLabel =
        language == 'cr' ? entry.creoleSymbol : entry.frenchTranslation;
    final secondaryLabel =
        language == 'cr' ? entry.frenchTranslation : entry.creoleSymbol;

    return Semantics(
      container: true,
      label:
          '$primaryLabel, ${entry.associatedNumbers.map((n) => n.toString()).join(', ')}',
      child: Container(
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
          border: Border.all(
            color: theme.alternate.withValues(alpha: 0.28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              primaryLabel,
              style: theme.titleSmall.override(
                fontFamily: 'Google sans flex',
                letterSpacing: 0.0,
              ),
            ),
            if (secondaryLabel != primaryLabel) ...[
              SizedBox(height: spacing.xs),
              Text(
                secondaryLabel,
                style: theme.bodySmall.override(
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                ),
              ),
            ],
            SizedBox(height: spacing.md),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: [
                for (final number in entry.associatedNumbers)
                  _NumberBadge(number: number),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Semantics(
      label: number.toString(),
      child: Container(
        width: 48.0,
        height: 40.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.primary,
          borderRadius: BorderRadius.circular(theme.designToken.radius.full),
        ),
        child: Text(
          number.toString().padLeft(2, '0'),
          style: theme.titleSmall.override(
            fontFamily: 'Google sans flex',
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _SaintsList extends StatelessWidget {
  const _SaintsList({required this.months, required this.query});

  final List<SaintMonth> months;
  final String query;

  @override
  Widget build(BuildContext context) {
    final visibleMonths = query.isEmpty
        ? months
        : months
            .map((month) {
              final monthMatches = month.name.toLowerCase().contains(query);
              final saints = monthMatches
                  ? month.saints
                  : month.saints
                      .where((saint) =>
                          saint.name.toLowerCase().contains(query) ||
                          saint.date.contains(query))
                      .toList(growable: false);
              return SaintMonth(name: month.name, saints: saints);
            })
            .where((month) => month.saints.isNotEmpty)
            .toList(growable: false);

    if (visibleMonths.isEmpty) {
      return const _EmptySearchResult();
    }

    final theme = FlutterFlowTheme.of(context);
    return ListView.builder(
      key: const PageStorageKey('saints-list'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: theme.designToken.spacing.lg),
      itemCount: visibleMonths.length,
      itemBuilder: (context, index) =>
          _SaintMonthSection(month: visibleMonths[index]),
    );
  }
}

class _SaintMonthSection extends StatelessWidget {
  const _SaintMonthSection({required this.month});

  final SaintMonth month;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    return StickyHeader(
      overlapHeaders: false,
      header: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          spacing.md,
          12.0,
          spacing.md,
          spacing.sm,
        ),
        color: theme.primaryBackground,
        child: Text(
          month.name,
          style: theme.titleSmall.override(
            fontFamily: 'Google sans flex',
            color: theme.secondaryText,
            letterSpacing: 0.0,
          ),
        ),
      ),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.md),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
          child: Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              border: Border.all(
                color: theme.alternate.withValues(alpha: 0.28),
              ),
              borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
            ),
            child: Column(
              children: [
                for (var index = 0; index < month.saints.length; index++)
                  _SaintRow(
                    saint: month.saints[index],
                    showDivider: index < month.saints.length - 1,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaintRow extends StatelessWidget {
  const _SaintRow({required this.saint, required this.showDivider});

  final SaintEntry saint;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final date = DateTime.tryParse(saint.date);
    final day = date == null ? saint.date : DateFormat('dd').format(date);

    return Container(
      constraints: const BoxConstraints(minHeight: 64.0),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: 10.0,
      ),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: theme.alternate.withValues(alpha: 0.24),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius:
                  BorderRadius.circular(theme.designToken.radius.full),
            ),
            child: Text(
              day,
              style: theme.titleSmall.override(
                fontFamily: 'Google sans flex',
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.0,
              ),
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Text(
              saint.name,
              style: theme.bodyLarge.override(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final localizations = FFLocalizations.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.designToken.spacing.lg),
        child: Text(
          localizations.getVariableText(
            frText: 'Aucun résultat trouvé.',
            enText: 'No results found.',
            crText: 'Pa gen rezilta.',
          ),
          textAlign: TextAlign.center,
          style: theme.bodyMedium.override(color: theme.secondaryText),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final localizations = FFLocalizations.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.designToken.spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.getVariableText(
                frText: 'Impossible de charger les données Tchala.',
                enText: 'Unable to load the Tchala data.',
                crText: 'Nou pa ka chaje done Tchala yo.',
              ),
              textAlign: TextAlign.center,
              style: theme.bodyMedium,
            ),
            SizedBox(height: theme.designToken.spacing.md),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.primaryText,
                side: BorderSide(color: theme.alternate),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(theme.designToken.radius.sm),
                ),
              ),
              child: Text(
                localizations.getVariableText(
                  frText: 'Réessayer',
                  enText: 'Try again',
                  crText: 'Eseye ankò',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
