import 'package:flutter_test/flutter_test.dart';
import 'package:choloto/support/support_bot.dart';

void main() {
  test('payment amounts are exact and incomplete active profiles are rejected',
      () {
    expect(SupportBotPayment.parseAmount('2500,50'), 250050);
    expect(SupportBotPayment.parseAmount('60'), 6000);
    expect(SupportBotPayment.parseAmount('-1'), isNull);
    expect(SupportBotPayment.parseAmount('1.234'), isNull);
    expect(
        () => const SupportBotPayment(
                id: 'moncash', name: 'MonCash', currency: 'HTG', enabled: true)
            .validate(),
        throwsFormatException);
  });
  test('legacy trees load without payment configuration', () {
    final legacy = {
      'enabled': true,
      'greeting': 'Hello',
      'revision': 1,
      'nodes': [
        {'id': 'a', 'parent': '', 'label': 'A', 'answer': 'B'}
      ]
    };
    final config = SupportBotConfig.fromJson(legacy);
    expect(config.paymentMethods, isEmpty);
    expect(config.nodes.single.paymentMethodId, isEmpty);
  });
  test('payment references survive storage and dangling links are rejected',
      () {
    final config = SupportBotConfig.fromJson(SupportBotConfig.initial.toJson());
    expect(config.node('renew_mon')!.paymentMethodId, 'moncash');
    expect(config.payment('moncash')!.enabled, false);
    expect(
        () => SupportBotConfig(
                enabled: true, greeting: 'Hello', nodes: config.nodes)
            .validate(),
        throwsFormatException);
  });

  test('initial tree is valid and survives storage roundtrip', () {
    SupportBotConfig.initial.validate();
    final config = SupportBotConfig.fromJson(SupportBotConfig.initial.toJson());
    expect(config.children('').length, 5);
    expect(config.node('paid')!.requiresAuth, isTrue);
    expect(config.node('paid')!.requestImage, isTrue);
    expect(config.node('renew')!.requiresAuth, isTrue);
    expect(config.children('renew').map((n) => n.label),
        ['MonCash', 'NatCash', 'Zelle']);
  });
  test('rejects orphan, duplicate and cyclic branches', () {
    for (final nodes in [
      [
        const SupportBotNode(
            id: 'a', parent: 'missing', label: 'A', answer: 'B')
      ],
      [const SupportBotNode(id: 'a', parent: 'a', label: 'A', answer: 'B')],
      [
        const SupportBotNode(id: 'a', parent: '', label: 'A', answer: 'B'),
        const SupportBotNode(id: 'a', parent: '', label: 'A', answer: 'B')
      ],
    ]) {
      expect(
          () => SupportBotConfig(enabled: true, greeting: 'Hello', nodes: nodes)
              .validate(),
          throwsFormatException);
    }
  });
  test('rejects empty response and excessive depth', () {
    expect(
        () => SupportBotConfig(enabled: true, greeting: 'Hello', nodes: [
              const SupportBotNode(id: 'a', parent: '', label: 'A', answer: '')
            ]).validate(),
        throwsFormatException);
    expect(
        () => SupportBotConfig(
            enabled: true,
            greeting: 'Hello',
            nodes: List.generate(
                7,
                (i) => SupportBotNode(
                    id: 'n$i',
                    parent: i == 0 ? '' : 'n${i - 1}',
                    label: 'A',
                    answer: 'B'))).validate(),
        throwsFormatException);
  });
}
