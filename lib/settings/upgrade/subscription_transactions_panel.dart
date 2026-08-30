import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';

import 'subscription_transaction.dart';

class SubscriptionTransactionsPanel extends StatelessWidget {
  const SubscriptionTransactionsPanel({
    super.key,
    required this.transactions,
    required this.subscriptionEnd,
    required this.onRenew,
    this.loading = false,
    this.loadFailed = false,
    this.now,
  });

  final List<SubscriptionTransaction> transactions;
  final DateTime? subscriptionEnd;
  final VoidCallback onRenew;
  final bool loading;
  final bool loadFailed;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final referenceTime = now ?? getCurrentTimestamp;
    final isActive = subscriptionEnd?.isAfter(referenceTime) ?? false;
    final latest = transactions.isEmpty ? null : transactions.first;
    final previous = transactions.skip(1).take(3).toList(growable: false);
    final hiddenCount = transactions.length > 4 ? transactions.length - 4 : 0;

    return Column(
      key: const ValueKey('subscription-transactions-panel'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SubscriptionStatusCard(
          expiration: subscriptionEnd,
          now: referenceTime,
        ),
        SizedBox(height: tokens.spacing.lg),
        _SectionTitle(
          icon: Icons.receipt_long_outlined,
          title: FFLocalizations.of(context)
              .getText('subscription_latest_transaction'),
        ),
        SizedBox(height: tokens.spacing.sm),
        if (loading)
          const _TransactionLoadingCard()
        else if (loadFailed)
          const _TransactionErrorCard()
        else if (latest == null)
          const _NoTransactionsCard()
        else
          _LatestTransactionCard(transaction: latest),
        if (!loading && !loadFailed && latest != null) ...[
          SizedBox(height: tokens.spacing.lg),
          _SectionTitle(
            icon: Icons.history_rounded,
            title: FFLocalizations.of(context)
                .getText('subscription_previous_transactions'),
          ),
          SizedBox(height: tokens.spacing.sm),
          _PreviousTransactionsCard(
            transactions: previous,
            hiddenCount: hiddenCount,
          ),
        ],
        SizedBox(height: tokens.spacing.lg),
        FFButtonWidget(
          key: const ValueKey('subscription-renew-button'),
          onPressed: onRenew,
          text: FFLocalizations.of(context).getText(
            isActive
                ? 'subscription_renew_action'
                : 'subscription_become_vip_action',
          ),
          icon: const Icon(Icons.workspace_premium_outlined, size: 22.0),
          options: FFButtonOptions(
            width: double.infinity,
            height: 52.0,
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: tokens.spacing.md,
            ),
            iconPadding: EdgeInsetsDirectional.only(
              end: tokens.spacing.sm,
            ),
            color: theme.primary,
            textStyle: theme.titleSmall.override(
              fontFamily: 'Google sans flex',
              color: theme.onPrimary,
              letterSpacing: 0.0,
            ),
            elevation: 0.0,
            borderRadius: BorderRadius.circular(tokens.radius.md),
          ),
        ),
      ],
    );
  }
}

class _SubscriptionStatusCard extends StatelessWidget {
  const _SubscriptionStatusCard({required this.expiration, required this.now});

  final DateTime? expiration;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final expirationDate = expiration;
    final isActive = expirationDate?.isAfter(now) ?? false;
    final isExpired = expirationDate != null && !isActive;
    final statusColor = isActive
        ? theme.success
        : isExpired
            ? theme.error
            : theme.secondaryText;
    final statusKey = isActive
        ? 'subscription_status_active'
        : isExpired
            ? 'subscription_status_expired'
            : 'subscription_status_inactive';

