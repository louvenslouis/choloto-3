import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'tchala_data_repository.dart';
import 'tchala_search.dart';

/// Each catalogue date represents an annual celebration, independent of its
/// original year. A 29 February entry is observed on February's final day.
typedef _Feast = ({DateTime date, List<SaintEntry> saints});

String _capitalized(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

String _monthName(DateTime date, String language) => _capitalized(
    dateTimeFormat('MMMM y', date, locale: language).split(' ').first);

String _fullDate(DateTime date, String language) =>
    _capitalized(dateTimeFormat('MMMMEEEEd', date, locale: language));

List<_Feast> _catalogue(List<SaintMonth> months, int year) {
  final days = SplayTreeMap<DateTime, List<SaintEntry>>();
  for (final month in months) {
    for (final saint in month.saints) {
      final date = DateTime.tryParse(saint.date);
      if (date == null) continue;
      final lastDay = DateUtils.getDaysInMonth(year, date.month);
      final observed = DateTime(year, date.month, date.day.clamp(1, lastDay));
      (days[observed] ??= []).add(saint);
    }
  }
  return [for (final day in days.entries) (date: day.key, saints: day.value)];
}

class SaintsCalendar extends StatefulWidget {
  const SaintsCalendar(
      {super.key, required this.months, required this.query, this.today});
  final List<SaintMonth> months;
  final String query;
  final DateTime? today;
  @override
  State<SaintsCalendar> createState() => _SaintsCalendarState();
}

class _SaintsCalendarState extends State<SaintsCalendar>
    with WidgetsBindingObserver {
  late DateTime _today;
  late DateTime _month;
  final _calendars = <int, List<_Feast>>{};
  final _scroll = ScrollController(keepScrollOffset: false);
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    _today = DateUtils.dateOnly(widget.today ?? DateTime.now());
    _month = DateTime(_today.year, _today.month);
    WidgetsBinding.instance.addObserver(this);
    _scheduleDayChange();
  }

  void _scheduleDayChange() {
    _midnight?.cancel();
    if (widget.today != null) return;
    final next = DateTime(_today.year, _today.month, _today.day + 1);
    _midnight = Timer(next.difference(DateTime.now()), _updateClock);
  }

  void _updateClock() {
    final next = DateUtils.dateOnly(widget.today ?? DateTime.now());
    if (next != _today) {
      setState(() {
        if (DateUtils.isSameMonth(_month, _today)) {
          _month = DateTime(next.year, next.month);
        }
        _today = next;
      });
    }
    _scheduleDayChange();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _updateClock();
  }

  @override
  void didUpdateWidget(SaintsCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.months != oldWidget.months) _calendars.clear();
    if (widget.today != oldWidget.today) _updateClock();
    if (widget.query != oldWidget.query && _scroll.hasClients) {
      _scroll.jumpTo(0);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnight?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _selectMonth(DateTime date) {
    if (_scroll.hasClients) _scroll.jumpTo(0);
    setState(() => _month = DateTime(date.year, date.month));
  }

  List<_Feast> _inYear(int year) {
    if (_calendars.length > 4) _calendars.clear();
    return _calendars.putIfAbsent(year, () => _catalogue(widget.months, year));
  }

  Iterable<_Feast> _upcoming() sync* {
    yield* _inYear(_today.year).where((entry) => !entry.date.isBefore(_today));
    yield* _inYear(_today.year + 1);
  }

  List<_Feast> _search(String raw, String language) {
    final query = raw.trim();
    final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(query);
    final numeric =
        RegExp(r'^(\d{1,2})[/.-](\d{1,2})(?:[/.-](\d{4}))?$').firstMatch(query);
    final monthFirst = language == 'en' &&
        numeric != null &&
        int.parse(numeric.group(1)!) <= 12;
    final month = iso == null
        ? int.tryParse(numeric?.group(monthFirst ? 1 : 2) ?? '')
        : int.parse(iso.group(2)!);
    final day = iso == null
        ? int.tryParse(numeric?.group(monthFirst ? 2 : 1) ?? '')
        : int.parse(iso.group(3)!);
    final explicitYear = RegExp(r'\b\d{4}\b').firstMatch(query)?.group(0);
    final year = int.tryParse(explicitYear ?? '') ?? _month.year;
    final terms = normalizeTchalaSearch(query)
        .split(' ')
        .where((s) => s.isNotEmpty && s != explicitYear)
        .toList();
    const titles = {
      'saint',
      'sainte',
      'saints',
      'saintes',
      'st',
      'st.',
      'ste',
      'ste.',
      'sen'
    };
    if (terms.any((term) => !titles.contains(term))) {
      terms.removeWhere(titles.contains);
    }
    if (terms.isEmpty && explicitYear == null) return [];
    final matches = <_Feast>[];
    final monthNames = <int, String>{};
    for (final entry in _inYear(year)) {
      final date = entry.date;
      final names = <SaintEntry>[];
      if (month != null && day != null) {
        if (date.month == month && date.day == day) names.addAll(entry.saints);
      } else {
        final months = monthNames.putIfAbsent(
            date.month,
            () => ['fr', 'en', 'cr']
                .map((locale) => _monthName(date, locale))
                .join(' '));
        for (final saint in entry.saints) {
          final translations =
              ['fr', 'en', 'cr'].map(saint.localizedName).join(' ');
          final words = normalizeTchalaSearch('$translations $months');
          if (terms.every((term) {
            final number = int.tryParse(term);
            return number == null ? words.contains(term) : date.day == number;
          })) {
            names.add(saint);
          }
        }
      }
      if (names.isNotEmpty) matches.add((date: date, saints: names));
    }
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final strings = FFLocalizations.of(context);
    final language = strings.languageCode;
    final spacing = theme.designToken.spacing;
    final searching = widget.query.trim().isNotEmpty;
    final results = searching
        ? _search(widget.query, language)
        : _inYear(_month.year)
            .where((entry) => entry.date.month == _month.month)
            .toList();
    final groups = <int, List<_Feast>>{};
    for (final result in results) {
      (groups[result.date.month] ??= []).add(result);
    }
    final forthcoming =
        searching ? const <_Feast>[] : _upcoming().take(4).toList();
    final controls = Row(children: [
      Expanded(
          child: PopupMenuButton<int>(
        key: const ValueKey('saints-month-picker'),
        tooltip: strings.getVariableText(
            frText: 'Choisir le mois',
            enText: 'Choose month',
            crText: 'Chwazi mwa a'),
        color: theme.designToken.home.surface.colors.first,
        initialValue: _month.month,
        onSelected: (month) => _selectMonth(DateTime(_month.year, month)),
        itemBuilder: (context) => [
          for (var month = 1; month <= 12; month++)
            PopupMenuItem(
                value: month,
                child: Text(_monthName(DateTime(_month.year, month), language),
                    style: theme.titleSmall)),
        ],
        child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(children: [
              Flexible(
                  child: Text(
                      _capitalized(
                          dateTimeFormat('MMMM y', _month, locale: language)),
                      style: theme.titleLarge
                          .copyWith(fontWeight: FontWeight.w800))),
              Icon(Icons.expand_more_rounded,
                  color: theme.designToken.home.mutedText),
            ])),
      )),
      if (!DateUtils.isSameMonth(_month, _today))
        IconButton(
            key: const ValueKey('saints-today'),
            tooltip: strings.getVariableText(
                frText: 'Revenir au mois en cours',
                enText: 'Return to current month',
                crText: 'Retounen nan mwa sa a'),
            onPressed: () => _selectMonth(_today),
            icon: Icon(Icons.today_rounded, color: theme.primary)),
      IconButton(
          key: const ValueKey('saints-previous-month'),
          tooltip: strings.getVariableText(
              frText: 'Mois précédent',
              enText: 'Previous month',
              crText: 'Mwa anvan'),
          onPressed: () =>
              _selectMonth(DateTime(_month.year, _month.month - 1)),
          icon: Icon(Icons.chevron_left_rounded,
              color: theme.designToken.home.mutedText)),
      IconButton(
          key: const ValueKey('saints-next-month'),
          tooltip: strings.getVariableText(
              frText: 'Mois suivant', enText: 'Next month', crText: 'Mwa apre'),
          onPressed: () =>
              _selectMonth(DateTime(_month.year, _month.month + 1)),
          icon: Icon(Icons.chevron_right_rounded,
              color: theme.designToken.home.mutedText)),
    ]);
    return LayoutBuilder(
        key: const ValueKey('saints-calendar'),
        builder: (context, constraints) {
          final wide = constraints.maxWidth >=
              840 * MediaQuery.textScalerOf(context).scale(16) / 16;
          final spotlight = forthcoming.isEmpty
              ? null
              : _Spotlight(
                  focus: forthcoming.first,
                  today: _today,
                  upcoming: forthcoming.skip(1).take(wide ? 3 : 1).toList(),
                );
          final body = ListView(
              controller: _scroll,
              primary: false,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(bottom: spacing.lg),
              children: [
                if (!wide &&
                    spotlight != null &&
                    DateUtils.isSameMonth(_month, _today)) ...[
                  spotlight,
                  SizedBox(height: spacing.sm)
                ],
                if (!searching) controls,
                if (results.isEmpty)
                  Padding(
                      key: const ValueKey('saints-no-results'),
                      padding: EdgeInsets.all(spacing.lg),
                      child: Text(
                          searching
                              ? strings.getVariableText(
                                  frText: 'Aucun résultat trouvé.',
                                  enText: 'No results found.',
                                  crText: 'Pa gen rezilta.')
                              : strings.getVariableText(
                                  frText:
                                      'Aucune célébration répertoriée ce mois-ci.',
                                  enText: 'No celebrations listed this month.',
                                  crText:
                                      'Pa gen fèt ki nan lis pou mwa sa a.'),
                          textAlign: TextAlign.center,
                          style: theme.bodyMedium.copyWith(
                              color: theme.designToken.home.mutedText))),
                for (final entries in groups.values) ...[
                  if (searching)
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: spacing.sm),
                        child: Semantics(
                            header: true,
                            child: Text(
                                _capitalized(dateTimeFormat(
                                    'MMMM y', entries.first.date,
                                    locale: language)),
                                style: theme.titleMedium
                                    .copyWith(fontWeight: FontWeight.w800)))),
                  _Agenda(entries: entries, today: _today),
                  SizedBox(height: spacing.sm),
                ]
              ]);
          if (!wide || spotlight == null) return body;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Flexible(
                flex: 4,
                child: SingleChildScrollView(primary: false, child: spotlight)),
            SizedBox(width: spacing.lg),
            Expanded(flex: 7, child: body),
          ]);
        });
  }
}

