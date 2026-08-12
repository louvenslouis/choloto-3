import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';

class VipHistoryWidget extends StatefulWidget {
  const VipHistoryWidget({super.key});

  static String routeName = 'vipHistory';
  static String routePath = '/vip-history';

  @override
  State<VipHistoryWidget> createState() => _VipHistoryWidgetState();
}

class _VipHistoryWidgetState extends State<VipHistoryWidget> {
  late Stream<List<PredictionRecord>> _historyStream;
  final Set<String> _expandedPredictionIds = <String>{};
  String? _latestPredictionId;
  DateTime? _selectedDate;
  DateTime? _displayedMonth;

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'vipHistory'});
    _historyStream = _createHistoryStream();
  }

  Stream<List<PredictionRecord>> _createHistoryStream() {
    return queryPredictionRecord(
      queryBuilder: (records) => records.orderBy('date', descending: true),
      limit: 20,
    );
  }

  Future<void> _reloadHistory() async {
    final refreshedStream = _createHistoryStream();
    safeSetState(() => _historyStream = refreshedStream);

    try {
      await refreshedStream.first;
    } catch (_) {
      // The StreamBuilder displays the localized error state.
    }
  }

  bool get _hasVipAccess {
    final subscriptionEnd = currentUserDocument?.endSub;
    return loggedIn &&
        subscriptionEnd != null &&
        subscriptionEnd >= getCurrentTimestamp;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF3E0066),
        appBar: AppBar(
          backgroundColor: const Color(0xFF650BB0),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: theme.designToken.radius.full,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.onDecorative,
              size: 28.0,
            ),
            onPressed: () async {
              logFirebaseEvent('VIP_HISTORY_BACK_ON_TAP');
              context.safePop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText('viphstttl'),
            style: theme.headlineMedium.override(
              fontFamily: 'Google sans flex',
              color: theme.onDecorative,
              fontSize: 22.0,
              letterSpacing: 0.0,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                end: theme.designToken.spacing.sm,
              ),
              child: Tooltip(
                message: FFLocalizations.of(context).getText('viphstrty'),
                child: FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: theme.designToken.radius.full,
                  buttonSize: 40.0,
                  showLoadingIndicator: true,
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: theme.onDecorative.applyAlpha(0.82),
                    size: 21.0,
                  ),
                  onPressed: _reloadHistory,
                ),
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: AuthUserStreamWidget(
            builder: (context) {
              if (loggedIn && currentUserDocument == null) {
                return const _VipHistoryLoading();
              }

              if (!_hasVipAccess) {
                return const _VipHistoryAccessDenied();
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760.0),
                  child: StreamBuilder<List<PredictionRecord>>(
                    stream: _historyStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _VipHistoryMessage(
                          icon: Icons.cloud_off_rounded,
                          title:
                              FFLocalizations.of(context).getText('viphsterr'),
                          description:
                              FFLocalizations.of(context).getText('viphsterd'),
                          buttonText:
                              FFLocalizations.of(context).getText('viphstrty'),
                          onPressed: _reloadHistory,
                        );
                      }

                      if (!snapshot.hasData) {
                        return const _VipHistoryLoading();
                      }

                      final predictions = snapshot.data!;
                      final predictionsByDay =
                          _groupPredictionsByDay(predictions);
                      _expandLatestPrediction(predictions);
                      _initializeCalendar(predictionsByDay);

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final horizontalPadding = constraints.maxWidth < 480
                              ? 12.0
                              : theme.designToken.spacing.md;
                          final availableDates = predictionsByDay.keys.toList()
                            ..sort();
                          final selectedPredictions = _selectedDate == null
                              ? const <PredictionRecord>[]
                              : predictionsByDay[_selectedDate] ??
                                  const <PredictionRecord>[];
                          final hasDatedPredictions =
                              predictionsByDay.isNotEmpty;
                          final itemCount = !hasDatedPredictions
                              ? 2
                              : selectedPredictions.isEmpty
                                  ? 4
                                  : selectedPredictions.length + 3;

                          return RefreshIndicator(
                            color: theme.primary,
                            backgroundColor: theme.secondaryBackground,
                            onRefresh: _reloadHistory,
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                12.0,
                                horizontalPadding,
                                80.0,
                              ),
                              itemCount: itemCount,
                              separatorBuilder: (_, __) => const SizedBox(
                                height: 10.0,
                              ),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _VipHistoryHeading(
                                    publicationCount: predictions.length,
                                  );
                                }

                                if (!hasDatedPredictions) {
                                  return _VipHistoryEmptyState(
                                    onRefresh: _reloadHistory,
                                  );
                                }

                                if (index == 1) {
                                  return _VipPredictionCalendar(
                                    displayedMonth: _displayedMonth!,
                                    selectedDate: _selectedDate!,
                                    predictionsByDay: predictionsByDay,
                                    firstMonth: _monthOf(availableDates.first),
                                    lastMonth: _monthOf(availableDates.last),
                                    onPreviousMonth: () => _changeMonth(
                                      -1,
                                      predictionsByDay,
                                    ),
                                    onNextMonth: () => _changeMonth(
                                      1,
                                      predictionsByDay,
                                    ),
                                    onDateSelected: (date) =>
                                        _selectDate(date, predictionsByDay),
                                  );
                                }

                                if (index == 2) {
                                  return _VipSelectedDayHeading(
                                    selectedDate: _selectedDate!,
                                    publicationCount:
                                        selectedPredictions.length,
                                  );
                                }

                                if (selectedPredictions.isEmpty) {
                                  return const _VipHistoryDayEmptyState();
                                }

                                final prediction =
                                    selectedPredictions[index - 3];
                                final predictionId = prediction.reference.path;
                                final isExpanded = _expandedPredictionIds
                                    .contains(predictionId);

                                return RepaintBoundary(
                                  key: ValueKey(predictionId),
                                  child: _VipPredictionHistoryCard(
                                    prediction: prediction,
                                    isLatest: prediction.reference ==
                                        predictions.first.reference,
                                    initiallyExpanded: isExpanded,
                                    onExpansionChanged: (expanded) {
                                      safeSetState(() {
                                        if (expanded) {
                                          _expandedPredictionIds
                                              .add(predictionId);
                                        } else {
                                          _expandedPredictionIds
                                              .remove(predictionId);
                                        }
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _expandLatestPrediction(List<PredictionRecord> predictions) {
    if (predictions.isEmpty) return;

    final latestId = predictions.first.reference.path;
    if (_latestPredictionId == latestId) return;

    _latestPredictionId = latestId;
    _expandedPredictionIds.add(latestId);
  }

  Map<DateTime, List<PredictionRecord>> _groupPredictionsByDay(
    List<PredictionRecord> predictions,
  ) {
    final grouped = <DateTime, List<PredictionRecord>>{};

    for (final prediction in predictions) {
      final date = prediction.date;
      if (date == null) continue;

      final day = _dateOnly(date);
      grouped.putIfAbsent(day, () => <PredictionRecord>[]).add(prediction);
    }

    return grouped;
  }

  void _initializeCalendar(
    Map<DateTime, List<PredictionRecord>> predictionsByDay,
  ) {
    if (predictionsByDay.isEmpty || _selectedDate != null) return;

    final dates = predictionsByDay.keys.toList()..sort();
    final latestDate = dates.last;
    _selectedDate = latestDate;
    _displayedMonth = _monthOf(latestDate);
  }

  void _selectDate(
    DateTime date,
    Map<DateTime, List<PredictionRecord>> predictionsByDay,
  ) {
    final selectedDay = _dateOnly(date);
    safeSetState(() {
      _selectedDate = selectedDay;
      final publications = predictionsByDay[selectedDay];
      if (publications != null && publications.isNotEmpty) {
        _expandedPredictionIds.add(publications.first.reference.path);
      }
    });
  }

  void _changeMonth(
    int offset,
    Map<DateTime, List<PredictionRecord>> predictionsByDay,
  ) {
    final currentMonth = _displayedMonth!;
    final nextMonth = DateTime(
      currentMonth.year,
      currentMonth.month + offset,
    );
    final datesInMonth = predictionsByDay.keys
        .where(
          (date) =>
              date.year == nextMonth.year && date.month == nextMonth.month,
        )
        .toList()
      ..sort();

    safeSetState(() {
      _displayedMonth = nextMonth;
      _selectedDate = datesInMonth.isEmpty ? nextMonth : datesInMonth.last;
      final publications = predictionsByDay[_selectedDate];
      if (publications != null && publications.isNotEmpty) {
        _expandedPredictionIds.add(publications.first.reference.path);
      }
    });
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);
}

class _VipHistoryHeading extends StatelessWidget {
  const _VipHistoryHeading({required this.publicationCount});

  final int publicationCount;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final publicationLabel = publicationCount == 1
        ? FFLocalizations.of(context).getText('viphstpub')
        : FFLocalizations.of(context).getText('viphstpbs');

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
        border: Border.all(color: theme.alternate.applyAlpha(0.14)),
        boxShadow: [theme.designToken.shadow.md],
      ),
      child: Row(
        children: [
          Container(
            width: 42.0,
            height: 42.0,
            decoration: BoxDecoration(
              color: theme.primary.applyAlpha(0.14),
              borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
            ),
            child: Icon(
              Icons.history_rounded,
              color: theme.primary,
              size: 21.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        FFLocalizations.of(context).getText('viphsthed'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.titleSmall.override(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primary.applyAlpha(0.14),
                        borderRadius: BorderRadius.circular(
                            theme.designToken.radius.full),
                      ),
                      child: Text(
                        '$publicationCount $publicationLabel',
                        style: theme.labelSmall.override(
                          color: theme.primary,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3.0),
                Text(
                  FFLocalizations.of(context).getText('viphstdsc'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                    lineHeight: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VipPredictionCalendar extends StatelessWidget {
  const _VipPredictionCalendar({
    required this.displayedMonth,
    required this.selectedDate,
    required this.predictionsByDay,
    required this.firstMonth,
    required this.lastMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Map<DateTime, List<PredictionRecord>> predictionsByDay;
  final DateTime firstMonth;
  final DateTime lastMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final firstDay = DateTime(displayedMonth.year, displayedMonth.month);
    final daysInMonth =
        DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    final firstWeekdayFromSunday = firstDay.weekday % 7;
    final languageCode = FFLocalizations.of(context).languageCode;
    final firstDayOfWeekIndex =
        languageCode == 'cr' ? 1 : localizations.firstDayOfWeekIndex;
    final weekdayLabels = languageCode == 'cr'
        ? const <String>['D', 'L', 'M', 'M', 'J', 'V', 'S']
        : localizations.narrowWeekdays;
    final leadingDays = (firstWeekdayFromSunday - firstDayOfWeekIndex + 7) % 7;
    final cellCount = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;
    final canGoBack = displayedMonth.isAfter(firstMonth);
    final canGoForward = displayedMonth.isBefore(lastMonth);

    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
        border: Border.all(color: theme.alternate.applyAlpha(0.14)),
        boxShadow: [theme.designToken.shadow.md],
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520.0),
          child: Column(
            children: [
              Row(
                children: [
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: theme.designToken.radius.full,
                    buttonSize: 38.0,
                    disabledIconColor: theme.secondaryText.applyAlpha(0.35),
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: theme.primaryText,
                      size: 24.0,
                    ),
                    onPressed: canGoBack ? onPreviousMonth : null,
                  ),
                  Expanded(
                    child: Text(
                      _formatVipMonth(context, displayedMonth),
                      textAlign: TextAlign.center,
                      style: theme.titleMedium.override(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: theme.designToken.radius.full,
                    buttonSize: 38.0,
                    disabledIconColor: theme.secondaryText.applyAlpha(0.35),
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.primaryText,
                      size: 24.0,
                    ),
                    onPressed: canGoForward ? onNextMonth : null,
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              Row(
                children: List.generate(7, (index) {
                  final weekdayIndex = (firstDayOfWeekIndex + index) % 7;
                  return Expanded(
                    child: Text(
                      weekdayLabels[weekdayIndex],
                      textAlign: TextAlign.center,
                      style: theme.labelSmall.override(
                        color: theme.secondaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6.0),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cellCount,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final dayNumber = index - leadingDays + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final date = DateTime(
                    displayedMonth.year,
                    displayedMonth.month,
                    dayNumber,
                  );
                  return _VipCalendarDay(
                    date: date,
                    isSelected: _sameDay(date, selectedDate),
                    isToday: _sameDay(date, DateTime.now()),
                    publicationCount: predictionsByDay[date]?.length ?? 0,
                    onTap: () => onDateSelected(date),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _VipCalendarDay extends StatelessWidget {
  const _VipCalendarDay({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.publicationCount,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final int publicationCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final hasPredictions = publicationCount > 0;
    final foregroundColor = isSelected ? theme.onPrimary : theme.primaryText;

    return Semantics(
      button: true,
      selected: isSelected,
      label: _formatVipFullDate(context, date),
      value: '$publicationCount',
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: theme.primary.applyAlpha(0.16),
            highlightColor: theme.primary.applyAlpha(0.08),
            child: Ink(
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primary
                    : hasPredictions
                        ? theme.primaryBackground
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: isSelected
                      ? theme.primary
                      : hasPredictions
                          ? theme.primary.applyAlpha(0.48)
                          : isToday
                              ? theme.primaryText.applyAlpha(0.38)
                              : Colors.transparent,
                  width: isToday && !isSelected ? 1.2 : 1.0,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: theme.labelMedium.override(
                      color: foregroundColor,
                      fontWeight: isSelected || hasPredictions
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
                  if (hasPredictions)
                    Positioned(
                      bottom: 4.0,
                      child: Container(
                        width: 4.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: isSelected ? theme.onPrimary : theme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  if (publicationCount > 1)
                    Positioned(
                      top: 2.0,
                      right: 2.0,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 15.0),
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.onPrimary : theme.primary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          '$publicationCount',
                          textAlign: TextAlign.center,
                          style: theme.labelSmall.override(
                            color: isSelected ? theme.primary : theme.onPrimary,
                            fontSize: 8.0,
                            fontWeight: FontWeight.w800,
                          ),
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

class _VipSelectedDayHeading extends StatelessWidget {
  const _VipSelectedDayHeading({
    required this.selectedDate,
    required this.publicationCount,
  });

  final DateTime selectedDate;
  final int publicationCount;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final publicationLabel = publicationCount == 1
        ? FFLocalizations.of(context).getText('viphstpub')
        : FFLocalizations.of(context).getText('viphstpbs');

    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 0.0),
      child: Row(
        children: [
          Icon(
            Icons.event_available_rounded,
            color: theme.primary,
            size: 20.0,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _formatVipFullDate(context, selectedDate),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.titleSmall.override(
                color: theme.onDecorative,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: theme.primary.applyAlpha(0.14),
              borderRadius:
                  BorderRadius.circular(theme.designToken.radius.full),
            ),
            child: Text(
              '$publicationCount $publicationLabel',
              style: theme.labelSmall.override(
                color: theme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VipPredictionHistoryCard extends StatelessWidget {
  const _VipPredictionHistoryCard({
    required this.prediction,
    required this.isLatest,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
  });

  final PredictionRecord prediction;
  final bool isLatest;
  final bool initiallyExpanded;
  final ValueChanged<bool> onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final categories = initiallyExpanded
        ? _categoriesFor(context, prediction)
        : const <_VipPredictionCategory>[];
    final selectionCount = _selectionCount(prediction);
    final selectionLabel = selectionCount == 1
        ? FFLocalizations.of(context).getText('viphstsel')
        : FFLocalizations.of(context).getText('viphstses');

    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
        border: Border.all(
          color: isLatest
              ? theme.primary.applyAlpha(0.55)
              : theme.alternate.applyAlpha(0.14),
          width: isLatest ? 1.4 : 1.0,
        ),
        boxShadow: [theme.designToken.shadow.md],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          maintainState: false,
          onExpansionChanged: onExpansionChanged,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 4.0,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            12.0,
            0.0,
            12.0,
            12.0,
          ),
          iconColor: theme.primary,
          collapsedIconColor: theme.primary,
          backgroundColor: theme.primaryBackground,
          collapsedBackgroundColor: theme.primaryBackground,
          leading: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: theme.primary.applyAlpha(0.12),
              borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
            ),
            child: Icon(
              Icons.insights_rounded,
              color: theme.primary,
              size: 20.0,
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  prediction.date == null
                      ? FFLocalizations.of(context).getText('viphstnod')
                      : _formatVipCompactDate(context, prediction.date!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.titleSmall.override(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isLatest) ...[
                const SizedBox(width: 6.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7.0,
                    vertical: 3.0,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius:
                        BorderRadius.circular(theme.designToken.radius.full),
                  ),
                  child: Text(
                    FFLocalizations.of(context).getText('viphstnew'),
                    style: theme.labelSmall.override(
                      color: theme.onPrimary,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 3.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (prediction.periode.isNotEmpty)
                  _VipHistoryMetadata(
                    icon: Icons.wb_twilight_rounded,
                    label: prediction.periode,
                  ),
                if (prediction.hasPourcentage())
                  _VipHistoryMetadata(
                    icon: Icons.timeline_rounded,
                    label: '${prediction.pourcentage}%',
                    accent: true,
                  ),
                _VipHistoryMetadata(
                  icon: Icons.numbers_rounded,
                  label: '$selectionCount $selectionLabel',
                ),
              ],
            ),
          ),
          children: [
            const Divider(
              height: 12.0,
              thickness: 1.0,
              color: Color(0xFF3E0066),
            ),
            if (categories.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(theme.designToken.spacing.md),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius:
                      BorderRadius.circular(theme.designToken.radius.sm),
                ),
                child: Text(
                  FFLocalizations.of(context).getText('viphstnos'),
                  textAlign: TextAlign.center,
                  style: theme.bodySmall.override(color: theme.secondaryText),
                ),
              )
            else
              _VipPredictionCategories(categories: categories),
          ],
        ),
      ),
    );
  }

  int _selectionCount(PredictionRecord record) {
    return <List<String>>[
      record.favori.boul,
      record.soutni.boul,
      record.boloto.boul,
      record.mariage.boul,
      record.chif3.boul,
      record.chif4.boul,
      record.extra.boul,
    ].fold<int>(
      0,
      (total, values) =>
          total + values.where((value) => value.trim().isNotEmpty).length,
    );
  }

  List<_VipPredictionCategory> _categoriesFor(
    BuildContext context,
    PredictionRecord record,
  ) {
    final categories = <_VipPredictionCategory>[
      _VipPredictionCategory(
        label: record.favori.name.isEmpty
            ? FFLocalizations.of(context).getText('viphstfav')
            : record.favori.name,
        icon: Icons.star_rounded,
        values: record.favori.boul,
      ),
      _VipPredictionCategory(
        label: record.soutni.name.isEmpty
            ? FFLocalizations.of(context).getText('viphstsou')
            : record.soutni.name,
        icon: Icons.people_alt_rounded,
        values: record.soutni.boul,
      ),
      _VipPredictionCategory(
        label: record.boloto.name.isEmpty
            ? FFLocalizations.of(context).getText('viphstbol')
            : record.boloto.name,
        icon: Icons.casino_rounded,
        values: record.boloto.boul,
      ),
      _VipPredictionCategory(
        label: record.mariage.name.isEmpty
            ? FFLocalizations.of(context).getText('viphstmar')
            : record.mariage.name,
        icon: Icons.link_rounded,
        values: record.mariage.boul,
      ),
      _VipPredictionCategory(
        label: record.chif3.name.isEmpty
            ? FFLocalizations.of(context).getText('viphstc3f')
            : record.chif3.name,
        icon: Icons.looks_3_rounded,
        values: record.chif3.boul,
      ),
      _VipPredictionCategory(
        label: record.chif4.name.isEmpty
            ? FFLocalizations.of(context).getText('viphstc4f')
            : record.chif4.name,
        icon: Icons.looks_4_rounded,
        values: record.chif4.boul,
      ),
      _VipPredictionCategory(
        label: record.extra.name.isEmpty
            ? FFLocalizations.of(context).getText('viphstext')
            : record.extra.name,
        icon: Icons.auto_awesome_rounded,
        values: record.extra.boul,
      ),
    ];

    return categories
        .map(
          (category) => category.copyWith(
            values: category.values
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toList(),
          ),
        )
        .where((category) => category.values.isNotEmpty)
        .toList();
  }
}

class _VipPredictionCategories extends StatelessWidget {
  const _VipPredictionCategories({required this.categories});

  final List<_VipPredictionCategory> categories;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final columns = constraints.maxWidth >= 560.0 ? 2 : 1;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: categories
              .map(
                (category) => SizedBox(
                  width: itemWidth,
                  child: _VipPredictionCategoryRow(category: category),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _VipHistoryMetadata extends StatelessWidget {
  const _VipHistoryMetadata({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final color = accent ? theme.primary : theme.secondaryText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13.0),
        SizedBox(width: theme.designToken.spacing.xs),
        Text(
          label,
          style: theme.labelSmall.override(
            color: color,
            fontWeight: accent ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VipPredictionCategoryRow extends StatelessWidget {
  const _VipPredictionCategoryRow({required this.category});

  final _VipPredictionCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.designToken.spacing.sm),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
        border: Border.all(color: theme.alternate.applyAlpha(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, color: theme.primary, size: 18.0),
              SizedBox(width: theme.designToken.spacing.sm),
              Expanded(
                child: Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.labelMedium.override(
                    color: theme.primaryText,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                '${category.values.length}',
                style: theme.labelSmall.override(
                  color: theme.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: theme.designToken.spacing.sm),
          Wrap(
            spacing: theme.designToken.spacing.sm,
            runSpacing: theme.designToken.spacing.sm,
            children: category.values
                .map(
                  (value) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 7.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryBackground,
                      borderRadius:
                          BorderRadius.circular(theme.designToken.radius.sm),
                      border: Border.all(
                        color: theme.primary.applyAlpha(0.50),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      value,
                      style: theme.titleSmall.override(
                        color: theme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _VipPredictionCategory {
  const _VipPredictionCategory({
    required this.label,
    required this.icon,
    required this.values,
  });

  final String label;
  final IconData icon;
  final List<String> values;

  _VipPredictionCategory copyWith({List<String>? values}) {
    return _VipPredictionCategory(
      label: label,
      icon: icon,
      values: values ?? this.values,
    );
  }
}

class _VipHistoryLoading extends StatelessWidget {
  const _VipHistoryLoading();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.designToken.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40.0,
              height: 40.0,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
              ),
            ),
            SizedBox(height: theme.designToken.spacing.md),
            Text(
              FFLocalizations.of(context).getText('viphstlod'),
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(color: theme.onDecorative),
            ),
          ],
        ),
      ),
    );
  }
}

class _VipHistoryEmptyState extends StatelessWidget {
  const _VipHistoryEmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return _VipHistoryMessage(
      icon: Icons.history_toggle_off_rounded,
      title: FFLocalizations.of(context).getText('viphstemp'),
      description: FFLocalizations.of(context).getText('viphstemd'),
      buttonText: FFLocalizations.of(context).getText('viphstrty'),
      onPressed: onRefresh,
      embedded: true,
    );
  }
}

class _VipHistoryDayEmptyState extends StatelessWidget {
  const _VipHistoryDayEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
        border: Border.all(color: theme.alternate.applyAlpha(0.14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: theme.primary.applyAlpha(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              color: theme.primary,
              size: 23.0,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            FFLocalizations.of(context).getText('viphstndy'),
            textAlign: TextAlign.center,
            style: theme.titleSmall.override(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5.0),
          Text(
            FFLocalizations.of(context).getText('viphstndd'),
            textAlign: TextAlign.center,
            style: theme.bodySmall.override(
              color: theme.secondaryText,
              lineHeight: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _VipHistoryAccessDenied extends StatelessWidget {
  const _VipHistoryAccessDenied();

  @override
  Widget build(BuildContext context) {
    return _VipHistoryMessage(
      icon: Icons.workspace_premium_rounded,
      title: FFLocalizations.of(context).getText('viphstacc'),
      description: FFLocalizations.of(context).getText('viphstacd'),
      buttonText: FFLocalizations.of(context).getText('viphstbak'),
      buttonIcon: Icons.arrow_back_rounded,
      onPressed: () async => context.safePop(),
    );
  }
}

class _VipHistoryMessage extends StatelessWidget {
  const _VipHistoryMessage({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    this.embedded = false,
    this.buttonIcon = Icons.refresh_rounded,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final Future<void> Function() onPressed;
  final bool embedded;
  final IconData buttonIcon;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final content = Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.designToken.spacing.xl),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
        border: Border.all(color: theme.alternate.applyAlpha(0.14)),
        boxShadow: [theme.designToken.shadow.md],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.0,
            height: 64.0,
            decoration: BoxDecoration(
              color: theme.primary.applyAlpha(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.primary, size: 30.0),
          ),
          SizedBox(height: theme.designToken.spacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.titleMedium.override(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: theme.designToken.spacing.sm),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              color: theme.secondaryText,
              lineHeight: 1.4,
            ),
          ),
          SizedBox(height: theme.designToken.spacing.lg),
          FFButtonWidget(
            text: buttonText,
            icon: Icon(
              buttonIcon,
              color: theme.onPrimary,
              size: 20.0,
            ),
            onPressed: onPressed,
            options: FFButtonOptions(
              height: 44.0,
              padding: EdgeInsets.symmetric(
                horizontal: theme.designToken.spacing.lg,
              ),
              color: theme.primary,
              textStyle: theme.labelLarge.override(
                color: theme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
            ),
          ),
        ],
      ),
    );

    if (embedded) {
      return content;
    }

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(theme.designToken.spacing.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520.0),
          child: content,
        ),
      ),
    );
  }
}

const _creoleMonths = <String>[
  'janvye',
  'fevriye',
  'mas',
  'avril',
  'me',
  'jen',
  'jiyè',
  'out',
  'septanm',
  'oktòb',
  'novanm',
  'desanm',
];

const _creoleShortMonths = <String>[
  'jan',
  'fev',
  'mas',
  'avr',
  'me',
  'jen',
  'jiy',
  'out',
  'sep',
  'okt',
  'nov',
  'des',
];

const _creoleWeekdays = <String>[
  'lendi',
  'madi',
  'mèkredi',
  'jedi',
  'vandredi',
  'samdi',
  'dimanch',
];

String _formatVipMonth(BuildContext context, DateTime date) {
  final languageCode = FFLocalizations.of(context).languageCode;
  if (languageCode == 'cr') {
    return '${_creoleMonths[date.month - 1]} ${date.year}';
  }
  return dateTimeFormat('MMMM y', date, locale: languageCode);
}

String _formatVipFullDate(BuildContext context, DateTime date) {
  final languageCode = FFLocalizations.of(context).languageCode;
  if (languageCode == 'cr') {
    return '${_creoleWeekdays[date.weekday - 1]} ${date.day} '
        '${_creoleMonths[date.month - 1]} ${date.year}';
  }
  return dateTimeFormat('EEEE d MMMM y', date, locale: languageCode);
}

String _formatVipCompactDate(BuildContext context, DateTime date) {
  final languageCode = FFLocalizations.of(context).languageCode;
  if (languageCode == 'cr') {
    return '${date.day} ${_creoleShortMonths[date.month - 1]} ${date.year}';
  }
  return dateTimeFormat('d MMM y', date, locale: languageCode);
}
