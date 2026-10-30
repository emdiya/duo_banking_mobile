import 'package:duo_banking_lab/app/app.dart';
import 'package:duo_banking_lab/core/widgets/banking_widgets.dart';
import 'package:duo_banking_lab/shared/bloc/banking_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> open(WidgetTester tester, String route) async {
  await tester.pumpWidget(
    BlocProvider(
      create: (_) => BankingCubit(),
      child: KhmerBankApp(initialLocation: route),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Login validates empty credentials', (tester) async {
    await open(tester, '/login');
    await tester.ensureVisible(find.widgetWithText(AppPrimaryButton, 'Login'));
    await tester.tap(find.widgetWithText(AppPrimaryButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsOneWidget);
    expect(find.text('Use at least 6 characters'), findsOneWidget);
  });
  testWidgets('Dashboard renders fictional customer and can hide balances', (
    tester,
  ) async {
    await open(tester, '/home');
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('\$12,450.75'), findsWidgets);
    await tester.tap(find.byTooltip('Hide balance'));
    await tester.pumpAndSettle();
    expect(find.text('\$12,450.75'), findsNothing);
    expect(find.text('••••••'), findsWidgets);
  });
  testWidgets('Bottom tabs navigate and preserve account search', (
    tester,
  ) async {
    await open(tester, '/home');
    await tester.tap(find.text('Accounts').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Khmer');
    await tester.pumpAndSettle();
    expect(find.text('Everyday savings'), findsNothing);
    await tester.tap(find.text('Cards').last);
    await tester.pumpAndSettle();
    expect(find.text('Your everyday companion.'), findsOneWidget);
    await tester.tap(find.text('Accounts').last);
    await tester.pumpAndSettle();
    expect(find.text('Khmer'), findsOneWidget);
  });
  testWidgets('Transaction search renders empty state', (tester) async {
    await open(tester, '/transactions');
    await tester.enterText(find.byType(TextField), 'unmatched merchant');
    await tester.pumpAndSettle();
    expect(find.text('No matching transactions'), findsOneWidget);
  });
  testWidgets('Transfer rejects amount greater than available balance', (
    tester,
  ) async {
    await open(tester, '/transfer');
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '123456789');
    await tester.enterText(fields.at(1), 'Jamie');
    await tester.enterText(fields.at(2), '999999999');
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Insufficient available balance'), findsOneWidget);
  });
  testWidgets('Theme and language switch immediately', (tester) async {
    await open(tester, '/settings');
    await tester.tap(find.text('dark'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Appearance'))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.text('ខ្មែរ'));
    await tester.pumpAndSettle();
    expect(find.text('ការកំណត់'), findsWidgets);
  });
  testWidgets('Empty and error widgets provide readable states', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const AppEmptyState(),
              AppErrorState(onRetry: () => retried = true),
            ],
          ),
        ),
      ),
    );
    expect(find.text('No activity yet'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, isTrue);
  });
  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(430, 932),
    const Size(800, 1280),
    const Size(844, 390),
  ]) {
    testWidgets('Dashboard has no layout exception at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await open(tester, '/home');
      expect(tester.takeException(), isNull);
    });
  }
}
