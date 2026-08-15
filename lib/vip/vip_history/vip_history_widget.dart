import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/vip/universal_v_i_p/universal_v_i_p_widget.dart';
import '/vip/v_i_pboloto/v_i_pboloto_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VipHistoryWidget extends StatefulWidget {
  const VipHistoryWidget({super.key});

  static String routeName = 'vipHistory';
  static String routePath = '/vip-history';

  @override
  State<VipHistoryWidget> createState() => _VipHistoryWidgetState();
}

class _VipHistoryWidgetState extends State<VipHistoryWidget> {
  late Stream<List<PredictionRecord>> _historyStream;
  DateTime? _selectedDate;

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
      // The StreamBuilder renders the localized error state.
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

    return Scaffold(
      backgroundColor: const Color(0xFF3E0066),
      appBar: AppBar(
        backgroundColor: const Color(0xFF650BB0),
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: theme.primaryText.withValues(alpha: 0.0),
          borderRadius: theme.designToken.radius.full,
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
            color: theme.onDecorative,
            fontSize: 22.0,
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
                borderColor: theme.primaryText.withValues(alpha: 0.0),
                borderRadius: theme.designToken.radius.full,
                buttonSize: 44.0,
                showLoadingIndicator: true,
                icon: Icon(
                  Icons.refresh_rounded,
                  color: theme.onDecorative,
                  size: 22.0,
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

            return StreamBuilder<List<PredictionRecord>>(
              stream: _historyStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _VipHistoryMessage(
                    icon: Icons.cloud_off_rounded,
                    title: FFLocalizations.of(context).getText('viphsterr'),
                    description:
                        FFLocalizations.of(context).getText('viphsterd'),
                    buttonText:
                        FFLocalizations.of(context).getText('viphstrty'),
                    buttonIcon: Icons.refresh_rounded,
                    onPressed: _reloadHistory,
                  );
                }

                if (!snapshot.hasData) {
                  return const _VipHistoryLoading();
                }

                final predictionsByDate = _groupPredictionsByDate(
                  snapshot.data!,
                );
                final dates = predictionsByDate.keys.toList()
                  ..sort((first, second) => second.compareTo(first));

                if (dates.isEmpty) {
                  return _VipHistoryEmptyState(onRefresh: _reloadHistory);
                }

                final selectedDate = dates.contains(_selectedDate)
                    ? _selectedDate!
                    : dates.first;
                final selectedIndex = dates.indexOf(selectedDate);
                final selectedPredictions = predictionsByDate[selectedDate]!;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760.0),
                    child: RefreshIndicator(
                      color: theme.primary,
                      backgroundColor: theme.secondaryBackground,
                      onRefresh: _reloadHistory,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          theme.designToken.spacing.sm,
                          theme.designToken.spacing.md,
                          theme.designToken.spacing.sm,
                          100.0,
                        ),
                        children: [
                          _VipDateSelector(
                            selectedDate: selectedDate,
                            position: selectedIndex + 1,
                            dateCount: dates.length,
                            canGoOlder: selectedIndex < dates.length - 1,
                            canGoNewer: selectedIndex > 0,
                            onOlder: () => _selectDate(
                              dates[selectedIndex + 1],
                            ),
                            onNewer: () => _selectDate(
                              dates[selectedIndex - 1],
                            ),
                          ),
                          SizedBox(height: theme.designToken.spacing.md),
                          ...selectedPredictions.map(
                            (prediction) => Padding(
                              padding: EdgeInsets.only(
                                bottom: theme.designToken.spacing.md,
                              ),
                              child: _VipPredictionDisplay(
                                key: ValueKey(prediction.reference.path),
                                prediction: prediction,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Map<DateTime, List<PredictionRecord>> _groupPredictionsByDate(
    List<PredictionRecord> predictions,
  ) {
    final grouped = <DateTime, List<PredictionRecord>>{};
    for (final prediction in predictions) {
      final date = prediction.date;
      if (date == null) continue;
      final dateOnly = DateTime(date.year, date.month, date.day);
      grouped.putIfAbsent(dateOnly, () => <PredictionRecord>[]).add(prediction);
    }
    return grouped;
  }

  void _selectDate(DateTime date) {
    logFirebaseEvent('VIP_HISTORY_DATE_CHANGED');
    safeSetState(() => _selectedDate = date);
  }
}

class _VipDateSelector extends StatelessWidget {
  const _VipDateSelector({
    required this.selectedDate,
    required this.position,
    required this.dateCount,
    required this.canGoOlder,
    required this.canGoNewer,
    required this.onOlder,
    required this.onNewer,
  });

  final DateTime selectedDate;
  final int position;
  final int dateCount;
  final bool canGoOlder;
  final bool canGoNewer;
  final VoidCallback onOlder;
  final VoidCallback onNewer;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.designToken.spacing.xs,
        vertical: theme.designToken.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
        boxShadow: [theme.designToken.shadow.sm],
      ),
      child: Row(
        children: [
          Tooltip(
            message: FFLocalizations.of(context).getText('viphstold'),
            child: FlutterFlowIconButton(
              borderColor: theme.primaryText.withValues(alpha: 0.0),
              borderRadius: theme.designToken.radius.full,
              buttonSize: 48.0,
              disabledIconColor: theme.secondaryText.withValues(alpha: 0.35),
              icon: Icon(
                Icons.chevron_left_rounded,
                color: theme.primaryText,
                size: 28.0,
              ),
              onPressed: canGoOlder ? onOlder : null,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatVipFullDate(context, selectedDate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.titleMedium.override(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: theme.designToken.spacing.xs),
                Text(
                  '$position / $dateCount',
                  style: theme.labelSmall.override(
                    color: theme.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: FFLocalizations.of(context).getText('viphstnewer'),
            child: FlutterFlowIconButton(
              borderColor: theme.primaryText.withValues(alpha: 0.0),
              borderRadius: theme.designToken.radius.full,
              buttonSize: 48.0,
              disabledIconColor: theme.secondaryText.withValues(alpha: 0.35),
              icon: Icon(
                Icons.chevron_right_rounded,
                color: theme.primaryText,
                size: 28.0,
              ),
              onPressed: canGoNewer ? onNewer : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _VipPredictionDisplay extends StatelessWidget {
  const _VipPredictionDisplay({
    super.key,
    required this.prediction,
  });

  final PredictionRecord prediction;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: theme.primaryBackground,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: theme.designToken.spacing.md,
              vertical: theme.designToken.spacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.primaryText,
                  size: 24.0,
                ),
                SizedBox(width: theme.designToken.spacing.sm),
                Expanded(
                  child: Text(
                    '${FFLocalizations.of(context).getText('vipproblb')}: '
                    '${_formatVipFullDate(context, prediction.date!)} '
                    '${prediction.periode}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodyMedium.override(
                      color: theme.alternate,
                    ),
                  ),
                ),
                if (prediction.hasPourcentage()) ...[
                  SizedBox(width: theme.designToken.spacing.sm),
                  Icon(
                    Icons.timeline_sharp,
                    color: theme.alternate,
                    size: 24.0,
                  ),
                  SizedBox(width: theme.designToken.spacing.xs),
                  Text(
                    '${prediction.pourcentage}%',
                    style: theme.bodyMedium.override(
                      color: theme.alternate,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        GridView(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 0.0,
            mainAxisSpacing: 0.0,
            childAspectRatio: 1.0,
          ),
          primary: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            UniversalVIPWidget(
              key: ValueKey('${prediction.reference.path}-favori'),
              name: prediction.favori.name,
              autre: '',
              chiffre: prediction.favori.boul,
              ref: prediction.reference,
              icon: Icon(
                Icons.star,
                color: theme.primary,
                size: 20.0,
              ),
            ),
            UniversalVIPWidget(
              key: ValueKey('${prediction.reference.path}-soutni'),
              name: prediction.soutni.name,
              chiffre: prediction.soutni.boul,
              ref: prediction.reference,
              icon: FaIcon(
                FontAwesomeIcons.peopleCarry,
                color: theme.primary,
                size: 20.0,
              ),
            ),
            VIPbolotoWidget(
              key: ValueKey('${prediction.reference.path}-boloto'),
              name: prediction.boloto.name,
              chiffre: prediction.boloto.boul,
              ref: prediction.reference,
            ),
            UniversalVIPWidget(
              key: ValueKey('${prediction.reference.path}-mariage'),
              name: prediction.mariage.name,
              chiffre: prediction.mariage.boul,
              ref: prediction.reference,
              icon: FaIcon(
                FontAwesomeIcons.link,
                color: theme.primary,
                size: 20.0,
              ),
            ),
            UniversalVIPWidget(
              key: ValueKey('${prediction.reference.path}-chif3'),
              name: prediction.chif3.name,
              chiffre: prediction.chif3.boul,
              ref: prediction.reference,
              icon: Icon(
                Icons.looks_3,
                color: theme.primary,
                size: 20.0,
              ),
            ),
            UniversalVIPWidget(
              key: ValueKey('${prediction.reference.path}-chif4'),
              name: prediction.chif4.name,
              chiffre: prediction.chif4.boul,
              ref: prediction.reference,
              icon: Icon(
                Icons.looks_4,
                color: theme.primary,
                size: 20.0,
              ),
            ),
            UniversalVIPWidget(
              key: ValueKey('${prediction.reference.path}-extra'),
              name: prediction.extra.name,
              chiffre: prediction.extra.boul,
              ref: prediction.reference,
              icon: Icon(
                Icons.auto_awesome_rounded,
                color: theme.error,
                size: 20.0,
              ),
            ),
          ],
        ),
      ],
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
                color: theme.primary,
              ),
            ),
            SizedBox(height: theme.designToken.spacing.md),
            Text(
              FFLocalizations.of(context).getText('viphstlod'),
              textAlign: TextAlign.center,
              style: theme.bodyMedium,
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
      buttonIcon: Icons.refresh_rounded,
      onPressed: onRefresh,
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
    required this.buttonIcon,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final IconData buttonIcon;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(theme.designToken.spacing.md),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 520.0),
          padding: EdgeInsets.all(theme.designToken.spacing.xl),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(theme.designToken.radius.md),
            boxShadow: [theme.designToken.shadow.md],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.0,
                height: 64.0,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
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
                style: theme.bodyMedium.override(color: theme.secondaryText),
              ),
              SizedBox(height: theme.designToken.spacing.lg),
              FilledButton.icon(
                onPressed: onPressed,
                icon: Icon(buttonIcon, color: theme.onPrimary, size: 20.0),
                label: Text(
                  buttonText,
                  style: theme.labelLarge.override(
                    color: theme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.primary,
                  minimumSize: const Size(0.0, 44.0),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(theme.designToken.radius.sm),
                  ),
                ),
              ),
            ],
          ),
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

const _creoleWeekdays = <String>[
  'lendi',
  'madi',
  'mèkredi',
  'jedi',
  'vandredi',
  'samdi',
  'dimanch',
];

String _formatVipFullDate(BuildContext context, DateTime date) {
  final languageCode = FFLocalizations.of(context).languageCode;
  if (languageCode == 'cr') {
    return '${_creoleWeekdays[date.weekday - 1]} ${date.day} '
        '${_creoleMonths[date.month - 1]} ${date.year}';
  }
  return dateTimeFormat('EEEE d MMMM y', date, locale: languageCode);
}