    final dateLabel = expirationDate == null
        ? FFLocalizations.of(context)
            .getText('subscription_no_active_membership')
        : '${FFLocalizations.of(context).getText(
            isActive ? 'subscription_valid_until' : 'subscription_expired_on',
          )} ${_formatDate(context, expirationDate)}';

    return Container(
      key: const ValueKey('subscription-status-card'),
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: theme.primary.withValues(alpha: 0.28)),
        boxShadow: [tokens.shadow.sm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: theme.primary,
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: theme.onPrimary,
                  size: 26.0,
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FFLocalizations.of(context)
                          .getText('subscription_plan_name'),
                      style: theme.headlineSmall.override(
                        fontFamily: 'Google sans flex',
                        letterSpacing: 0.0,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      dateLabel,
                      style: theme.bodyMedium.override(
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
          Container(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: tokens.spacing.sm,
              vertical: tokens.spacing.xs,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(tokens.radius.full),
            ),
            child: Text(
              FFLocalizations.of(context).getText(statusKey),
              style: theme.labelMedium.override(
                color: statusColor,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    return Row(
      children: [
        Icon(icon, color: theme.primary, size: 22.0),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            title,
            style: theme.titleLarge.override(
              fontFamily: 'Google sans flex',
              letterSpacing: 0.0,
            ),
          ),
        ),
      ],
    );
  }
}

class _LatestTransactionCard extends StatelessWidget {
  const _LatestTransactionCard({required this.transaction});

  final SubscriptionTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final accentColor =
        transaction.isCancellation ? theme.error : theme.primary;

    return Container(
      key: const ValueKey('subscription-latest-transaction-card'),
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        boxShadow: [tokens.shadow.sm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: tokens.spacing.sm,
            runSpacing: tokens.spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: tokens.spacing.sm,
                  vertical: tokens.spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(tokens.radius.full),
                ),
                child: Text(
                  _transactionTypeLabel(context, transaction),
                  style: theme.labelMedium.override(
                    color: accentColor,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _transactionAmount(context, transaction),
                style: theme.headlineSmall.override(
                  fontFamily: 'Google sans flex',
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
          _DetailRow(
            label:
                FFLocalizations.of(context).getText('subscription_detail_date'),
            value: transaction.createdAt == null
                ? FFLocalizations.of(context)
                    .getText('subscription_detail_unavailable')
                : _formatDate(context, transaction.createdAt!),
          ),
          _DetailRow(
            label: FFLocalizations.of(context)
                .getText('subscription_detail_payment_method'),
            value: _paymentMethodLabel(context, transaction.paymentMethod),
          ),
          _DetailRow(
            label: FFLocalizations.of(context)
                .getText('subscription_detail_receipt'),
            value: transaction.displayReceiptCode,
            valueKey: const ValueKey('subscription-receipt-code'),
          ),
          if (transaction.newEndSub != null)
            _DetailRow(
              label: FFLocalizations.of(context)
                  .getText('subscription_detail_period_end'),
              value: _formatDate(context, transaction.newEndSub!),
            ),
          if (transaction.refundedAmount != null)
            _DetailRow(
              label: FFLocalizations.of(context)
                  .getText('subscription_detail_refund'),
              value: _formatMoney(
                context,
                transaction.refundedAmount!,
                transaction.refundCurrency,
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueKey,
  });

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    return Padding(
      padding: EdgeInsetsDirectional.only(top: spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.bodyMedium.override(
                color: theme.secondaryText,
                letterSpacing: 0.0,
              ),
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Text(
              value,
              key: valueKey,
              textAlign: TextAlign.end,
              style: theme.bodyMedium.override(
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviousTransactionsCard extends StatelessWidget {
  const _PreviousTransactionsCard({
    required this.transactions,
    required this.hiddenCount,
  });

  final List<SubscriptionTransaction> transactions;
  final int hiddenCount;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;

    return Container(
      key: const ValueKey('subscription-previous-transactions-card'),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        boxShadow: [tokens.shadow.sm],
      ),
      child: transactions.isEmpty
          ? Padding(
              padding: EdgeInsets.all(tokens.spacing.md),
              child: Text(
                FFLocalizations.of(context)
                    .getText('subscription_no_previous_transactions'),
                style: theme.bodyMedium.override(
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                ),
              ),
            )
          : Column(
              children: [
                for (var index = 0; index < transactions.length; index++) ...[
                  _PreviousTransactionRow(transaction: transactions[index]),
                  if (index < transactions.length - 1)
                    Divider(
                      height: 1.0,
                      color: theme.secondaryText.withValues(alpha: 0.18),
                      indent: tokens.spacing.md,
                      endIndent: tokens.spacing.md,
                    ),
                ],
                if (hiddenCount > 0)
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      tokens.spacing.md,
                      tokens.spacing.sm,
                      tokens.spacing.md,
                      tokens.spacing.md,
                    ),
                    child: Text(
                      '+$hiddenCount ${FFLocalizations.of(context).getText('subscription_more_transactions')}',
                      textAlign: TextAlign.center,
                      style: theme.labelMedium.override(
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _PreviousTransactionRow extends StatelessWidget {
  const _PreviousTransactionRow({required this.transaction});

  final SubscriptionTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final iconColor = transaction.isCancellation ? theme.error : theme.primary;

    return Padding(
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
            alignment: Alignment.center,
            child: Icon(
              transaction.isCancellation
                  ? Icons.event_busy_outlined
                  : Icons.receipt_outlined,
              color: iconColor,
              size: 20.0,
            ),
          ),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _transactionTypeLabel(context, transaction),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodyMedium.override(
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  transaction.createdAt == null
                      ? FFLocalizations.of(context)
                          .getText('subscription_detail_unavailable')
                      : _formatDate(context, transaction.createdAt!),
                  style: theme.labelMedium.override(
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: tokens.spacing.sm),
          Flexible(
            child: Text(
              _transactionAmount(context, transaction),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.bodyMedium.override(
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionLoadingCard extends StatelessWidget {
  const _TransactionLoadingCard();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return Container(
      key: const ValueKey('subscription-transactions-loading'),
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22.0,
            height: 22.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: theme.primary,
            ),
          ),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Text(
              FFLocalizations.of(context)
                  .getText('subscription_transactions_loading'),
              style: theme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionErrorCard extends StatelessWidget {
  const _TransactionErrorCard();

  @override
  Widget build(BuildContext context) {
    return _MessageCard(
      key: const ValueKey('subscription-transactions-error'),
      icon: Icons.cloud_off_outlined,
      iconColor: FlutterFlowTheme.of(context).error,
      title: FFLocalizations.of(context)
          .getText('subscription_transactions_error_title'),
      message: FFLocalizations.of(context)
          .getText('subscription_transactions_error_message'),
    );
  }
}

class _NoTransactionsCard extends StatelessWidget {
  const _NoTransactionsCard();

  @override
  Widget build(BuildContext context) {
    return _MessageCard(
      key: const ValueKey('subscription-transactions-empty'),
      icon: Icons.receipt_long_outlined,
      iconColor: FlutterFlowTheme.of(context).secondaryText,
      title: FFLocalizations.of(context)
          .getText('subscription_no_transactions_title'),
      message: FFLocalizations.of(context)
          .getText('subscription_no_transactions_message'),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24.0),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.titleMedium.override(
                    fontFamily: 'Google sans flex',
                    letterSpacing: 0.0,
                  ),
                ),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  message,
                  style: theme.bodyMedium.override(
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
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

String _formatDate(BuildContext context, DateTime date) {
  return dateTimeFormat(
    'd MMM y',
    date,
    locale: FFLocalizations.of(context).languageCode,
  );
}

String _formatMoney(BuildContext context, double amount, String currency) {
  final languageCode = FFLocalizations.of(context).languageCode;
  final locale = languageCode == 'cr' ? 'fr' : languageCode;
  final decimals = amount == amount.truncateToDouble() ? 0 : 2;
  final formatted = NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: decimals,
  ).format(amount);
  return currency.isEmpty ? formatted : '$currency $formatted';
}

String _transactionAmount(
  BuildContext context,
  SubscriptionTransaction transaction,
) {
  if (transaction.isCancellation) {
    return FFLocalizations.of(context)
        .getText('subscription_transaction_cancelled');
  }
  final amount = transaction.amount;
  if (amount == null) {
    return FFLocalizations.of(context)
        .getText('subscription_amount_unavailable');
  }
  return _formatMoney(context, amount, transaction.currency);
}

String _transactionTypeLabel(
  BuildContext context,
  SubscriptionTransaction transaction,
) {
  final key = switch (transaction.transactionType) {
    'renewal' => 'subscription_transaction_type_renewal',
    'adjustment' => 'subscription_transaction_type_adjustment',
    'cancellation' => 'subscription_transaction_type_cancellation',
    _ => 'subscription_transaction_type_subscription',
  };
  return FFLocalizations.of(context).getText(key);
}

String _paymentMethodLabel(BuildContext context, String method) {
  final localizations = FFLocalizations.of(context);
  return switch (method) {
    'moncash' => 'MonCash',
    'natcash' => 'NatCash',
    'stripe' => 'Stripe',
    'zelle' => 'Zelle',
    'cashapp' => 'Cash App',
    'cash' => localizations.getText('subscription_payment_cash'),
    'virement' => localizations.getText('subscription_payment_transfer'),
    _ => localizations.getText('subscription_detail_unavailable'),
  };
}
