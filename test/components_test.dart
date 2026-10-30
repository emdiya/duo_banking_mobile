import 'package:duo_banking_lab/app/theme/app_theme.dart';
import 'package:duo_banking_lab/core/widgets/banking_widgets.dart';
import 'package:duo_banking_lab/core/widgets/app_components.dart';
import 'package:duo_banking_lab/shared/models/banking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final dark in [false, true]) {
    for (final width in [320.0, 390.0, 800.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'Banking components: width=$width, scale=$scale, dark=$dark',
          (tester) async {
            tester.view.physicalSize = Size(width, 1000);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.build(
                  dark ? Brightness.dark : Brightness.light,
                ),
                home: MediaQuery(
                  data: MediaQueryData(
                    size: Size(width, 1000),
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: Scaffold(
                    body: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        AppAccountCard(
                          account: MockBankRepository.accounts.first,
                        ),
                        AppTransactionTile(
                          transaction: MockBankRepository.transactions().first,
                        ),
                        AppPrimaryButton(label: 'Continue', onPressed: () {}),
                        const AppBalanceDisplay(
                          balance: '\$12,450.75',
                          hidden: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.text('••••••'), findsOneWidget);
          },
        );
      }
    }
  }
  testWidgets('Loading, empty and error components render', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              const AppShimmerCard(),
              const AppEmptyState(),
              AppErrorState(onRetry: () => retried = true),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('No activity yet'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, isTrue);
  });
}
