import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/accomplissements/member_vip_badge.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/autres/bingo/bingo_card_v_i_p/bingo_card_v_i_p_widget.dart';
import '/backend/backend.dart';
import '/components/don_widget.dart';
import '/components/home_page_scaffold.dart';
import '/components/vip_motion.dart';
import '/components/vip_page_header.dart';
import '/components/vip_prediction_panel.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart' show ProfilWidget, VipHistoryWidget;
import '/settings/devenir_v_i_p/devenir_v_i_p_widget.dart';
import '/settings/upgrade/subscription_transaction.dart';
import 'vip_model.dart';
export 'vip_model.dart';

class VipWidget extends StatefulWidget {
  const VipWidget({super.key});

  static String routeName = 'VIP';
  static String routePath = '/vip';

  @override
  State<VipWidget> createState() => _VipWidgetState();
}

class _VipWidgetState extends State<VipWidget> {
  late VipModel _model;

  final SubscriptionTransactionRepository _transactionsRepository =
      SubscriptionTransactionRepository();

  StreamSubscription<List<SubscriptionTransaction>>?
      _transactionMembershipSubscription;
  String? _transactionsUserUid;
  DateTime? _latestRecordedSubscriptionEnd;
  bool _latestTransactionIsCancellation = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VipModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'VIP'});
  }

  @override
  void dispose() {
    _transactionMembershipSubscription?.cancel();
    _model.dispose();

    super.dispose();
  }

  UserRecord? get _ownProfile {
    final user = currentUserDocument;
    return loggedIn && user != null && user.reference.id == currentUserUid
        ? user
        : null;
  }

  void _ensureTransactionMembershipStream() {
    final shouldWatch = shouldWatchSubscriptionTransactions(
      loggedIn: loggedIn,
      userUid: currentUserUid,
      profileEnd: _ownProfile?.endSub,
      now: getCurrentTimestamp,
    );
    if (!shouldWatch) {
      if (_transactionMembershipSubscription != null) {
        unawaited(_transactionMembershipSubscription?.cancel());
        _transactionMembershipSubscription = null;
        _transactionsUserUid = null;
        _latestRecordedSubscriptionEnd = null;
        _latestTransactionIsCancellation = false;
      }
      return;
    }
    if (_transactionsUserUid == currentUserUid) {
      return;
    }

    _transactionsUserUid = currentUserUid;
    _latestRecordedSubscriptionEnd = null;
    _latestTransactionIsCancellation = false;
    _transactionMembershipSubscription?.cancel();
    _transactionMembershipSubscription =
        _transactionsRepository.watchForUser(currentUserUid).listen(
      (transactions) {
        final latestEnd = latestRecordedSubscriptionEnd(transactions);
        final latestIsCancellation =
            latestSubscriptionTransactionIsCancellation(transactions);
        if (!mounted || latestEnd == _latestRecordedSubscriptionEnd) {
          if (mounted &&
              latestIsCancellation != _latestTransactionIsCancellation) {
            safeSetState(
              () => _latestTransactionIsCancellation = latestIsCancellation,
            );
          }
          return;
        }
        safeSetState(() {
          _latestRecordedSubscriptionEnd = latestEnd;
          _latestTransactionIsCancellation = latestIsCancellation;
        });
      },
      onError: (_) {
        // The profile stream remains the fallback when transaction history is
        // unavailable (for example before the owner-read rules are deployed).
      },
    );
  }

  Future<void> _showTip() async {
    logFirebaseEvent('VIP_FloatingActionButton_qjsc5kip_ON_TAP');
    logFirebaseEvent('FloatingActionButton_bottom_sheet');
    await showModalBottomSheet<void>(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => SingleChildScrollView(
        padding: MediaQuery.viewInsetsOf(context),
        child: const DonWidget(),
      ),
    );
  }

  Widget _membershipContent(BuildContext context) {
    // The profile and its transaction fallback may arrive in either order.
    _ensureTransactionMembershipStream();
    if (loggedIn && _ownProfile == null) {
      return const _VipStatus();
    }
    final end = effectiveSubscriptionEnd(
      profileEnd: _ownProfile?.endSub,
      latestRecordedEnd: _latestRecordedSubscriptionEnd,
      latestTransactionIsCancellation: _latestTransactionIsCancellation,
    );
    if (!loggedIn ||
        !hasActiveVipSubscription(expiration: end, now: getCurrentTimestamp)) {
      return wrapWithModel(
        model: _model.devenirVIPModel,
        updateCallback: () => safeSetState(() {}),
        child: const DevenirVIPWidget(),
      );
    }
    return _LatestPrediction(key: ValueKey(currentUserUid));
  }

  @override
  Widget build(BuildContext context) {
    final bingo = context.watch<FFAppState>().bingo;
    return AuthUserStreamWidget(builder: (context) {
      final profile = _ownProfile;
      final signedIn = loggedIn;
      final profileName = profile?.displayName.trim() ?? '';
      final profilePhoto = profile?.photoUrl.trim() ?? '';
      final name = !signedIn
          ? null
          : profileName.isNotEmpty
              ? profileName
              : currentUser?.displayName?.trim() ?? '';
      final photo = !signedIn
          ? ''
          : profilePhoto.isNotEmpty
              ? profilePhoto
              : currentUser?.photoUrl?.trim() ?? '';
      return VipPageView(
        memberName: name,
        memberMedal: profile == null
            ? null
            : MemberVipBadge(user: profile, expandedMedal: true),
        avatar: VipHeaderAvatar(name: name ?? '', photoUrl: photo),
        onProfile: () {
          logFirebaseEvent('VIP_PAGE_Card_elizvnyh_ON_TAP');
          logFirebaseEvent('Card_navigate_to');
          context.pushNamed(ProfilWidget.routeName);
        },
        onHistory: () {
          logFirebaseEvent('VIP_HISTORY_FAB_ON_TAP');
          context.pushNamed(VipHistoryWidget.routeName);
        },
        onTip: _showTip,
        onBack: ModalRoute.of(context)?.canPop == true
            ? () => context.safePop()
            : null,
        bingo: bingo.hasDate() &&
                bingo.hasExpiration() &&
                bingo.expiration! >= getCurrentTimestamp
            ? wrapWithModel(
                model: _model.bingoCardVIPModel,
                updateCallback: () => safeSetState(() {}),
                child: const BingoCardVIPWidget(),
              )
            : null,
        content: _membershipContent(context),
      );
    });
  }
}

