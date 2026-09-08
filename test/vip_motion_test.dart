import 'package:choloto/components/vip_motion.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {bool reduced = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(body: Center(child: child)),
      ),
    );

final entrances = find.descendant(
  of: find.byType(VipEntrance),
  matching: find.byType(FadeTransition),
);

void main() {
  testWidgets('entrances stagger, settle and do not replay on rebuild',
      (tester) async {
    Widget sections() => Column(children: [
          const SizedBox(width: 80, height: 80).vipEntrance(),
          const SizedBox(width: 80, height: 80).vipEntrance(delayMs: 200),
        ]);
    await tester.pumpWidget(host(sections()));
    double opacity(int index) =>
        tester.widget<FadeTransition>(entrances.at(index)).opacity.value;
    await tester.pump(const Duration(milliseconds: 150));
    expect(opacity(0), greaterThan(0));
    expect(opacity(1), 0);
    await tester.pumpAndSettle();
    expect(opacity(0), 1);
    expect(opacity(1), 1);
    await tester.pumpWidget(host(sections()));
    expect(opacity(0), 1);
    expect(opacity(1), 1);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('reduced motion immediately reveals content, also mid-entrance',
      (tester) async {
    Widget section() =>
        const SizedBox(width: 80, height: 80).vipEntrance(delayMs: 200);
    await tester.pumpWidget(host(section(), reduced: true));
    expect(tester.widget<FadeTransition>(entrances).opacity.value, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(host(section()));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pumpWidget(host(section(), reduced: true));
    expect(tester.widget<FadeTransition>(entrances).opacity.value, 1);
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('press, cancellation, hover and keyboard preserve button actions',
      (tester) async {
    var taps = 0;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(host(ElevatedButton(
      focusNode: focus,
      onPressed: () => taps++,
      child: const Text('VIP'),
    ).vipActionFeedback()));
    double scale() =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
    final button = find.byType(ElevatedButton);
    final touch = await tester.startGesture(tester.getCenter(button));
    await tester.pump();
    expect(scale(), lessThan(1));
    await touch.up();
    await tester.pumpAndSettle();
    expect(scale(), 1);
    expect(taps, 1);
    final cancelled = await tester.startGesture(tester.getCenter(button));
    await tester.pump();
    await cancelled.cancel();
    await tester.pumpAndSettle();
    expect(scale(), 1);
    expect(taps, 1);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(button));
    await tester.pumpAndSettle();
    expect(scale(), greaterThan(1));
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(scale(), 1);
    await mouse.removePointer();
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(taps, 2);
  });

  testWidgets('reduced motion keeps feedback static and the button usable',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(
        ElevatedButton(
          onPressed: () => taps++,
          child: const Text('VIP'),
        ).vipActionFeedback(),
        reduced: true));
    final touch = await tester.startGesture(tester.getCenter(find.text('VIP')));
    await tester.pump();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    await touch.up();
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('removing a section during its delay leaves no animation running',
      (tester) async {
    await tester.pumpWidget(host(const SizedBox().vipEntrance(delayMs: 300)));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(tester.binding.transientCallbackCount, 0);
  });
}
