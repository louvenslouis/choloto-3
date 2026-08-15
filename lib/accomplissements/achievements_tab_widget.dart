import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/services/engagement_service.dart';
import 'package:flutter/material.dart';

import 'achievement_progress.dart';

class AchievementsTabWidget extends StatefulWidget {
  const AchievementsTabWidget({super.key});

  @override
  State<AchievementsTabWidget> createState() => _AchievementsTabWidgetState();
}

class _AchievementsTabWidgetState extends State<AchievementsTabWidget> {
  int _streamVersion = 0;

  @override
  void initState() {
    super.initState();
    unawaited(recordDailyEngagement(userReference: currentUserReference));
  }

  @override
  Widget build(BuildContext context) {
    if (!loggedIn || currentUserReference == null) {
      return AchievementAccessState(
        icon: Icons.lock_outline_rounded,
        titleKey: 'ach_guest_title',
        descriptionKey: 'ach_guest_desc',
        actionKey: 'ach_sign_in',
        onAction: () => context.goNamed(AuthentificationWidget.routeName),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      key: ValueKey(_streamVersion),
      stream: currentUserReference!.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AchievementAccessState(
            icon: Icons.cloud_off_outlined,
            titleKey: 'ach_error_title',
            descriptionKey: 'ach_error_desc',
            actionKey: 'ach_retry',
            onAction: () => setState(() => _streamVersion++),
          );
        }
        if (!snapshot.hasData) {
          return const AchievementLoadingView();
        }
        if (!snapshot.data!.exists) {
          return const AchievementAccessState(
            icon: Icons.person_outline_rounded,
            titleKey: 'ach_profile_missing_title',
            descriptionKey: 'ach_profile_missing_desc',
          );
        }

        final user = UserRecord.fromSnapshot(snapshot.data!);
        final engagement = user.engagement;
        final now = DateTime.now();
        final snapshotData = AchievementSnapshot(
          currentStreak: engagement.currentStreak,
          longestStreak: engagement.longestStreak,
          totalActiveDays: engagement.totalActiveDays,
          recentActiveDays: engagement.recentActiveDays,
          reportedWins: user.userStats.bingoGain,
          reportedMisses: user.userStats.bingoRater,
          memberDays: membershipDays(user.createdTime, now),
          hasCompleteProfile: user.displayName.trim().isNotEmpty &&
              user.photoUrl.trim().isNotEmpty,
        );
        return AchievementDashboard(snapshot: snapshotData, now: now);
      },
    );
  }
}

class AchievementDashboard extends StatelessWidget {
  const AchievementDashboard({
    super.key,
    required this.snapshot,
    required this.now,
  });

  final AchievementSnapshot snapshot;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          key: const ValueKey('achievements-scroll-view'),
          padding: EdgeInsets.all(spacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StreakHero(snapshot: snapshot, now: now),
                  if (snapshot.totalActiveDays <= 1) ...[
                    SizedBox(height: spacing.sm),
                    const _TrackingStartedNotice(),
                  ],
                  SizedBox(height: spacing.lg),
                  const _SectionTitle(
                    titleKey: 'ach_overview_title',
                    subtitleKey: 'ach_overview_desc',
                  ),
                  SizedBox(height: spacing.md),
                  _OverviewGrid(snapshot: snapshot),
                  SizedBox(height: spacing.lg),
                  const _SectionTitle(
                    titleKey: 'ach_badges_title',
                    subtitleKey: 'ach_badges_desc',
                  ),
                  SizedBox(height: spacing.md),
                  _BadgeGrid(snapshot: snapshot),
                  SizedBox(height: spacing.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.snapshot, required this.now});

