import 'package:flutter/material.dart';
import '/payments/payment_request.dart';
import '/payments/payment_text.dart';
import '/payments/payment_widgets.dart' show paymentDateLabel;

/// Derived from the persisted review status: no client-side approval or duplicate
/// chat writes when Firestore replays a snapshot or the chat is reopened.
class SupportPaymentNotice extends StatelessWidget {
  const SupportPaymentNotice({super.key, required this.requests});
  final Stream<List<PaymentRequest>> requests;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<PaymentRequest>>(
        stream: requests,
        builder: (context, snapshot) {
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }
          final sorted = List<PaymentRequest>.of(snapshot.data!)
            ..sort((a, b) => (b.createdAt ?? DateTime(1970))
                .compareTo(a.createdAt ?? DateTime(1970)));
          final request = sorted.first;
          if (request.status != 'approved' && request.status != 'pending') {
            return const SizedBox.shrink();
          }
          final approved = request.status == 'approved';
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Semantics(
                liveRegion: true,
                child: Card(
                  key: ValueKey(
                      'support-payment-${request.id}-${request.status}'),
                  child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                                approved
                                    ? Icons.check_circle_outline
                                    : Icons.hourglass_top,
                                size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(paymentText(context,
                                      approved ? 'congratulations' : 'sent')),
                                  if (approved && request.newEndSub != null)
                                    Text(
                                        '${paymentText(context, 'until')} ${paymentDateLabel(context, request.newEndSub!)}'),
                                ])),
                          ])),
                )),
          );
        },
      );
}
