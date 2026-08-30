import 'package:cloud_firestore/cloud_firestore.dart';

/// Read-only projection of a payment transaction created by the dashboard.
///
/// The app deliberately keeps payment methods and transaction types as strings
/// so records created by newer dashboard versions remain readable.
class SubscriptionTransaction {
  const SubscriptionTransaction({
    required this.id,
    required this.transactionType,
    required this.receiptCode,
    required this.paymentMethod,
    required this.currency,
    required this.amount,
    required this.refundedAmount,
    required this.refundCurrency,
    required this.previousEndSub,
    required this.newEndSub,
    required this.createdAt,
    required this.paymentCancelled,
  });

  factory SubscriptionTransaction.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) =>
      SubscriptionTransaction.fromMap(id: document.id, data: document.data());

  factory SubscriptionTransaction.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return SubscriptionTransaction(
      id: id,
      transactionType:
          (data['transaction_type'] as String?)?.trim().toLowerCase() ??
              'subscription',
      receiptCode: (data['receipt_code'] as String?)?.trim() ?? '',
      paymentMethod:
          (data['payment_method'] as String?)?.trim().toLowerCase() ?? '',
      currency: (data['currency'] as String?)?.trim().toUpperCase() ?? '',
      amount: (data['amount'] as num?)?.toDouble(),
      refundedAmount: (data['refunded_amount'] as num?)?.toDouble(),
      refundCurrency:
          (data['refund_currency'] as String?)?.trim().toUpperCase() ?? '',
      previousEndSub: _readDate(data['previous_end_sub']),
      newEndSub: _readDate(data['new_end_sub']),
      createdAt: _readDate(data['created_at']),
      paymentCancelled: data['payment_cancelled'] == true,
    );
  }

  final String id;
  final String transactionType;
  final String receiptCode;
  final String paymentMethod;
  final String currency;
  final double? amount;
  final double? refundedAmount;
  final String refundCurrency;
  final DateTime? previousEndSub;
  final DateTime? newEndSub;
  final DateTime? createdAt;
  final bool paymentCancelled;

  bool get isCancellation =>
      transactionType == 'cancellation' || paymentCancelled;

  String get displayReceiptCode =>
      receiptCode.isNotEmpty ? receiptCode : 'CH-$id';

  static DateTime? _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return value is DateTime ? value : null;
  }
}

class SubscriptionTransactionRepository {
  SubscriptionTransactionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Watches every transaction owned by [userUid]. Sorting is performed on the
  /// client so this owner-scoped query does not require a composite index.
  Stream<List<SubscriptionTransaction>> watchForUser(String userUid) {
    if (userUid.isEmpty) {
      return Stream.value(const <SubscriptionTransaction>[]);
    }

    return _firestore
        .collection('payment_transactions')
        .where('user_uid', isEqualTo: userUid)
        .snapshots()
        .map((snapshot) {
      final transactions = snapshot.docs
          .map(SubscriptionTransaction.fromDocument)
          .toList(growable: false);
      return sortSubscriptionTransactionsNewestFirst(transactions);
    });
  }
}

List<SubscriptionTransaction> sortSubscriptionTransactionsNewestFirst(
  Iterable<SubscriptionTransaction> transactions,
) {
  return [...transactions]..sort((first, second) {
      final firstDate = first.createdAt;
      final secondDate = second.createdAt;
      if (firstDate == null && secondDate == null) {
        return second.id.compareTo(first.id);
      }
      if (firstDate == null) return 1;
      if (secondDate == null) return -1;
      final dateOrder = secondDate.compareTo(firstDate);
      return dateOrder != 0 ? dateOrder : second.id.compareTo(first.id);
    });
}

DateTime? latestRecordedSubscriptionEnd(
  Iterable<SubscriptionTransaction> transactions,
) {
  for (final transaction in transactions) {
    // The repository presents records newest first. A cancellation therefore
    // terminates the fallback scan: an older renewal must not resurrect VIP
    // access while the profile document catches up with the cancellation.
    if (transaction.isCancellation) return null;
    if (transaction.newEndSub != null) {
      return transaction.newEndSub;
    }
  }
  return null;
}

bool latestSubscriptionTransactionIsCancellation(
  Iterable<SubscriptionTransaction> transactions,
) {
  final iterator = transactions.iterator;
  return iterator.moveNext() && iterator.current.isCancellation;
}

/// Uses the profile as the source of truth, while allowing a freshly recorded
/// payment to bridge a short-lived auth-stream lag after a renewal.
DateTime? effectiveSubscriptionEnd({
  required DateTime? profileEnd,
  required DateTime? latestRecordedEnd,
  bool latestTransactionIsCancellation = false,
}) {
  if (latestTransactionIsCancellation) return null;
  if (profileEnd == null) return latestRecordedEnd;
  if (latestRecordedEnd == null) return profileEnd;
  return latestRecordedEnd.isAfter(profileEnd) ? latestRecordedEnd : profileEnd;
}

bool hasActiveVipSubscription({
  required DateTime? expiration,
  required DateTime now,
}) =>
    expiration?.isAfter(now) ?? false;