  final AchievementSnapshot snapshot;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final radius = theme.designToken.radius;
    final nextTarget = nextStreakTarget(snapshot.longestStreak);
    final allStreakBadgesUnlocked = snapshot.longestStreak >= 30;
    final remaining = allStreakBadgesUnlocked
        ? 0
        : mathMax(0, nextTarget - snapshot.currentStreak);
    final progress = allStreakBadgesUnlocked
        ? 1.0
        : (snapshot.currentStreak / nextTarget).clamp(0.0, 1.0);

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: FFLocalizations.of(context).getText('ach_streak_semantics'),
      value:
          '${snapshot.currentStreak} ${FFLocalizations.of(context).getText('ach_days_in_a_row')}',
      child: Container(
        decoration: BoxDecoration(
          color: theme.primary,
          borderRadius: BorderRadius.circular(radius.lg),
          boxShadow: [theme.designToken.shadow.md],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 680.0;
            final content = _StreakHeroContent(
              snapshot: snapshot,
              now: now,
              nextTarget: nextTarget,
              remaining: remaining,
              progress: progress,
              allStreakBadgesUnlocked: allStreakBadgesUnlocked,
            );
            final illustration = ExcludeSemantics(
              child: Image.asset(
                'assets/images/achievements/achievements_hero_3d.png',
                width: wide ? 260.0 : 180.0,
                height: wide ? 260.0 : 180.0,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.emoji_events_rounded,
                  size: wide ? 160.0 : 112.0,
                  color: theme.onPrimary,
                ),
              ),
            );

            if (wide) {
              return Padding(
                padding: EdgeInsets.all(spacing.lg),
                child: Row(
                  children: [
                    Expanded(child: content),
                    SizedBox(width: spacing.md),
                    illustration,
                  ],
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Column(
                children: [
                  illustration,
                  SizedBox(height: spacing.xs),
                  content,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StreakHeroContent extends StatelessWidget {
  const _StreakHeroContent({
    required this.snapshot,
    required this.now,
    required this.nextTarget,
    required this.remaining,
    required this.progress,
    required this.allStreakBadgesUnlocked,
  });

  final AchievementSnapshot snapshot;
  final DateTime now;
  final int nextTarget;
  final int remaining;
  final double progress;
  final bool allStreakBadgesUnlocked;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FFLocalizations.of(context).getText('ach_streak_title'),
          style: theme.titleMedium.override(
            color: theme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: spacing.xs),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: spacing.sm,
          children: [
            Text(
              '${snapshot.currentStreak}',
              key: const ValueKey('current-streak-value'),
              style: theme.displaySmall.override(
                color: theme.onPrimary,
                fontSize: 48.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: spacing.sm),
              child: Text(
                FFLocalizations.of(context).getText('ach_days_in_a_row'),
                style: theme.titleLarge.override(color: theme.onPrimary),
              ),
            ),
          ],
        ),
        Text(
          '${FFLocalizations.of(context).getText('ach_best_streak')} ${snapshot.longestStreak}',
          style: theme.bodyMedium.override(
            color: theme.onPrimary.withValues(alpha: 0.72),
          ),
        ),
        SizedBox(height: spacing.md),
        _RecentActivityRow(
          recentDays: snapshot.recentActiveDays,
          now: now,
        ),
        SizedBox(height: spacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(theme.designToken.radius.full),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: spacing.sm,
            backgroundColor: theme.onPrimary.withValues(alpha: 0.16),
            valueColor: AlwaysStoppedAnimation<Color>(theme.onPrimary),
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(
          allStreakBadgesUnlocked
              ? FFLocalizations.of(context).getText('ach_all_streak_unlocked')
              : '$remaining ${FFLocalizations.of(context).getText('ach_days_until_badge')} $nextTarget',
          style: theme.labelMedium.override(
            color: theme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RecentActivityRow extends StatelessWidget {
  const _RecentActivityRow({required this.recentDays, required this.now});

  final List<String> recentDays;
  final DateTime now;

  static const _weekdayKeys = [
    'ach_day_mon',
    'ach_day_tue',
    'ach_day_wed',
    'ach_day_thu',
    'ach_day_fri',
    'ach_day_sat',
    'ach_day_sun',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final days = List.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - index)),
    );
    final activeDays = recentDays.toSet();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final active = activeDays.contains(engagementDayKey(day));
        return Expanded(
          child: Column(
            children: [
              Text(
                FFLocalizations.of(context)
                    .getText(_weekdayKeys[day.weekday - 1]),
                style: theme.labelSmall.override(
                  color: theme.onPrimary.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: theme.designToken.spacing.xs),
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: active
                      ? theme.onPrimary
                      : theme.onPrimary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  active ? Icons.check_rounded : Icons.remove_rounded,
                  size: 18.0,
                  color: active ? theme.primary : theme.onPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TrackingStartedNotice extends StatelessWidget {
  const _TrackingStartedNotice();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: EdgeInsets.all(theme.designToken.spacing.md),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
        boxShadow: [theme.designToken.shadow.sm],
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: theme.primary),
          SizedBox(width: theme.designToken.spacing.sm),
          Expanded(
            child: Text(
              FFLocalizations.of(context).getText('ach_tracking_started'),
              style: theme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.titleKey, required this.subtitleKey});

  final String titleKey;
  final String subtitleKey;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FFLocalizations.of(context).getText(titleKey),
          style: theme.headlineSmall,
        ),
        SizedBox(height: theme.designToken.spacing.xs),
        Text(
          FFLocalizations.of(context).getText(subtitleKey),
          style: theme.bodyMedium.override(color: theme.secondaryText),
        ),
      ],
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.snapshot});

  final AchievementSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final percent = (snapshot.winRate * 100).round();
    final items = [
      _OverviewData(
        icon: Icons.how_to_vote_outlined,
        value: '${snapshot.totalDeclarations}',
        labelKey: 'ach_stat_declarations',
      ),
      _OverviewData(
        icon: Icons.emoji_events_outlined,
        value: '${snapshot.reportedWins}',
        labelKey: 'ach_stat_wins',
      ),
      _OverviewData(
        icon: Icons.insights_rounded,
        value: '$percent%',
        labelKey: 'ach_stat_rate',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 680.0 ? 3 : 1;
        final spacing = FlutterFlowTheme.of(context).designToken.spacing;
        final width =
            (constraints.maxWidth - spacing.sm * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          children: items
              .map((item) => SizedBox(
                    width: width,
                    child: _OverviewCard(data: item),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _OverviewData {
  const _OverviewData({
    required this.icon,
    required this.value,
    required this.labelKey,
  });

  final IconData icon;
  final String value;
  final String labelKey;
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.data});

  final _OverviewData data;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: EdgeInsets.all(theme.designToken.spacing.md),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
        boxShadow: [theme.designToken.shadow.sm],
      ),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
            ),
            alignment: Alignment.center,
            child: Icon(data.icon, color: theme.primary),
          ),
          SizedBox(width: theme.designToken.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.value, style: theme.headlineSmall),
                Text(
                  FFLocalizations.of(context).getText(data.labelKey),
                  style: theme.labelMedium.override(color: theme.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.snapshot});

  final AchievementSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900.0
            ? 4
            : constraints.maxWidth >= 620.0
                ? 3
                : 2;
        final spacing = theme.designToken.spacing.sm;
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: achievementDefinitions
              .map(
                (definition) => SizedBox(
                  width: cardWidth,
                  child: _AchievementBadgeCard(
                    definition: definition,
                    snapshot: snapshot,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _AchievementBadgeCard extends StatelessWidget {
  const _AchievementBadgeCard({
    required this.definition,
    required this.snapshot,
  });

  final AchievementDefinition definition;
  final AchievementSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final unlocked = definition.isUnlocked(snapshot);
    final progress = definition.progress(snapshot);
    final localizations = FFLocalizations.of(context);

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: localizations.getText(definition.titleKey),
      value: unlocked
          ? localizations.getText('ach_unlocked')
          : '${localizations.getText('ach_locked')}, $progress ${localizations.getText('ach_progress_of')} ${definition.target}',
      child: Container(
        key: ValueKey('achievement-${definition.id}'),
        padding: EdgeInsets.all(theme.designToken.spacing.sm),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(theme.designToken.radius.md),
          boxShadow: [theme.designToken.shadow.sm],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: unlocked ? 1.0 : 0.36,
                  child: ExcludeSemantics(
                    child: Image.asset(
                      definition.assetPath,
                      height: 88.0,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.military_tech_rounded,
                        size: 64.0,
                        color: theme.primary,
                      ),
                    ),
                  ),
                ),
                if (!unlocked)
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: theme.primaryBackground.withValues(alpha: 0.88),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.lock_rounded,
                      color: theme.primaryText,
                      size: 22.0,
                    ),
                  ),
              ],
            ),
            SizedBox(height: theme.designToken.spacing.sm),
            Text(
              localizations.getText(definition.titleKey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.titleSmall,
            ),
            SizedBox(height: theme.designToken.spacing.xs),
            Text(
              localizations.getText(definition.descriptionKey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.labelSmall.override(color: theme.secondaryText),
            ),
            SizedBox(height: theme.designToken.spacing.sm),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(theme.designToken.radius.full),
              child: LinearProgressIndicator(
                minHeight: theme.designToken.spacing.xs,
                value: definition.progressValue(snapshot),
                backgroundColor: theme.alternate.withValues(alpha: 0.28),
                valueColor: AlwaysStoppedAnimation<Color>(
                  unlocked ? theme.success : theme.primary,
                ),
              ),
            ),
            SizedBox(height: theme.designToken.spacing.xs),
            Text(
              unlocked
                  ? localizations.getText('ach_unlocked')
                  : '$progress / ${definition.target}',
              textAlign: TextAlign.center,
              style: theme.labelSmall.override(
                color: unlocked ? theme.success : theme.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementLoadingView extends StatelessWidget {
  const AchievementLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.designToken.spacing.lg),
        child: CircularProgressIndicator(color: theme.primary),
      ),
    );
  }
}

class AchievementAccessState extends StatelessWidget {
  const AchievementAccessState({
    super.key,
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    this.actionKey,
    this.onAction,
  });

  final IconData icon;
  final String titleKey;
  final String descriptionKey;
  final String? actionKey;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.designToken.spacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520.0),
          child: Container(
            padding: EdgeInsets.all(theme.designToken.spacing.lg),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(theme.designToken.radius.lg),
              boxShadow: [theme.designToken.shadow.sm],
            ),
            child: Column(
              children: [
                Icon(icon, color: theme.primary, size: 48.0),
                SizedBox(height: theme.designToken.spacing.md),
                Text(
                  FFLocalizations.of(context).getText(titleKey),
                  textAlign: TextAlign.center,
                  style: theme.headlineSmall,
                ),
                SizedBox(height: theme.designToken.spacing.sm),
                Text(
                  FFLocalizations.of(context).getText(descriptionKey),
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium.override(color: theme.secondaryText),
                ),
                if (actionKey != null && onAction != null) ...[
                  SizedBox(height: theme.designToken.spacing.lg),
                  FFButtonWidget(
                    onPressed: onAction,
                    text: FFLocalizations.of(context).getText(actionKey!),
                    options: FFButtonOptions(
                      height: 48.0,
                      color: theme.primary,
                      textStyle:
                          theme.titleSmall.override(color: theme.onPrimary),
                      borderRadius: BorderRadius.circular(
                        theme.designToken.radius.sm,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

int mathMax(int a, int b) => a > b ? a : b;
