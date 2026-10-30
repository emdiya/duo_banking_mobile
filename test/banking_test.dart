import 'package:duo_banking_lab/shared/models/banking.dart';
import 'package:duo_banking_lab/shared/bloc/banking_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mock data is deterministic and covers six transaction categories', () {
    final transactions = MockBankRepository.transactions();
    expect(transactions.length, greaterThanOrEqualTo(50));
    expect(transactions.map((t) => t.category).toSet().length, 6);
    expect(transactions.first.date, DateTime(2026, 10, 28, 14, 32));
  });
  test('Transfer updates source balance and matching history atomically', () {
    final controller = BankingCubit();
    addTearDown(controller.close);
    final id = controller.transfer('usd', 'Jamie', 25);
    final state = controller.state;
    expect(state.accounts.first.balance, 12425.75);
    expect(state.transactions.first.id, id);
    expect(state.transactions.first.amount, -25);
    expect(state.transactions.length, 61);
    expect(state.accounts[1].balance, 8750000);
  });
  test('Invalid transfers leave balances and history untouched', () {
    final controller = BankingCubit();
    addTearDown(controller.close);
    final before = controller.state;
    for (final amount in [-1.0, 0.0, double.nan, double.infinity, 999999.0]) {
      expect(
        () => controller.transfer('usd', 'Jamie', amount),
        throwsStateError,
      );
      expect(identical(before, controller.state), isTrue);
    }
  });
}
