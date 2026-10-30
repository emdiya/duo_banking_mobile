import 'package:duo_banking_lab/features/onboarding/presentation/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<void> openOnboarding(
  WidgetTester tester,
  Size size,
  double scale,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
      GoRoute(
        path: '/login',
        builder: (_, _) => const Scaffold(body: Text('Login destination')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [
    const Size(320, 420),
    const Size(320, 568),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    for (final scale in [1.0, 2.0, 3.0]) {
      testWidgets('Onboarding scrolls without overflow at $size / $scale', (
        tester,
      ) async {
        await openOnboarding(tester, size, scale);
        expect(tester.takeException(), isNull);
        final login = find.byKey(const Key('onboarding-login'));
        await tester.ensureVisible(login);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(login);
        await tester.pumpAndSettle();
        expect(find.text('Login destination'), findsOneWidget);
      });
    }
  }
  testWidgets('Next advances all pages and Get started opens login', (
    tester,
  ) async {
    await openOnboarding(tester, const Size(320, 568), 2);
    for (var i = 0; i < 3; i++) {
      final next = find.byKey(const Key('onboarding-next'));
      await tester.ensureVisible(next);
      await tester.pumpAndSettle();
      if (i == 2) expect(find.text('Get started'), findsOneWidget);
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.text('Login destination'), findsOneWidget);
  });
  testWidgets('Skip opens login immediately', (tester) async {
    await openOnboarding(tester, const Size(390, 844), 1);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Login destination'), findsOneWidget);
  });
}
