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
              color: theme.primaryText,
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
              color: theme.primaryText,
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
                    color: theme.primaryText.applyAlpha(0.82),
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
                      _expandLatestPrediction(predictions);

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final horizontalPadding = constraints.maxWidth < 480
                              ? 12.0
                              : theme.designToken.spacing.md;

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
                              itemCount: predictions.isEmpty
                                  ? 2
                                  : predictions.length + 1,
                              separatorBuilder: (_, __) => const SizedBox(
                                height: 10.0,
                              ),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _VipHistoryHeading(
                                    publicationCount: predictions.length,
                                  );
                                }

                                if (predictions.isEmpty) {
                                  return _VipHistoryEmptyState(
                                    onRefresh: _reloadHistory,
                                  );
                                }

                                final prediction = predictions[index - 1];
                                final predictionId = prediction.reference.path;
                                final isExpanded = _expandedPredictionIds
                                    .contains(predictionId);

                                return RepaintBoundary(
                                  key: ValueKey(predictionId),
                                  child: _VipPredictionHistoryCard(
                                    prediction: prediction,
                                    isLatest: index == 1,
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
    final locale = FFLocalizations.of(context).languageCode;
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
                      : dateTimeFormat(
                          'd MMM y',
                          prediction.date,
                          locale: locale,
                        ),
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
                      color: theme.primaryBackground,
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
              style: theme.bodyMedium.override(color: theme.primaryText),
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
              color: theme.primaryBackground,
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
                color: theme.primaryBackground,
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
