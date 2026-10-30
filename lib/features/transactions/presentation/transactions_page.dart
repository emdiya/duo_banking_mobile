import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/bloc/banking_cubit.dart';
import '../../../core/widgets/banking_widgets.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key, this.id});
  final String? id;
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String search = '', filter = 'All';
  int count = 20;
  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<BankingCubit>().state.transactions;
    if (widget.id != null) {
      final t = transactions.firstWhere((t) => t.id == widget.id);
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(radius: 36, child: Icon(Icons.check, size: 36)),
          const SizedBox(height: 24),
          Center(
            child: Text(
              t.formatted,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const Center(child: Text('Completed')),
          const SizedBox(height: 32),
          for (final item in [
            ('Reference', t.id),
            ('Date', DateFormat('dd MMM yyyy • HH:mm').format(t.date)),
            ('From', t.amount < 0 ? 'Alex Morgan' : t.title),
            ('To', t.amount < 0 ? t.title : 'Alex Morgan'),
            ('Description', t.category),
          ])
            ListTile(title: Text(item.$1), subtitle: Text(item.$2)),
          AppPrimaryButton(
            label: 'Download receipt',
            onPressed: () => AdaptiveSnackBar.show(
              context,
              message: 'Demo receipt requested',
            ),
          ),
        ],
      );
    }
    final filtered = transactions
        .where(
          (t) =>
              t.title.toLowerCase().contains(search.toLowerCase()) &&
              (filter == 'All' || t.category == filter),
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Transactions', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 24),
        TextField(
          onChanged: (v) => setState(() => search = v),
          decoration: const InputDecoration(
            hintText: 'Search transactions',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final c in [
                'All',
                'Transfer',
                'QR payment',
                'Deposit',
                'Bill payment',
                'Top-up',
                'Withdrawal',
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: filter == c,
                    onSelected: (_) => setState(() => filter = c),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const AppEmptyState(message: 'No matching transactions'),
        for (var i = 0; i < filtered.length && i < count; i++) ...[
          if (i == 0 || filtered[i].date.day != filtered[i - 1].date.day)
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 8),
              child: Text(
                DateFormat('EEEE, d MMM').format(filtered[i].date),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          AppTransactionTile(
            transaction: filtered[i],
            onTap: () => context.push('/transaction/${filtered[i].id}'),
          ),
        ],
        if (filtered.length > count)
          TextButton(
            onPressed: () => setState(() => count += 20),
            child: const Text('Load more'),
          ),
      ],
    );
  }
}
