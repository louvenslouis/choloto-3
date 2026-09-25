import 'dart:async';
import 'package:choloto/payments/payment_request.dart';
import 'package:choloto/support/support_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'support_chat_view_test.dart' show localizedApp;

void main() {
  setUpAll(() => initializeDateFormatting());
  for (final language in ['fr', 'en', 'cr']) {
    testWidgets('approval appears once after review in $language',
        (tester) async {
      final requests = StreamController<List<PaymentRequest>>();
      addTearDown(requests.close);
      await tester.pumpWidget(localizedApp(
          locale: Locale(language),
          brightness: Brightness.light,
          child: Scaffold(
              body: SupportChatView(
                  messages: Stream.value(const []),
                  paymentRequests: requests.stream,
                  onSend: (_, image) async {}))));
      final created = DateTime(2026, 9, 24);
      final pending = PaymentRequest('r1',
          {'user_uid': 'member', 'status': 'pending', 'created_at': created});
      final approved = PaymentRequest('r1', {
        'user_uid': 'member',
        'status': 'approved',
        'created_at': created,
        'new_end_sub': DateTime(2090, 10, 24)
      });
      requests.add([pending]);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('support-payment-r1-pending')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('support-payment-r1-approved')),
          findsNothing);
      requests.add([approved]);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('support-payment-r1-approved')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('support-payment-r1-pending')),
          findsNothing);
      expect(
          find.textContaining(language == 'fr'
              ? 'Félicitations'
              : language == 'en'
                  ? 'Congratulations'
                  : 'Felisitasyon'),
          findsOneWidget);
      expect(find.textContaining('2090'), findsOneWidget);
      requests.add([approved]);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('support-payment-r1-approved')),
          findsOneWidget);
      // A more recent request must not be congratulated for an earlier payment.
      requests.add([
        approved,
        PaymentRequest('r2', {
          'user_uid': 'member',
          'status': 'pending',
          'created_at': created.add(const Duration(days: 1))
        })
      ]);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('support-payment-r1-approved')),
          findsNothing);
      expect(find.byKey(const ValueKey('support-payment-r2-pending')),
          findsOneWidget);
      requests.add([
        PaymentRequest('r2',
            {'user_uid': 'member', 'status': 'rejected', 'created_at': created})
      ]);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('support-payment-r2-approved')),
          findsNothing);
    });
  }
}
