import '/flutter_flow/flutter_flow_theme.dart';
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
          final theme = FlutterFlowTheme.of(context);
          final tokens = theme.designToken;
          final accent = approved ? theme.success : theme.warning;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.md,
              vertical: tokens.spacing.sm,
            ),
            child: Semantics(
              liveRegion: true,
              child: Container(
                key:
                    ValueKey('support-payment-${request.id}-${request.status}'),
                padding: EdgeInsets.all(tokens.spacing.md),
                decoration: tokens.home.panel,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      approved
                          ? Icons.check_circle_outline
                          : Icons.hourglass_top,
                      color: accent,
                      size: 24,
                    ),
                    SizedBox(width: tokens.spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            paymentText(
                                context, approved ? 'congratulations' : 'sent'),
                            style: theme.titleSmall,
                          ),
                          if (approved && request.newEndSub != null) ...[
                            SizedBox(height: tokens.spacing.xs),
                            Text(
                              '${paymentText(context, 'until')} ${paymentDateLabel(context, request.newEndSub!)}',
                              style: theme.bodyMedium
                                  .copyWith(color: tokens.home.mutedText),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}
