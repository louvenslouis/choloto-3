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
                      return RefreshIndicator(
                        color: theme.primary,
                        backgroundColor: theme.secondaryBackground,
                        onRefresh: _reloadHistory,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            theme.designToken.spacing.md,
                            theme.designToken.spacing.md,
                            theme.designToken.spacing.md,
                            100.0,
                          ),
                          itemCount:
                              predictions.isEmpty ? 2 : predictions.length + 1,
                          separatorBuilder: (_, __) => SizedBox(
                            height: theme.designToken.spacing.md,
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

                            return _VipPredictionHistoryCard(
                              prediction: predictions[index - 1],
                              isLatest: index == 1,
                            );
                          },
                        ),
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
      padding: EdgeInsets.all(theme.designToken.spacing.md),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
        border: Border.all(color: theme.alternate.applyAlpha(0.14)),
        boxShadow: [theme.designToken.shadow.md],
      ),
      child: Row(
        children: [
          Container(
            width: 52.0,
            height: 52.0,
            decoration: BoxDecoration(
              color: theme.primary.applyAlpha(0.14),
              borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
            ),
            child: Icon(
              Icons.history_rounded,
              color: theme.primary,
              size: 26.0,
            ),
          ),
          SizedBox(width: theme.designToken.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FFLocalizations.of(context).getText('viphsthed'),
                  style: theme.titleMedium.override(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: theme.designToken.spacing.xs),
                Text(
                  FFLocalizations.of(context).getText('viphstdsc'),
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                    lineHeight: 1.35,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: theme.designToken.spacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: theme.designToken.spacing.sm,
              vertical: theme.designToken.spacing.xs,
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
                fontWeight: FontWeight.w600,
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
  });

  final PredictionRecord prediction;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final locale = FFLocalizations.of(context).languageCode;
    final categories = _categoriesFor(context, prediction);
    final selectionCount = categories.fold<int>(
      0,
      (total, category) => total + category.values.length,
    );
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
          tilePadding: EdgeInsets.symmetric(
            horizontal: theme.designToken.spacing.md,
            vertical: theme.designToken.spacing.sm,
          ),
          childrenPadding: EdgeInsets.fromLTRB(
            theme.designToken.spacing.md,
            0.0,
            theme.designToken.spacing.md,
            theme.designToken.spacing.md,
          ),
          iconColor: theme.primary,
          collapsedIconColor: theme.primary,
          backgroundColor: theme.primaryBackground,
          collapsedBackgroundColor: theme.primaryBackground,
          leading: Container(
            width: 46.0,
            height: 46.0,
            decoration: BoxDecoration(
              color: theme.primary.applyAlpha(0.12),
              borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
            ),
            child: Icon(
              Icons.insights_rounded,
              color: theme.primary,
              size: 23.0,
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  prediction.date == null
                      ? FFLocalizations.of(context).getText('viphstnod')
                      : dateTimeFormat(
                          'd MMMM y',
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
                SizedBox(width: theme.designToken.spacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.designToken.spacing.sm,
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
            padding: EdgeInsets.only(top: theme.designToken.spacing.xs),
            child: Wrap(
              spacing: theme.designToken.spacing.sm,
              runSpacing: theme.designToken.spacing.xs,
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
            Divider(
              height: theme.designToken.spacing.md,
              thickness: 1.0,
              color: const Color(0xFF3E0066),
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
              ...List.generate(categories.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: index == 0 ? 0.0 : theme.designToken.spacing.sm,
                  ),
                  child: _VipPredictionCategoryRow(
                    category: categories[index],
                  ),
                );
              }),
          ],
        ),
      ),
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
