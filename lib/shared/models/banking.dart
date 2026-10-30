import 'package:intl/intl.dart';

class BankAccount {
  const BankAccount(
    this.id,
    this.name,
    this.currency,
    this.balance,
    this.number,
  );
  final String id, name, currency, number;
  final double balance;
  String get formatted => currency == 'USD'
      ? NumberFormat.currency(symbol: '\$').format(balance)
      : '${NumberFormat('#,##0').format(balance)} ៛';
  BankAccount withBalance(double value) =>
      BankAccount(id, name, currency, value, number);
}

class BankTransaction {
  const BankTransaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.accountId = 'usd',
    this.currency = 'USD',
  });
  final String id, title, category, accountId, currency;
  final double amount;
  final DateTime date;
  String get formatted =>
      '${amount >= 0 ? '+' : '−'}${currency == 'USD' ? '\$' : '៛'}${NumberFormat('#,##0.00').format(amount.abs())}';
}

class MockBankRepository {
  static const accounts = [
    BankAccount('usd', 'Everyday savings', 'USD', 12450.75, '001 234 567 890'),
    BankAccount('khr', 'Khmer savings', 'KHR', 8750000, '002 234 567 890'),
    BankAccount(
      'current',
      'Current account',
      'USD',
      3280.50,
      '003 234 567 890',
    ),
  ];
  static List<BankTransaction> transactions() => List.generate(60, (i) {
    const names = [
      'The Coffee Lab',
      'Monthly salary',
      'Alex → Jamie',
      'Electricity bill',
      'Mobile top-up',
      'ATM withdrawal',
    ];
    const categories = [
      'QR payment',
      'Deposit',
      'Transfer',
      'Bill payment',
      'Top-up',
      'Withdrawal',
    ];
    return BankTransaction(
      id: 'DUO${202610280000 + i}',
      title: names[i % 6],
      category: categories[i % 6],
      amount: i % 6 == 1 ? 2450 : -(4.5 + i * 3.25),
      date: DateTime(2026, 10, 28, 14, 32).subtract(Duration(hours: i * 7)),
    );
  });
}