class VipPageView extends StatelessWidget {
  const VipPageView({
    super.key,
    required this.content,
    required this.avatar,
    required this.onProfile,
    required this.onHistory,
    required this.onTip,
    this.onBack,
    this.memberName,
    this.memberMedal,
    this.bingo,
  });

  final Widget content;
  final Widget avatar;
  final String? memberName;
  final Widget? memberMedal;
  final VoidCallback onProfile;
  final VoidCallback onHistory;
  final VoidCallback onTip;
  final VoidCallback? onBack;
  final Widget? bingo;

  @override
  Widget build(BuildContext context) {
    final tokens = FlutterFlowTheme.of(context).designToken;
    final spacing = tokens.spacing;
    final wide = MediaQuery.sizeOf(context).width >= kBreakpointMedium;
    final gutter = wide ? spacing.lg : spacing.md;
    return Scaffold(
      backgroundColor: tokens.background.home,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: tokens.background.homeGradient),
        child: SafeArea(
          child: SizedBox.expand(
            child: SingleChildScrollView(
              key: const PageStorageKey('vip-scroll'),
              padding: EdgeInsets.fromLTRB(gutter, gutter, gutter, spacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: HomePageScaffold.maxContentWidth),
                  child: LayoutBuilder(builder: (context, bounds) {
                    final scale =
                        MediaQuery.textScalerOf(context).scale(16) / 16;
                    final split =
                        bounds.maxWidth >= 744 * scale.clamp(1.0, 2.0);
                    final passWidth = split
                        ? (bounds.maxWidth * .30).clamp(264.0, 376.0).toDouble()
                        : bounds.maxWidth;
                    final gap = split || wide ? spacing.xl : spacing.lg;
                    return Flex(
                      direction: split ? Axis.horizontal : Axis.vertical,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: passWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                VipPageHeader(
                                  avatar: avatar,
                                  memberName: memberName,
                                  memberMedal: memberMedal,
                                  onProfile: onProfile,
                                  onHistory: onHistory,
                                  onTip: onTip,
                                  onBack: onBack,
                                ).vipEntrance(),
                                if (bingo != null) ...[
                                  SizedBox(height: spacing.md),
                                  bingo!,
                                ],
                              ],
                            )),
                        SizedBox(
                            width: split ? gap : 0, height: split ? 0 : gap),
                        SizedBox(
                            width: split
                                ? bounds.maxWidth - passWidth - gap
                                : bounds.maxWidth,
                            child: content),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LatestPrediction extends StatefulWidget {
  const _LatestPrediction({super.key});

  @override
  State<_LatestPrediction> createState() => _LatestPredictionState();
}

class _LatestPredictionState extends State<_LatestPrediction> {
  late Stream<PredictionRecord?> _stream = _watchLatest();

  // Keep the released date ordering and limit. StreamBuilder also needs the
  // original error event to offer a retry when this subscription fails.
  Stream<PredictionRecord?> _watchLatest() => PredictionRecord.collection
      .orderBy('date', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) => snapshot.docs.isEmpty
          ? null
          : PredictionRecord.fromSnapshot(snapshot.docs.first));

  @override
  Widget build(BuildContext context) {
    final strings = FFLocalizations.of(context);
    return StreamBuilder<PredictionRecord?>(
      key: ObjectKey(_stream),
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _VipStatus(
            message: strings.getText('viphsterd'),
            onRetry: () => setState(() => _stream = _watchLatest()),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _VipStatus();
        }
        final prediction = snapshot.data;
        if (prediction == null) {
          return _VipStatus(
              message: strings.getVariableText(
            frText: 'Aucune prédiction disponible.',
            enText: 'No predictions available.',
            crText: 'Pa gen prediksyon disponib.',
          ));
        }
        return VipPredictionPanel(prediction: prediction);
      },
    );
  }
}

/// Profile loading, prediction loading, empty and recoverable errors share a footprint.
class _VipStatus extends StatelessWidget {
  const _VipStatus({this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);
    return Container(
      decoration: tokens.home.panel,
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (message == null)
          CircularProgressIndicator(
            color: tokens.home.amethystGlow,
            semanticsLabel: strings.getVariableText(
              frText: 'Chargement',
              enText: 'Loading',
              crText: 'Ap chaje',
            ),
          )
        else ...[
          Icon(
              onRetry == null
                  ? Icons.calendar_today_outlined
                  : Icons.cloud_off_rounded,
              color: tokens.home.mutedText),
          SizedBox(height: tokens.spacing.sm),
          Text(message!,
              style: tokens.vip.typography.supporting
                  .copyWith(color: tokens.home.mutedText),
              textAlign: TextAlign.center),
          if (onRetry != null)
            TextButton(
              key: const ValueKey('vip-prediction-retry'),
              onPressed: onRetry,
              style: TextButton.styleFrom(
                  textStyle: tokens.vip.typography.action,
                  foregroundColor: tokens.home.amethystGlow,
                  minimumSize: const Size.square(kMinInteractiveDimension)),
              child: Text(strings.getText('viphstrty')),
            ),
        ],
      ]),
    );
  }
}
