import 'package:flutter/material.dart';
import '/components/draw_result_chip.dart';
import '/components/home_page_scaffold.dart';
import '/components/illustrated_page_header.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'saints_calendar.dart';
import 'tchala_data_repository.dart';
import 'tchala_search.dart';
export 'tchala_model.dart';

class TchalaWidget extends StatefulWidget {
  const TchalaWidget({super.key, this.openSaints = false, this.today});

  final bool openSaints;
  final DateTime? today;
  static const saintsRouteName = 'Saints';

  static String routeName = 'Tchala';
  static String routePath = '/tchala';

  @override
  State<TchalaWidget> createState() => _TchalaWidgetState();
}

class _TchalaWidgetState extends State<TchalaWidget>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<TextEditingController> _searchControllers;
  TextEditingController get _searchController => _searchControllers[_activeTab];
  late final FocusNode _searchFocusNode;
  late Future<TchalaData> _data;

  late int _activeTab;

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Tchala'});
    _activeTab = widget.openSaints ? 1 : 0;
    _tabController =
        TabController(length: 2, initialIndex: _activeTab, vsync: this)
          ..addListener(_handleTabChange);
    _searchControllers = List.generate(
        2, (_) => TextEditingController()..addListener(_handleSearch));
    _searchFocusNode = FocusNode();
    _data = tchalaDataRepository.load();
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChange)
      ..dispose();
    for (final controller in _searchControllers) {
      controller
        ..removeListener(_handleSearch)
        ..dispose();
    }
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging || _activeTab == _tabController.index) {
      return;
    }
    _searchFocusNode.unfocus();
    setState(() => _activeTab = _tabController.index);
  }

  void _handleSearch() => setState(() {});

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
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final strings = FFLocalizations.of(context);
    final saints = _activeTab == 1;
    final tabHeight = max(kMinInteractiveDimension,
        MediaQuery.textScalerOf(context).scale(20) + spacing.md);
    final tabs = DecoratedBox(
      decoration: tokens.home.panel,
      child: Padding(
          padding: EdgeInsets.all(spacing.xs),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
                color: theme.primary,
                borderRadius:
                    BorderRadius.circular(tokens.radius.md - spacing.xs)),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerHeight: 0,
            labelPadding: EdgeInsets.symmetric(horizontal: spacing.xs),
            labelColor: theme.onPrimary,
            unselectedLabelColor: tokens.home.mutedText,
            labelStyle: theme.titleSmall.copyWith(fontWeight: FontWeight.w800),
            tabs: [
              Tab(
                  height: tabHeight,
                  text: strings.getVariableText(
                      frText: 'Symboles', enText: 'Symbols', crText: 'Senbòl')),
              Tab(height: tabHeight, text: strings.getText('d4x9buzb')),
            ],
          )),
    );
    final search = _SearchField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      onClear: _clearSearch,
      hintText: saints
          ? strings.getVariableText(
              frText: 'Rechercher un saint ou une date',
              enText: 'Search by saint or date',
              crText: 'Chèche yon sen oswa yon dat')
          : strings.getVariableText(
              frText: 'Symbole ou numéro',
              enText: 'Symbol or number',
              crText: 'Senbòl oswa nimewo'),
    );
    return Scaffold(
      backgroundColor: tokens.background.home,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: tokens.background.homeGradient),
        child: SafeArea(child: LayoutBuilder(builder: (context, bounds) {
          final wide = bounds.maxWidth >= kBreakpointMedium;
          final gutter = wide ? spacing.lg : spacing.md;
          final inlineTools = wide &&
              bounds.maxWidth / MediaQuery.textScalerOf(context).scale(1) >=
                  620;
          final inset = max(
              gutter, (bounds.maxWidth - HomePageScaffold.maxContentWidth) / 2);
          final showHeader = bounds.maxHeight >= 410 &&
              MediaQuery.viewInsetsOf(context).bottom == 0;
          return Padding(
              padding: EdgeInsets.fromLTRB(
                  inset, showHeader ? gutter : spacing.xs, inset, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showHeader) ...[
                      IllustratedPageHeader(
                        title: saints
                            ? strings.getVariableText(
                                frText: 'Calendrier des saints',
                                enText: 'Saints calendar',
                                crText: 'Kalandriye sen yo')
                            : strings.getText('40q38tw9'),
                        asset: saints
                            ? 'assets/images/home/shortcut_saints.webp'
                            : 'assets/images/home/shortcut_tchala.webp',
                        fallback: saints
                            ? Icons.calendar_month_rounded
                            : Icons.menu_book_rounded,
                      ),
                      SizedBox(height: spacing.md),
                    ],
                    if (inlineTools)
                      Row(children: [
                        Expanded(flex: 2, child: tabs),
                        SizedBox(width: spacing.md),
                        Expanded(flex: 3, child: search)
                      ])
                    else ...[
                      if (bounds.maxHeight > 230 ||
                          !_searchFocusNode.hasFocus) ...[
                        tabs,
                        SizedBox(height: spacing.sm),
                      ],
                      search,
                    ],
                    SizedBox(height: showHeader ? spacing.md : spacing.xs),
                    Expanded(
                        child: FutureBuilder<TchalaData>(
                            future: _data,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return Center(
                                    child: CircularProgressIndicator(
                                        color: theme.primary));
                              }
                              if (snapshot.hasError || !snapshot.hasData) {
                                return _LoadError(onRetry: _retryLoading);
                              }
                              final data = snapshot.requireData;
                              return TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _TchalaList(
                                        entries: data.symbols,
                                        query: _searchControllers[0].text),
                                    SaintsCalendar(
                                        months: data.saintMonths,
                                        query: _searchControllers[1].text,
                                        today: widget.today),
                                  ]);
                            })),
                  ]));
        })),
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
    final radius = theme.designToken.radius.md;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.search,
      cursorColor: theme.primary,
      style: theme.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            theme.bodyMedium.override(color: theme.designToken.home.mutedText),
        prefixIcon:
            Icon(Icons.search_rounded, color: theme.designToken.home.mutedText),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: FFLocalizations.of(context).getVariableText(
                  frText: 'Effacer',
                  enText: 'Clear',
                  crText: 'Efase',
                ),
                onPressed: onClear,
                icon: Icon(Icons.close_rounded,
                    color: theme.designToken.home.mutedText),
              ),
        filled: true,
        fillColor: theme.designToken.home.surface.colors.last,
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.designToken.home.panelEdge),
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
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final language = FFLocalizations.of(context).languageCode;
    final term = normalizeTchalaSearch(query);
    final visible = term.isEmpty
        ? entries
        : entries
            .where((entry) => [
                  entry.creoleSymbol,
                  entry.frenchTranslation,
                  entry.englishTranslation,
                  entry.associatedNumbers
                      .map((n) => n.toString().padLeft(2, '0'))
                      .join(' '),
                ].any((field) => normalizeTchalaSearch(field).contains(term)))
            .toList();
    if (visible.isEmpty) return const _EmptySearchResult();
    return LayoutBuilder(builder: (context, bounds) {
      final columns =
          bounds.maxWidth >= 840 * MediaQuery.textScalerOf(context).scale(1)
              ? 2
              : 1;
      return ListView.separated(
        key:
            term.isEmpty ? const PageStorageKey('tchala-list') : ValueKey(term),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(bottom: spacing.lg),
        itemCount: (visible.length / columns).ceil(),
        separatorBuilder: (_, __) => SizedBox(height: spacing.sm),
        itemBuilder: (context, index) {
          final first = index * columns;
          final card = _SymbolCard(entry: visible[first], language: language);
          if (columns == 1) return card;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: card),
            SizedBox(width: spacing.md),
            Expanded(
                child: first + 1 < visible.length
                    ? _SymbolCard(entry: visible[first + 1], language: language)
                    : const SizedBox.shrink()),
          ]);
        },
      );
    });
  }
}

