import 'dart:async';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/internationalization.dart';
import '/settings/upgrade/subscription_transaction.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'vip_badge.dart';

typedef _BadgeHistory = ({
  List<VipBadgeTier> tiers,
  List<SubscriptionTransaction> receipts
});

class MemberVipBadge extends StatefulWidget {
  MemberVipBadge({required this.user, this.showCollection = false})
      : super(key: ValueKey(user.reference.path));

  final UserRecord user;
  final bool showCollection;
  @override
  State<MemberVipBadge> createState() => _MemberVipBadgeState();
}

class _MemberVipBadgeState extends State<MemberVipBadge> {
  late Stream<_BadgeHistory> _stream;
  Timer? _clock;

  Stream<_BadgeHistory> _watch() {
    final tiers = FirebaseFirestore.instance
        .doc('vip_badges/config')
        .snapshots(includeMetadataChanges: true)
        .where((snapshot) =>
            !snapshot.metadata.isFromCache &&
            !snapshot.metadata.hasPendingWrites)
        .map((snapshot) => readVipBadges(snapshot.data()));
    final receipts = SubscriptionTransactionRepository()
        .watchForUser(widget.user.reference.id, confirmedOnly: true);
    return Rx.combineLatest2(
        tiers, receipts, (t, r) => (tiers: t, receipts: r));
  }

  @override
  void initState() {
    super.initState();
    _stream = _watch();
    _scheduleRefresh();
  }

  @override
  void didUpdateWidget(MemberVipBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.endSub != widget.user.endSub) _scheduleRefresh();
  }

  void _scheduleRefresh() {
    _clock?.cancel();
    final remaining = widget.user.endSub?.difference(DateTime.now());
    if (remaining == null || remaining.isNegative) return;
    const minute = Duration(minutes: 1);
    final untilExpired = remaining + const Duration(milliseconds: 1);
    _clock = Timer(untilExpired < minute ? untilExpired : minute, () {
      setState(() {});
      _scheduleRefresh();
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<_BadgeHistory>(
        stream: _stream,
        builder: (context, snapshot) {
          final user = widget.user;
          final now = DateTime.now();
          final active = hasActiveVipForBadge(
            expiry: user.endSub,
            created: user.createdTime,
            onboarded: user.onboardingCompletedAt,
            now: now,
          );
          if (snapshot.hasError) {
            if (!active) return const SizedBox.shrink();
            final l = FFLocalizations.of(context);
            final label = l.getVariableText(
                frText: 'Recharger le badge',
                enText: 'Reload badge',
                crText: 'Rechaje badj la');
            void retry() => setState(() => _stream = _watch());
            if (!widget.showCollection) {
              return IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: retry,
                  tooltip: label);
            }
            return TextButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: retry,
                label: Text(label));
          }
          final data = snapshot.data;
          if (data == null) return const SizedBox.shrink();
          final time = verifiedVipTime(
              history: data.receipts,
              expiry: user.endSub,
              memberTime: user.memberTime,
              created: user.createdTime,
              onboarded: user.onboardingCompletedAt,
              now: now);
          return VipBadgeView(
              tiers: data.tiers,
              time: time,
              active: active,
              showCollection: widget.showCollection);
        },
      );
}

class VipBadgeView extends StatefulWidget {
  const VipBadgeView(
      {super.key,
      required this.tiers,
      required this.time,
      required this.active,
      required this.showCollection});
  final List<VipBadgeTier> tiers;
  final VerifiedVipTime time;
  final bool active;
  final bool showCollection;

  @override
  State<VipBadgeView> createState() => _VipBadgeViewState();
}

class _VipBadgeViewState extends State<VipBadgeView> {
  ModalRoute<void>? _details;
  // The open sheet lives on its own route and also follows membership changes.
  final _detailUpdates = StreamController<VipBadgeView>.broadcast();
  int? get _rank =>
      vipBadgeIndex(widget.tiers, widget.time, active: widget.active);

  @override
  void didUpdateWidget(VipBadgeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _detailUpdates.add(widget);
  }

  void _closeDetails() {
    final route = _details;
    if (route == null) return;
    _details = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (route.isActive) route.navigator?.removeRoute(route);
    });
  }

  @override
  void dispose() {
    _closeDetails();
    _detailUpdates.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiers = widget.tiers;
    final rank = _rank;
    if (rank == null) {
      _closeDetails();
      return const SizedBox.shrink();
    }
    final showCollection = widget.showCollection;
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final imageSize = showCollection ? 48.0 : 24.0;
    Widget medal(int index) {
      final l = FFLocalizations.of(context);
      final name = vipBadgeName(l, tiers[index].name);
      final status = _badgeStatus(l, index, rank);
      return IconButton(
        key: ValueKey('vip-medal-${index + 1}'),
        tooltip: '$name · $status',
        iconSize: imageSize,
        padding: EdgeInsets.all(spacing.xs),
        onPressed: () async {
          ModalRoute<void>? opened;
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            showDragHandle: true,
            backgroundColor: theme.secondaryBackground,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(theme.designToken.radius.lg))),
            constraints: const BoxConstraints(maxWidth: 480),
            builder: (sheetContext) {
              if (opened == null) {
                opened = ModalRoute.of<void>(sheetContext);
                _details = opened;
                if (!mounted || _rank == null) _closeDetails();
              }
              if (!mounted) return const SizedBox.shrink();
              return StreamBuilder<VipBadgeView>(
                stream: _detailUpdates.stream,
                initialData: widget,
                builder: (_, snapshot) {
                  final view = snapshot.requireData;
                  final currentRank =
                      vipBadgeIndex(view.tiers, view.time, active: view.active);
                  if (currentRank == null) return const SizedBox.shrink();
                  return _MedalDetails(
                      tiers: view.tiers,
                      index: index,
                      rank: currentRank,
                      time: view.time,
                      retained: !view.active && index <= currentRank);
                },
              );
            },
          );
          if (identical(_details, opened)) _details = null;
        },
        icon: SizedBox.square(
          dimension: imageSize,
          child: Stack(fit: StackFit.expand, children: [
            _medalImage(index, retained: !widget.active && index <= rank),
            if (showCollection && index >= rank)
              Align(
                alignment: Alignment.bottomRight,
                child: _StatusMark(current: index == rank),
              ),
          ]),
        ),
      );
    }

    if (!showCollection) return medal(rank);
    return Padding(
        padding: EdgeInsets.only(bottom: spacing.md),
        child: LayoutBuilder(builder: (context, constraints) {
          final buttonSize = imageSize + 2 * spacing.xs;
          final fourAcross = 4 * buttonSize + 3 * spacing.sm;
          final eightAcross = 8 * buttonSize + 7 * spacing.sm;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth >= eightAcross
                      ? eightAcross
                      : fourAcross),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: List.generate(tiers.length, medal),
              ),
            ),
          );
        }));
  }
}

