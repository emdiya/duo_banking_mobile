import '../../../core/widgets/app_page_scaffold.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../../../shared/models/banking.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/bloc/banking_cubit.dart';
import '../../../core/widgets/banking_widgets.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key, this.id});
  final String? id;
  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  String search = '';
  String currency = 'All';
  final expanded = <String>{'Saving Accounts'};
  Widget _listing(
    BuildContext context,
    List<BankAccount> accounts,
    bool hidden,
  ) {
    final visible = accounts
        .where((a) => currency == 'All' || a.currency == currency)
        .toList();
    final totals = {
      for (final c in ['USD', 'KHR'])
        c: accounts
            .where((a) => a.currency == c)
            .fold<double>(0, (sum, a) => sum + a.balance),
    };
    return AppPageScaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'My Accounts',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          tooltip: 'Back to home',
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Balance',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Column(
                            children: [
                              for (final c in ['USD', 'KHR']) ...[
                                if (c == 'KHR')
                                  const Divider(
                                    height: 12,
                                    color: Colors.white,
                                  ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        alignment: Alignment.centerLeft,
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          hidden
                                              ? '••••••'
                                              : NumberFormat(
                                                  '#,##0.00',
                                                ).format(totals[c]),
                                          style: const TextStyle(
                                            fontSize: 21,
                                            color: Color(0xFFFF7100),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      c,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 126,
                    height: 126,
                    child: CustomPaint(
                      painter: _AccountChart(accounts.length),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              accounts.length.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              'Accounts',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _action(
                    Icons.add_circle_outline,
                    'New Account',
                    () => context.push('/new-account'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _action(
                    Icons.filter_list,
                    currency == 'All'
                        ? 'All Accounts Type'
                        : '$currency Accounts',
                    () async {
                      final result = await showModalBottomSheet<String>(
                        context: context,
                        showDragHandle: true,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  'Select account type',
                                  style: TextStyle(fontSize: 19),
                                ),
                              ),
                              for (final c in ['All', 'USD', 'KHR'])
                                ListTile(
                                  title: Text(
                                    c == 'All'
                                        ? 'All Accounts Type'
                                        : '$c Accounts',
                                  ),
                                  trailing: c == currency
                                      ? const Icon(
                                          Icons.check,
                                          color: Color(0xFFFF7100),
                                        )
                                      : null,
                                  onTap: () => Navigator.pop(ctx, c),
                                ),
                            ],
                          ),
                        ),
                      );
                      if (mounted && result != null) {
                        setState(() => currency = result);
                      }
                    },
                  ),
                ),
              ],
            ),
            for (final section in [
              'Saving Accounts',
              'Fixed Deposit',
              'Currency Accounts',
            ]) ...[
              InkWell(
                onTap: () => setState(() {
                  if (!expanded.add(section)) expanded.remove(section);
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          section,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        expanded.contains(section)
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
              if (expanded.contains(section)) ...[
                if (section == 'Saving Accounts')
                  for (final a in visible)
                    _accountTile(context, a, accounts.indexOf(a), hidden)
                else
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No accounts in this category',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                if (section == 'Saving Accounts' && visible.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No matching accounts'),
                  ),
              ],
              if (section != 'Saving Accounts')
                const Divider(height: 1, color: Color(0xFFCCCCCC)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) =>
      TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF222222),
          minimumSize: const Size.fromHeight(44),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        icon: Icon(icon, size: 22, color: const Color(0xFF657793)),
        label: Text(label, style: const TextStyle(fontSize: 12)),
      );

  Widget _accountTile(
    BuildContext context,
    BankAccount a,
    int index,
    bool hidden,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Stack(
      children: [
        Container(
          width: 80,
          height: 20,
          decoration: BoxDecoration(
            color: index.isEven
                ? const Color(0xFFFFCF00)
                : const Color(0xFFA13CFF),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFE8E8E8), width: 2),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => context.push('/account/${a.id}'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 5, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.name,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Account options',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.more_horiz),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'details',
                              child: Text('View details'),
                            ),
                            PopupMenuItem(
                              value: 'copy',
                              child: Text('Copy account number'),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'details') {
                              context.push('/account/${a.id}');
                              return;
                            }
                            await Clipboard.setData(
                              ClipboardData(text: a.number),
                            );
                            if (context.mounted) {
                              AdaptiveSnackBar.show(
                                context,
                                message: 'Account number copied',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (index == 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA8CEFF),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF153F8C),
                              ),
                            ),
                          ),
                        Text(a.number, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Mobile Saving Account',
                      style: TextStyle(fontSize: 10, color: Color(0xFF8795A3)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final mark in ['VISA', '●●', 'KHQR'])
                          Container(
                            margin: const EdgeInsets.only(right: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFEEEEEE),
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              mark,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                                color: mark == '●●'
                                    ? Colors.orange
                                    : const Color(0xFF1745BB),
                              ),
                            ),
                          ),
                        const Spacer(),
                        Flexible(
                          flex: 3,
                          child: Text(
                            hidden
                                ? '••••••'
                                : NumberFormat('#,##0.00').format(a.balance),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFFF7100),
                            ),
                          ),
                        ),
                        Text(
                          ' ${a.currency}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BankingCubit>().state;
    final accounts = state.accounts.where(
      (a) =>
          (widget.id == null || a.id == widget.id) &&
          a.name.toLowerCase().contains(search.toLowerCase()) &&
          (currency == 'All' || a.currency == currency),
    );
    if (widget.id == null) {
      return _listing(context, state.accounts, state.hidden);
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          widget.id == null ? 'My accounts' : 'Account details',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        const Text('A clear view of your everyday money.'),
        const SizedBox(height: 24),
        if (widget.id == null) ...[
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search accounts',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => search = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final c in ['All', 'USD', 'KHR'])
                ChoiceChip(
                  label: Text(c),
                  selected: currency == c,
                  onSelected: (_) => setState(() => currency = c),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        for (final a in accounts) ...[
          AppAccountCard(
            account: a,
            hidden: state.hidden,
            onTap: widget.id == null
                ? () => context.push('/account/${a.id}')
                : null,
          ),
          const SizedBox(height: 16),
          if (widget.id != null) ...[
            ListTile(
              title: const Text('Account number'),
              subtitle: Text(a.number),
              trailing: IconButton(
                tooltip: 'Copy account number',
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: a.number));
                  AdaptiveSnackBar.show(
                    context,
                    message: 'Account number copied',
                  );
                },
              ),
            ),
            const ListTile(title: Text('Status'), trailing: Text('Active')),
            const ListTile(
              title: Text('Type'),
              trailing: Text('Personal savings'),
            ),
            AppPrimaryButton(
              label: 'Download statement',
              onPressed: () => AdaptiveSnackBar.show(
                context,
                message: 'Demo statement requested',
              ),
            ),
            const SizedBox(height: 16),
            const AppSectionHeader('Recent activity'),
            for (final t
                in state.transactions.where((t) => t.accountId == a.id).take(8))
              AppTransactionTile(
                transaction: t,
                onTap: () => context.push('/transaction/${t.id}'),
              ),
          ],
        ],
        if (accounts.isEmpty)
          const AppEmptyState(message: 'No matching accounts'),
      ],
    );
  }
}

class _AccountChart extends CustomPainter {
  const _AccountChart(this.count);
  final int count;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const colors = [Color(0xFF009ABA), Color(0xFFFFBF00), Color(0xFFAC49DE)];
    final segments = count == 0 ? 1 : count;
    for (var i = 0; i < segments; i++) {
      final sweep = 2 * math.pi / segments;
      canvas.drawArc(
        rect.deflate(10),
        -math.pi / 2 + i * sweep + .055,
        sweep - .11,
        false,
        Paint()
          ..color = count == 0
              ? const Color(0xFFEEEEEE)
              : colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 19
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_AccountChart oldDelegate) => count != oldDelegate.count;
}
