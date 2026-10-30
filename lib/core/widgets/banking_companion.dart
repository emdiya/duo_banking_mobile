import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../app/localization/strings.dart';
import '../../shared/bloc/banking_cubit.dart';
import 'banking_widgets.dart';

/// A scrolling companion for the wider inner display and regular-width windows.
class BankingCompanion extends StatelessWidget {
  const BankingCompanion({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<BankingCubit>().state;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            tr(context, 'My accounts'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          for (final account in state.accounts)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: Text(account.name),
              subtitle: Text(state.hidden ? '••••••' : account.formatted),
              onTap: () => context.push('/account/${account.id}'),
            ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: 'Transfer',
            icon: Icons.north_east,
            onPressed: () => context.push('/transfer'),
          ),
          const SizedBox(height: 12),
          AppPrimaryButton(
            label: 'Receive',
            icon: Icons.qr_code,
            onPressed: () => context.push('/my-qr'),
          ),
          const SizedBox(height: 24),
          Text(
            tr(context, 'Recent activity'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final transaction in state.transactions.take(4))
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(transaction.title),
              subtitle: Text(state.hidden ? '••••••' : transaction.formatted),
              onTap: () => context.push('/transaction/${transaction.id}'),
            ),
        ],
      ),
    );
  }
}