class _Spotlight extends StatelessWidget {
  const _Spotlight(
      {required this.focus, required this.upcoming, required this.today});
  final _Feast focus;
  final List<_Feast> upcoming;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final strings = FFLocalizations.of(context);
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final sp = tokens.spacing;
    final isToday = DateUtils.isSameDay(today, focus.date);
    final label = isToday
        ? strings.getVariableText(
            frText: 'Aujourd’hui', enText: 'Today', crText: 'Jodi a')
        : strings.getVariableText(
            frText: 'Prochaine célébration',
            enText: 'Next celebration',
            crText: 'Pwochen fèt');
    final gold = tokens.vip.goldLight;
    return Container(
        key: const ValueKey('saints-focus'),
        decoration: tokens.home.panel,
        padding: EdgeInsets.all(sp.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.calendar_today_rounded, size: 18, color: gold),
            SizedBox(width: sp.sm),
            Expanded(
                child: Text(label,
                    style: theme.labelLarge
                        .copyWith(color: gold, fontWeight: FontWeight.w700))),
          ]),
          SizedBox(height: sp.sm),
          for (final (index, saint) in focus.saints.indexed) ...[
            if (index > 0) SizedBox(height: sp.xs),
            Text(saint.localizedName(strings.languageCode),
                style: (focus.saints.length == 1
                        ? theme.headlineSmall
                        : theme.titleLarge)
                    .copyWith(
                  color: theme.primaryText,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                )),
          ],
          SizedBox(height: sp.xs),
          Text(_fullDate(focus.date, strings.languageCode),
              style: theme.bodyMedium.copyWith(color: tokens.home.mutedText)),
          if (upcoming.isNotEmpty) ...[
            SizedBox(height: sp.md),
            Divider(height: 1, color: tokens.home.panelEdge),
            SizedBox(height: sp.sm),
            Text(
                strings.getVariableText(
                    frText: 'À venir',
                    enText: 'Coming up',
                    crText: 'K ap vini'),
                style: theme.labelMedium.copyWith(
                    color: tokens.home.mutedText, fontWeight: FontWeight.w600)),
            for (final feast in upcoming)
              Padding(
                  padding: EdgeInsets.only(top: sp.sm),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            dateTimeFormat('MMMd', feast.date,
                                locale: strings.languageCode),
                            style: theme.labelMedium.copyWith(
                                color: gold, fontWeight: FontWeight.w700)),
                        SizedBox(width: sp.sm),
                        Expanded(
                            child: Text(
                                feast.saints
                                    .map((s) =>
                                        s.localizedName(strings.languageCode))
                                    .join('\n'),
                                style: theme.bodyMedium
                                    .copyWith(color: theme.primaryText))),
                      ]))
          ],
        ]));
  }
}

