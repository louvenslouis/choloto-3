import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/settings/upgrade/subscription_transaction.dart';
import 'package:choloto/settings/upgrade/subscription_transactions_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const _locales = [Locale('fr'), Locale('en'), Locale('cr')];

Widget _app({
  required Locale locale,
  required ThemeMode themeMode,
  required List<SubscriptionTransaction> transactions,
  DateTime? subscriptionEnd,
  bool loading = false,
  bool loadFailed = false,
  VoidCallback? onRenew,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: _locales,
    localizationsDelegates: const [
      FFLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      FallbackMaterialLocalizationDelegate(),
      FallbackCupertinoLocalizationDelegate(),
    ],
    theme: ThemeData(brightness: Brightness.light),
    darkTheme: ThemeData(brightness: Brightness.dark),
    themeMode: themeMode,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760.0),
            child: SubscriptionTransactionsPanel(
              transactions: transactions,
              subscriptionEnd: subscriptionEnd,
              loading: loading,
              loadFailed: loadFailed,
              now: DateTime.utc(2026, 8, 30, 12),
              onRenew: onRenew ?? () {},
            ),
          ),
        ),
      ),
    ),
  );
}

List<SubscriptionTransaction> _transactions() => [
      SubscriptionTransaction.fromMap(
        id: 'latest',
        data: {
          'transaction_type': 'renewal',
          'receipt_code': 'CH-LATEST',
          'payment_method': 'moncash',
          'amount': 40,
          'currency': 'USD',
          'created_at': DateTime.utc(2026, 8, 29),
          'previous_end_sub': DateTime.utc(2026, 8, 31),
          'new_end_sub': DateTime.utc(2026, 9, 30),
        },
      ),
      SubscriptionTransaction.fromMap(
        id: 'previous-1',
        data: {
          'transaction_type': 'subscription',
          'receipt_code': 'CH-PREVIOUS-1',
          'payment_method': 'cash',
          'amount': 2000,
          'currency': 'GDS',
          'created_at': DateTime.utc(2026, 7, 29),
          'new_end_sub': DateTime.utc(2026, 8, 31),
        },
      ),
      SubscriptionTransaction.fromMap(
        id: 'previous-2',
        data: {
          'transaction_type': 'adjustment',
          'receipt_code': 'CH-PREVIOUS-2',
          'payment_method': 'virement',
          'created_at': DateTime.utc(2026, 7, 15),
          'new_end_sub': DateTime.utc(2026, 8, 31),
        },
      ),
      SubscriptionTransaction.fromMap(
        id: 'previous-3',
        data: {
          'transaction_type': 'cancellation',
          'receipt_code': 'CH-PREVIOUS-3',
          'payment_cancelled': true,
          'created_at': DateTime.utc(2026, 6, 29),
          'refunded_amount': 40,
          'refund_currency': 'USD',
        },
      ),
      SubscriptionTransaction.fromMap(
        id: 'previous-4',
        data: {
          'transaction_type': 'renewal',
          'receipt_code': 'CH-PREVIOUS-4',
          'payment_method': 'stripe',
          'amount': 40,
          'currency': 'USD',
          'created_at': DateTime.utc(2026, 5, 29),
          'new_end_sub': DateTime.utc(2026, 6, 30),
        },
      ),
    ];

