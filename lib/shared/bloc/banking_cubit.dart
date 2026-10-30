import '../../core/storage/session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/banking.dart';

class BankState {
  BankState({
    this.accounts = MockBankRepository.accounts,
    List<BankTransaction>? transactions,
    this.hidden = false,
    this.theme = ThemeMode.system,
    this.khmer = false,
    this.frozen = false,
    this.notifications = true,
    this.read = false,
    this.signedIn = false,
  }) : transactions = transactions ?? MockBankRepository.transactions();
  final List<BankAccount> accounts;
  final List<BankTransaction> transactions;
  final bool hidden, khmer, frozen, notifications, read, signedIn;
  final ThemeMode theme;
  BankState copy({
    List<BankAccount>? accounts,
    List<BankTransaction>? transactions,
    bool? hidden,
    ThemeMode? theme,
    bool? khmer,
    bool? frozen,
    bool? notifications,
    bool? read,
    bool? signedIn,
  }) => BankState(
    accounts: accounts ?? this.accounts,
    transactions: transactions ?? this.transactions,
    hidden: hidden ?? this.hidden,
    theme: theme ?? this.theme,
    khmer: khmer ?? this.khmer,
    frozen: frozen ?? this.frozen,
    notifications: notifications ?? this.notifications,
    read: read ?? this.read,
    signedIn: signedIn ?? this.signedIn,
  );
}

class BankingCubit extends Cubit<BankState> {
  BankingCubit({SessionStore? sessionStore, bool signedIn = false})
    : sessionStore = sessionStore ?? SessionStore(),
      super(BankState(signedIn: signedIn));

  final SessionStore sessionStore;

  Future<void> signIn({required bool remember}) async {
    await sessionStore.save(remember: remember);
    if (!isClosed) emit(state.copy(signedIn: true));
  }

  Future<void> signOut() async {
    await sessionStore.clear();
    if (!isClosed) emit(BankState());
  }

  void visibility() => emit(state.copy(hidden: !state.hidden));
  void theme(ThemeMode mode) => emit(state.copy(theme: mode));
  void language(bool khmer) => emit(state.copy(khmer: khmer));
  void freeze(bool value) => emit(state.copy(frozen: value));
  void notifications(bool value) => emit(state.copy(notifications: value));
  void markRead() => emit(state.copy(read: true));
  String transfer(String accountId, String recipient, double amount) {
    final account = state.accounts.firstWhere((a) => a.id == accountId);
    if (!amount.isFinite || amount <= 0 || amount > account.balance) {
      throw StateError('Invalid transfer amount');
    }
    final id = 'DUO${202610280000 + state.transactions.length}';
    emit(
      state.copy(
        accounts: [
          for (final a in state.accounts)
            if (a.id == accountId) a.withBalance(a.balance - amount) else a,
        ],
        transactions: [
          BankTransaction(
            id: id,
            title: recipient,
            category: 'Transfer',
            amount: -amount,
            date: DateTime(2026, 10, 28, 15),
            accountId: accountId,
            currency: account.currency,
          ),
          ...state.transactions,
        ],
      ),
    );
    return id;
  }
}