Widget _medalImage(int index, {required bool retained}) {
  final image = Image.asset(
    'assets/images/vip_badges/rank-${index + 1}.webp',
    fit: BoxFit.contain,
    filterQuality: FilterQuality.medium,
    excludeFromSemantics: true,
  );
  if (!retained) return image;
  // Use the same luminance weights as CSS grayscale(), preserving alpha.
  const luminance = <double>[0.2126, 0.7152, 0.0722, 0, 0];
  return ColorFiltered(
    colorFilter: const ColorFilter.matrix(
        [...luminance, ...luminance, ...luminance, 0, 0, 0, 1, 0]),
    child: image,
  );
}

String _badgeStatus(FFLocalizations l, int index, int rank) {
  if (index == rank) {
    return l.getVariableText(
        frText: 'Badge actuel', enText: 'Current badge', crText: 'Badj aktyèl');
  }
  return l.getText(index < rank ? 'ach_unlocked' : 'ach_locked');
}

class _StatusMark extends StatelessWidget {
  const _StatusMark({required this.current});
  final bool current;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: current ? theme.primary : theme.secondaryBackground,
        shape: BoxShape.circle,
        border: Border.all(color: theme.alternate),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(current ? Icons.check_rounded : Icons.lock_rounded,
            size: 12, color: current ? theme.onPrimary : theme.primaryText),
      ),
    );
  }
}

class _MedalDetails extends StatelessWidget {
  const _MedalDetails(
      {required this.tiers,
      required this.index,
      required this.rank,
      required this.time,
      required this.retained});
  final List<VipBadgeTier> tiers;
  final int index;
  final int rank;
  final VerifiedVipTime time;
  final bool retained;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final l = FFLocalizations.of(context);
    final tier = tiers[index];
    String unit(int days) => l.getVariableText(
        frText: days == 1 ? 'jour VIP' : 'jours VIP',
        enText: days == 1 ? 'VIP day' : 'VIP days',
        crText: 'jou VIP');
    final threshold = tier.days == 0
        ? l.getVariableText(
            frText: 'Dès l’activation VIP',
            enText: 'When VIP access starts',
            crText: 'Depi aksè VIP la aktive')
        : l.getVariableText(
            frText: 'À partir de ${tier.days} ${unit(tier.days)}',
            enText: 'From ${tier.days} ${unit(tier.days)}',
            crText: 'Apati ${tier.days} ${unit(tier.days)}');
    final nextTier =
        index == rank && rank + 1 < tiers.length ? tiers[rank + 1] : null;
    final target = nextTier ?? (index > rank ? tier : null);
    final prefix = time.partial ? '≥ ' : '';
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                SizedBox.square(
                    dimension: 144,
                    child: _medalImage(index, retained: retained)),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    key: const ValueKey('close-vip-medal'),
                    tooltip: l.getVariableText(
                        frText: 'Fermer', enText: 'Close', crText: 'Fèmen'),
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.sm),
            Text(vipBadgeName(l, tier.name),
                textAlign: TextAlign.center, style: theme.titleLarge),
            SizedBox(height: spacing.xs),
            Text('${_badgeStatus(l, index, rank)} · $threshold',
                textAlign: TextAlign.center, style: theme.bodyMedium),
            if (nextTier != null) ...[
              SizedBox(height: spacing.md),
              Text(
                  l.getVariableText(
                    frText:
                        'Prochain badge · ${vipBadgeName(l, nextTier.name)}',
                    enText: 'Next badge · ${vipBadgeName(l, nextTier.name)}',
                    crText: 'Pwochen badj · ${vipBadgeName(l, nextTier.name)}',
                  ),
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium),
            ],
            if (target != null) ...[
              SizedBox(height: spacing.sm),
              LinearProgressIndicator(
                  value: time.days / target.days,
                  color: theme.primary,
                  backgroundColor: theme.alternate),
              SizedBox(height: spacing.xs),
              Text('$prefix${time.days} / ${target.days} ${unit(target.days)}',
                  style: theme.labelMedium.copyWith(color: theme.primaryText)),
            ] else ...[
              SizedBox(height: spacing.sm),
              Text('$prefix${time.days} ${unit(time.days)}',
                  style: theme.labelMedium.copyWith(color: theme.primaryText)),
            ],
          ],
        ),
      ),
    );
  }
}