class _Agenda extends StatelessWidget {
  const _Agenda({required this.entries, required this.today});
  final List<_Feast> entries;
  final DateTime today;
  @override
  Widget build(BuildContext context) {
    final strings = FFLocalizations.of(context);
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final sp = tokens.spacing;
    return Container(
        decoration: tokens.home.panel,
        padding: EdgeInsets.symmetric(horizontal: sp.md),
        child: Column(children: [
          for (final (index, feast) in entries.indexed) ...[
            if (index > 0) Divider(height: 1, color: tokens.home.panelEdge),
            Padding(
                padding: EdgeInsets.symmetric(vertical: sp.sm),
                child: MergeSemantics(
                    child: Row(children: [
                  ExcludeSemantics(
                      child: Container(
                          width: 48 *
                              MediaQuery.textScalerOf(context).scale(16) /
                              16,
                          constraints: const BoxConstraints(minHeight: 46),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: DateUtils.isSameDay(feast.date, today)
                                  ? theme.primary
                                  : tokens.background.home,
                              borderRadius:
                                  BorderRadius.circular(tokens.radius.sm)),
                          child: Text(feast.date.day.toString().padLeft(2, '0'),
                              style: theme.titleLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: DateUtils.isSameDay(feast.date, today)
                                      ? theme.onPrimary
                                      : tokens.vip.goldLight)))),
                  SizedBox(width: sp.md),
                  Expanded(
                      child: Semantics(
                          label: _fullDate(feast.date, strings.languageCode),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final saint in feast.saints)
                                  Text(
                                      saint.localizedName(strings.languageCode),
                                      style: theme.titleSmall.copyWith(
                                          fontWeight: FontWeight.w600)),
                              ]))),
                ]))),
          ],
        ]));
  }
}
