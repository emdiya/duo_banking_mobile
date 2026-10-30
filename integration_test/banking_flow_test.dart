import 'package:duo_banking_lab/core/widgets/banking_widgets.dart';
import 'package:duo_banking_lab/shared/bloc/banking_cubit.dart';
import 'package:duo_banking_lab/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Login → transfer → review → success → history', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => BankingCubit(),
        child: KhmerBankApp(initialLocation: '/login'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('identity')), 'alex');
    await tester.enterText(find.byKey(const Key('password')), 'demo123');
    await tester.ensureVisible(find.widgetWithText(AppPrimaryButton, 'Login'));
    await tester.tap(find.widgetWithText(AppPrimaryButton, 'Login'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Transfer'));
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '123456789');
    await tester.enterText(fields.at(1), 'Jamie Demo');
    await tester.enterText(fields.at(2), '25');
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Review transfer'), findsOneWidget);
    await tester.ensureVisible(find.text('Confirm transfer'));
    await tester.tap(find.text('Confirm transfer'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '1234');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Money on its way'), findsOneWidget);
    await tester.ensureVisible(find.text('Transaction history'));
    await tester.tap(find.text('Transaction history'));
    await tester.pumpAndSettle();
    expect(find.text('Jamie Demo'), findsOneWidget);
  });
}