class _SymbolCard extends StatelessWidget {
  const _SymbolCard({required this.entry, required this.language});
  final TchalaEntry entry;
  final String language;
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final (title, subtitle) = switch (language) {
      'en' => (entry.englishTranslation, entry.creoleSymbol),
      'cr' => (entry.creoleSymbol, entry.frenchTranslation),
      _ => (entry.frenchTranslation, entry.creoleSymbol),
    };
    final chipSize = max(36.0, MediaQuery.textScalerOf(context).scale(18) + 14);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.md, vertical: spacing.sm + spacing.xs),
      decoration: tokens.home.panel,
      child: MergeSemantics(
          child: OverflowBar(
        alignment: MainAxisAlignment.spaceBetween,
        spacing: spacing.md,
        overflowSpacing: spacing.sm,
        children: [
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.titleMedium
                        .copyWith(fontWeight: FontWeight.w800)),
                if (subtitle != title)
                  Text(subtitle,
                      style: theme.bodyMedium
                          .copyWith(color: tokens.home.mutedText)),
              ]),
          Wrap(spacing: spacing.xs, runSpacing: spacing.xs, children: [
            for (final n in entry.associatedNumbers)
              DrawResultChip(
                  value: n.toString().padLeft(2, '0'), size: chipSize),
          ]),
        ],
      )),
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
          style: theme.bodyMedium
              .override(color: theme.designToken.home.mutedText),
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
    return SingleChildScrollView(
        child: Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: EdgeInsets.all(theme.designToken.spacing.lg),
        decoration: theme.designToken.home.panel,
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
                foregroundColor: theme.primary,
                side: BorderSide(color: theme.designToken.home.panelEdge),
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
    ));
  }
}
