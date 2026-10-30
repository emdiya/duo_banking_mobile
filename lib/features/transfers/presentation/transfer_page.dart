import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/bloc/banking_cubit.dart';
import '../../../core/widgets/banking_widgets.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});
  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final form = GlobalKey<FormState>();
  final destination = TextEditingController();
  final name = TextEditingController();
  final amount = TextEditingController();
  final description = TextEditingController();
  String accountId = 'usd';
  bool review = false, busy = false;
  @override
  void dispose() {
    destination.dispose();
    name.dispose();
    amount.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<BankingCubit>().state.accounts;
    final account = accounts.firstWhere((a) => a.id == accountId);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          review ? 'Review transfer' : 'Move money. Simply.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        const Text('A simulated transfer. Your real money stays untouched.'),
        const SizedBox(height: 24),
        if (!review)
          Form(
            key: form,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: accountId,
                  decoration: const InputDecoration(labelText: 'From account'),
                  items: [
                    for (final a in accounts)
                      DropdownMenuItem(
                        value: a.id,
                        child: Text('${a.currency} • ${a.name}'),
                      ),
                  ],
                  onChanged: (v) => setState(() => accountId = v!),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Available: ${account.formatted}'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: destination,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Destination account',
                  ),
                  validator: (v) => (v?.replaceAll(' ', '').length ?? 0) < 8
                      ? 'Enter at least 8 digits'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Beneficiary name',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter a beneficiary name'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '${account.currency}  ',
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    return n == null || !n.isFinite || n <= 0
                        ? 'Enter an amount greater than zero'
                        : n > account.balance
                        ? 'Insufficient available balance'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: description,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  label: 'Continue',
                  onPressed: () {
                    if (form.currentState!.validate()) {
                      setState(() => review = true);
                    }
                  },
                ),
              ],
            ),
          ),
        if (review) ...[
          AdaptiveCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  for (final row in [
                    ('From', account.name),
                    ('To', name.text),
                    ('Account', destination.text),
                    ('Amount', '${account.currency} ${amount.text}'),
                    ('Fee', '${account.currency} 0.00'),
                    ('Total', '${account.currency} ${amount.text}'),
                  ])
                    ListTile(title: Text(row.$1), subtitle: Text(row.$2)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (busy)
            const Center(child: CircularProgressIndicator())
          else
            AppPrimaryButton(
              label: 'Confirm transfer',
              onPressed: () async {
                final pin = await showDialog<String>(
                  context: context,
                  builder: (context) => const _PinDialog(),
                );
                if (pin == null || !context.mounted) return;
                if (pin != '1234') {
                  context.push('/transfer-failure');
                  return;
                }
                setState(() => busy = true);
                await Future<void>.delayed(const Duration(milliseconds: 500));
                if (!context.mounted) return;
                try {
                  final id = context.read<BankingCubit>().transfer(
                    accountId,
                    name.text.trim(),
                    double.parse(amount.text),
                  );
                  context.go('/transfer-success/$id');
                } catch (_) {
                  context.push('/transfer-failure');
                  setState(() => busy = false);
                }
              },
            ),
          TextButton(
            onPressed: () => setState(() => review = false),
            child: const Text('Edit transfer'),
          ),
        ],
      ],
    );
  }
}

class _PinDialog extends StatefulWidget {
  const _PinDialog();
  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final pin = TextEditingController();
  @override
  void dispose() {
    pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Confirm with demo PIN'),
    content: TextField(
      controller: pin,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 4,
      decoration: const InputDecoration(
        helperText: 'Use 1234 for success. Other PINs simulate failure.',
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, pin.text),
        child: const Text('Confirm'),
      ),
    ],
  );
}

class TransferResultPage extends StatelessWidget {
  const TransferResultPage({super.key, this.id});
  final String? id;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(32),
    children: [
      const SizedBox(height: 60),
      Icon(
        id == null ? Icons.error_outline : Icons.check_circle_rounded,
        size: 96,
        color: id == null ? Colors.red : const Color(0xFF16A34A),
      ),
      const SizedBox(height: 24),
      Text(
        id == null ? 'Transfer unsuccessful' : 'Money on its way',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 16),
      Text(
        id == null
            ? 'The demo PIN was incorrect. No money was moved.'
            : 'Your simulated transfer is complete.\nReference: $id',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      AppPrimaryButton(
        label: id == null ? 'Retry' : 'View receipt',
        onPressed: () =>
            id == null ? context.pop() : context.push('/transaction/$id'),
      ),
      TextButton(
        onPressed: () => context.go('/home'),
        child: const Text('Back to Home'),
      ),
      TextButton(
        onPressed: () => context.push('/transactions'),
        child: const Text('Transaction history'),
      ),
    ],
  );
}