void main() {
  test('transaction projection tolerates missing and future fields', () {
    final transaction = SubscriptionTransaction.fromMap(
      id: 'future-record',
      data: {
        'payment_method': 'future-wallet',
        'amount': 19,
        'created_at': DateTime.utc(2026, 8, 30),
        'future_dashboard_field': true,
      },
    );

    expect(transaction.transactionType, 'subscription');
    expect(transaction.paymentMethod, 'future-wallet');
    expect(transaction.amount, 19);
    expect(transaction.displayReceiptCode, 'CH-future-record');
    expect(transaction.isCancellation, isFalse);
  });

  test('transaction history selects the newest dated record first', () {
    final undated = SubscriptionTransaction.fromMap(
      id: 'undated',
      data: const {},
    );
    final older = SubscriptionTransaction.fromMap(
      id: 'older',
      data: {'created_at': DateTime.utc(2026, 7, 1)},
    );
    final newest = SubscriptionTransaction.fromMap(
      id: 'newest',
      data: {'created_at': DateTime.utc(2026, 8, 1)},
    );

    final sorted = sortSubscriptionTransactionsNewestFirst([
      undated,
      older,
      newest,
    ]);

    expect(sorted.map((transaction) => transaction.id), [
      'newest',
      'older',
      'undated',
    ]);
  });

  test('a just-recorded renewal bridges a stale profile expiration', () {
    final now = DateTime.utc(2026, 8, 30, 12);
    expect(
      hasActiveVipSubscription(
        expiration: effectiveSubscriptionEnd(
          profileEnd: DateTime.utc(2026, 8, 1),
          latestRecordedEnd: DateTime.utc(2026, 9, 30),
        ),
        now: now,
      ),
      isTrue,
    );
    expect(
      effectiveSubscriptionEnd(
        profileEnd: DateTime.utc(2026, 9, 30),
        latestRecordedEnd: DateTime.utc(2026, 8, 1),
      ),
      DateTime.utc(2026, 9, 30),
    );
  });

  test('a cancellation is not reused as the active membership fallback', () {
    final cancellation = SubscriptionTransaction.fromMap(
      id: 'cancellation',
      data: {
        'transaction_type': 'cancellation',
        'payment_cancelled': true,
        'new_end_sub': DateTime.utc(2026, 12, 30),
      },
    );
    final olderRenewal = SubscriptionTransaction.fromMap(
      id: 'older-renewal',
      data: {
        'transaction_type': 'renewal',
        'created_at': DateTime.utc(2026, 8, 1),
        'new_end_sub': DateTime.utc(2026, 12, 31),
      },
    );

    expect(
      latestRecordedSubscriptionEnd([cancellation, olderRenewal]),
      isNull,
    );
    expect(
      latestSubscriptionTransactionIsCancellation([cancellation, olderRenewal]),
      isTrue,
    );
    expect(
      effectiveSubscriptionEnd(
        profileEnd: DateTime.utc(2026, 12, 31),
        latestRecordedEnd: null,
        latestTransactionIsCancellation: true,
      ),
      isNull,
    );
  });

  for (final locale in _locales) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
        'transaction panel fits a small ${themeMode.name} screen in ${locale.languageCode}',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            _app(
              locale: locale,
              themeMode: themeMode,
              transactions: _transactions(),
              subscriptionEnd: DateTime.utc(2026, 9, 30),
            ),
          );
          await tester.pumpAndSettle();

          final localizations = FFLocalizations(locale);
          expect(
            find.text(localizations.getText('subscription_status_active')),
            findsOneWidget,
          );
          expect(
            find.text(
              localizations.getText('subscription_latest_transaction'),
            ),
            findsOneWidget,
          );
          expect(find.text('CH-LATEST'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('subscription-renew-button')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('shows a three-item preview and the hidden transaction count',
      (tester) async {
    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        transactions: _transactions(),
        subscriptionEnd: DateTime.utc(2026, 9, 30),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CH-LATEST'), findsOneWidget);
    expect(find.text('+1 autres transactions'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('subscription-previous-transactions-card')),
      findsOneWidget,
    );
  });

  testWidgets('renders empty and failed history states without raw errors',
      (tester) async {
    await tester.pumpWidget(
      _app(
        locale: const Locale('cr'),
        themeMode: ThemeMode.light,
        transactions: const [],
        loadFailed: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('subscription-transactions-error')),
      findsOneWidget,
    );
    expect(find.textContaining('permission-denied'), findsNothing);

    await tester.pumpWidget(
      _app(
        locale: const Locale('cr'),
        themeMode: ThemeMode.light,
        transactions: const [],
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('subscription-transactions-empty')),
      findsOneWidget,
    );
  });

  testWidgets('remains centered and actionable on a web viewport',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var renewed = false;
    await tester.pumpWidget(
      _app(
        locale: const Locale('en'),
        themeMode: ThemeMode.dark,
        transactions: _transactions(),
        subscriptionEnd: DateTime.utc(2026, 9, 30),
        onRenew: () => renewed = true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('subscription-renew-button')),
    );
    await tester.tap(
      find.byKey(const ValueKey('subscription-renew-button')),
    );
    expect(renewed, isTrue);
    expect(tester.takeException(), isNull);
  });
}
