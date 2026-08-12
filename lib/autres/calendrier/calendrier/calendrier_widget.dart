import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'calendrier_model.dart';
export 'calendrier_model.dart';

class CalendrierWidget extends StatefulWidget {
  const CalendrierWidget({super.key});

  @override
  State<CalendrierWidget> createState() => _CalendrierWidgetState();
}

class _CalendrierWidgetState extends State<CalendrierWidget> {
  late CalendrierModel _model;
  late DateTime _displayedMonth;

  static const _monthNames = <String, List<String>>{
    'fr': [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ],
    'en': [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ],
    'cr': [
      'Janvye',
      'Fevriye',
      'Mas',
      'Avril',
      'Me',
      'Jen',
      'Jiyè',
      'Out',
      'Septanm',
      'Oktòb',
      'Novanm',
      'Desanm',
    ],
  };

  static const _weekdayNames = <String, List<String>>{
    'fr': ['L', 'M', 'M', 'J', 'V', 'S', 'D'],
    'en': ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    'cr': ['L', 'M', 'M', 'J', 'V', 'S', 'D'],
  };

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CalendrierModel());
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  String get _languageCode {
    final code = FFLocalizations.of(context).languageCode;
    return _monthNames.containsKey(code) ? code : 'fr';
  }

  String get _monthLabel =>
      '${_monthNames[_languageCode]![_displayedMonth.month - 1]} ${_displayedMonth.year}';

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return now.year == _displayedMonth.year &&
        now.month == _displayedMonth.month;
  }

  void _changeMonth(int amount) {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + amount);
    });
  }

  String _bingoCountLabel(int count) =>
      FFLocalizations.of(context).getVariableText(
        frText: count > 1 ? '$count bingos' : '$count bingo',
        enText: count > 1 ? '$count bingos' : '$count bingo',
        crText: '$count bingo',
      );

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final startOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month);
    final startOfNextMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18.0,
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0.0, 6.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 10.0),
        child: StreamBuilder<List<BingoRecord>>(
          stream: queryBingoRecord(
            queryBuilder: (query) => query
                .where('date', isGreaterThanOrEqualTo: startOfMonth)
                .where('date', isLessThan: startOfNextMonth)
                .orderBy('date'),
          ),
          builder: (context, snapshot) {
            final bingosByDay = <int, List<BingoRecord>>{};
            for (final bingo in snapshot.data ?? const <BingoRecord>[]) {
              final date = bingo.date;
              if (date != null) {
                bingosByDay.putIfAbsent(date.day, () => []).add(bingo);
              }
            }

            final bingoCount = bingosByDay.values.fold<int>(
              0,
              (total, records) {
                final entries = _entriesFor(records);
                return total +
                    (entries.isEmpty ? records.length : entries.length);
              },
            );

            return Column(
              children: [
                _CalendarHeader(
                  monthLabel: _monthLabel,
                  summary: snapshot.hasData
                      ? _bingoCountLabel(bingoCount)
                      : FFLocalizations.of(context).getVariableText(
                          frText: 'Chargement…',
                          enText: 'Loading…',
                          crText: 'Chajman…',
                        ),
                  isCurrentMonth: _isCurrentMonth,
                  onPrevious: () => _changeMonth(-1),
                  onNext: () => _changeMonth(1),
                  onToday: () {
                    final now = DateTime.now();
                    setState(
                        () => _displayedMonth = DateTime(now.year, now.month));
                  },
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: _weekdayNames[_languageCode]!
                      .map(
                        (day) => Expanded(
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: theme.labelSmall.override(
                              fontFamily: 'Google sans flex',
                              color: theme.secondaryText,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 7.0),
                Expanded(
                  child: snapshot.hasError
                      ? _CalendarError(onRetry: () => setState(() {}))
                      : _MonthGrid(
                          month: _displayedMonth,
                          bingosByDay: bingosByDay,
                          isLoading: !snapshot.hasData,
                          onDayPressed: _showDayDetails,
                        ),
                ),
                if (snapshot.hasData && bingoCount == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      FFLocalizations.of(context).getVariableText(
                        frText: 'Aucun bingo enregistré pour ce mois',
                        enText: 'No bingo recorded this month',
                        crText: 'Pa gen bingo ki anrejistre pou mwa sa a',
                      ),
                      textAlign: TextAlign.center,
                      style: theme.labelSmall.override(
                        fontFamily: 'Google sans flex',
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<DataStackStruct> _entriesFor(List<BingoRecord> records) =>
      records.expand((record) => record.dataStack).toList(growable: false);

  Future<void> _showDayDetails(
    int day,
    List<BingoRecord> records,
  ) async {
    final entries = _entriesFor(records);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => _BingoDaySheet(
        day: day,
        monthLabel: _monthLabel,
        entries: entries,
        fallbackRecordCount: records.length,
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.monthLabel,
    required this.summary,
    required this.isCurrentMonth,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final String monthLabel;
  final String summary;
  final bool isCurrentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      children: [
        _MonthButton(
          tooltip: MaterialLocalizations.of(context).previousMonthTooltip,
          icon: Icons.chevron_left_rounded,
          onPressed: onPrevious,
        ),
        Expanded(
          child: InkWell(
            key: const ValueKey('calendar-month-label'),
            borderRadius: BorderRadius.circular(10.0),
            onTap: isCurrentMonth ? null : onToday,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Column(
                children: [
                  Text(
                    monthLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleMedium.override(
                      fontFamily: 'Google sans flex',
                      fontSize: 17.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.0,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    summary,
                    style: theme.labelSmall.override(
                      fontFamily: 'Google sans flex',
                      color: theme.primary,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _MonthButton(
          tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
          icon: Icons.chevron_right_rounded,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: theme.primaryBackground,
        foregroundColor: theme.primaryText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 22.0),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.bingosByDay,
    required this.isLoading,
    required this.onDayPressed,
  });

  final DateTime month;
  final Map<int, List<BingoRecord>> bingosByDay;
  final bool isLoading;
  final Future<void> Function(int day, List<BingoRecord> records) onDayPressed;

  @override
  Widget build(BuildContext context) {
    final firstDayOffset = DateTime(month.year, month.month).weekday - 1;
    final numberOfDays = DateTime(month.year, month.month + 1, 0).day;
    final visibleCells = ((firstDayOffset + numberOfDays + 6) ~/ 7) * 7;

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
        childAspectRatio: 0.76,
      ),
      itemCount: visibleCells,
      itemBuilder: (context, index) {
        final day = index - firstDayOffset + 1;
        if (day < 1 || day > numberOfDays) {
          return const SizedBox.shrink();
        }
        final records = bingosByDay[day] ?? const <BingoRecord>[];
        return _DayTile(
          key: ValueKey('calendar-day-$day'),
          date: DateTime(month.year, month.month, day),
          records: records,
          isLoading: isLoading,
          onPressed: records.isEmpty ? null : () => onDayPressed(day, records),
        );
      },
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    super.key,
    required this.date,
    required this.records,
    required this.isLoading,
    required this.onPressed,
  });

  final DateTime date;
  final List<BingoRecord> records;
  final bool isLoading;
  final VoidCallback? onPressed;

  bool get _isToday {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  List<DataStackStruct> get _entries =>
      records.expand((record) => record.dataStack).toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final entries = _entries;
    final hasBingo = records.isNotEmpty;
    final displayedCount = entries.isEmpty ? records.length : entries.length;
    final colors = hasBingo
        ? const [Color(0xFFFFA726), Color(0xFFFF7043)]
        : [theme.primaryBackground, theme.primaryBackground];
    final foregroundColor = hasBingo ? Colors.white : theme.primaryText;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isLoading ? 0.45 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(11.0),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(11.0),
              border: Border.all(
                color: _isToday
                    ? theme.primary
                    : hasBingo
                        ? Colors.white.withValues(alpha: 0.24)
                        : theme.alternate.withValues(alpha: 0.7),
                width: _isToday ? 2.0 : 1.0,
              ),
              boxShadow: hasBingo
                  ? [
                      BoxShadow(
                        blurRadius: 7.0,
                        color: const Color(0xFFFF7043).withValues(alpha: 0.24),
                        offset: const Offset(0.0, 3.0),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '${date.day}',
                      style: theme.labelMedium.override(
                        fontFamily: 'Google sans flex',
                        color: foregroundColor,
                        fontSize: 11.0,
                        fontWeight:
                            _isToday ? FontWeight.w900 : FontWeight.w700,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: hasBingo
                        ? Center(
                            child: Image.asset(
                              'assets/images/bingo-2.png',
                              width: 27.0,
                              height: 27.0,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Center(
                            child: Container(
                              width: 4.0,
                              height: 4.0,
                              decoration: BoxDecoration(
                                color: theme.alternate,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                  ),
                  if (hasBingo)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        '×$displayedCount',
                        style: theme.labelSmall.override(
                          fontFamily: 'Google sans flex',
                          color: Colors.white,
                          fontSize: 9.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BingoDaySheet extends StatelessWidget {
  const _BingoDaySheet({
    required this.day,
    required this.monthLabel,
    required this.entries,
    required this.fallbackRecordCount,
  });

  final int day;
  final String monthLabel;
  final List<DataStackStruct> entries;
  final int fallbackRecordCount;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final count = entries.isEmpty ? fallbackRecordCount : entries.length;
    final countLabel = FFLocalizations.of(context).getVariableText(
      frText: count > 1 ? '$count bingos réalisés' : '$count bingo réalisé',
      enText: count > 1 ? '$count bingos completed' : '$count bingo completed',
      crText: '$count bingo fèt',
    );

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10.0),
            Container(
              width: 42.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 8.0, 12.0),
              child: Row(
                children: [
                  Container(
                    width: 46.0,
                    height: 46.0,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                      ),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Image.asset('assets/images/bingo-2.png'),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$day $monthLabel',
                          style: theme.titleLarge.override(
                            fontFamily: 'Google sans flex',
                            fontSize: 20.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.0,
                          ),
                        ),
                        Text(
                          countLabel,
                          style: theme.labelMedium.override(
                            fontFamily: 'Google sans flex',
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip:
                        MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1.0, color: theme.alternate),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Text(
                  FFLocalizations.of(context).getVariableText(
                    frText: 'Les détails de ce bingo ne sont pas disponibles.',
                    enText: 'The details for this bingo are not available.',
                    crText: 'Detay bingo sa a pa disponib.',
                  ),
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium,
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 24.0),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                  itemBuilder: (context, index) =>
                      _BingoDetailTile(entry: entries[index], index: index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BingoDetailTile extends StatelessWidget {
  const _BingoDetailTile({required this.entry, required this.index});

  final DataStackStruct entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final title = entry.tirage.isEmpty
        ? FFLocalizations.of(context).getVariableText(
            frText: 'Bingo ${index + 1}',
            enText: 'Bingo ${index + 1}',
            crText: 'Bingo ${index + 1}',
          )
        : entry.tirage;
    final details = [entry.valeur, entry.periode]
        .where((value) => value.trim().isNotEmpty)
        .join('  •  ');

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.75)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 7.0,
                  color: const Color(0xFFFFA726).withValues(alpha: 0.3),
                  offset: const Offset(0.0, 3.0),
                ),
              ],
            ),
            child: Text(
              entry.boul.isEmpty ? '—' : entry.boul,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: theme.titleMedium.override(
                fontFamily: 'Google sans flex',
                color: Colors.white,
                fontSize: entry.boul.length > 3 ? 13.0 : 17.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.0,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.titleMedium.override(
                    fontFamily: 'Google sans flex',
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.0,
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 3.0),
                  Text(
                    details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.labelMedium.override(
                      fontFamily: 'Google sans flex',
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarError extends StatelessWidget {
  const _CalendarError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: theme.secondaryText, size: 28.0),
          const SizedBox(height: 8.0),
          Text(
            FFLocalizations.of(context).getVariableText(
              frText: 'Impossible de charger les bingos',
              enText: 'Unable to load bingos',
              crText: 'Nou pa ka chaje bingo yo',
            ),
            textAlign: TextAlign.center,
            style: theme.labelMedium,
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18.0),
            label: Text(
              FFLocalizations.of(context).getVariableText(
                frText: 'Réessayer',
                enText: 'Retry',
                crText: 'Eseye ankò',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
