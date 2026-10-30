import 'package:duo_banking_lab/features/auth/presentation/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> open(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double scale = 1,
  double keyboard = 0,
  Future<void> Function()? onLogin,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LoginForm(
            onLogin: onLogin ?? () async {},
            onForgot: () {},
            onRegister: () {},
            onBiometric: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final scenario in [
    (const Size(320, 568), 1.0, 0.0),
    (const Size(390, 844), 2.0, 300.0),
    (const Size(844, 390), 1.0, 0.0),
    (const Size(320, 420), 3.0, 0.0),
  ]) {
    testWidgets('Login action is visible: $scenario', (tester) async {
      await open(
        tester,
        size: scenario.$1,
        scale: scenario.$2,
        keyboard: scenario.$3,
      );
      final action = find.byKey(const Key('login-submit'));
      expect(action.hitTestable(), findsOneWidget);
      expect(
        tester.getRect(action).bottom,
        lessThanOrEqualTo(scenario.$1.height - scenario.$3),
      );
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Visible login action validates empty credentials', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsOneWidget);
    expect(find.text('Use at least 6 characters'), findsOneWidget);
  });
  testWidgets('Demo credentials invoke login', (tester) async {
    var submitted = false;
    await open(
      tester,
      onLogin: () async {
        submitted = true;
      },
    );
    await tester.enterText(find.byKey(const Key('identity')), 'alex');
    await tester.enterText(find.byKey(const Key('password')), 'demo123');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(submitted, isTrue);
  });
  testWidgets('Very short window can scroll to login without overflow', (
    tester,
  ) async {
    await open(tester, size: const Size(320, 180), scale: 2);
    final action = find.byKey(const Key('login-submit'));
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    expect(action.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
