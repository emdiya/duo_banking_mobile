import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import 'qr_confirm_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/bloc/banking_cubit.dart';

class QrPaymentPage extends StatefulWidget {
  const QrPaymentPage({super.key});
  @override
  State<QrPaymentPage> createState() => _QrPaymentPageState();
}

class _QrPaymentPageState extends State<QrPaymentPage> {
  String accountId = 'khr';
  String currency = 'USD';
  String input = '';
  String remark = '';
  final remarkController = TextEditingController();

  @override
  void dispose() {
    remarkController.dispose();
    super.dispose();
  }

  String? error;
  double? operand;
  String? operation;
  bool replace = false;
  bool keypad = true;
  bool paying = false;
  static const recipient = 'Ruska Roma Eve Macarro';

  void press(String key) {
    setState(() {
      error = null;
      if (key == 'C') {
        input = '';
        operand = null;
        operation = null;
        replace = false;
      } else if (key == '⌫') {
        if (input.isNotEmpty) input = input.substring(0, input.length - 1);
      } else if (['+', '−', '×', '÷', '='].contains(key)) {
        final value = double.tryParse(input);
        if (value == null) return;
        if (operand != null && operation != null && !replace) {
          final result = switch (operation) {
            '+' => operand! + value,
            '−' => operand! - value,
            '×' => operand! * value,
            _ => value == 0 ? double.nan : operand! / value,
          };
          if (!result.isFinite) {
            error = 'Cannot divide by zero';
            return;
          }
          input = result.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
        }
        operand = key == '=' ? null : double.tryParse(input);
        operation = key == '=' ? null : key;
        replace = true;
      } else {
        if (replace) {
          input = '';
          replace = false;
        }
        if (key == '.' && input.contains('.')) return;
        if (input.length >= 12) return;
        input += key == '.' && input.isEmpty ? '0.' : key;
      }
    });
  }

  Widget key(
    String label, {
    bool operator = false,
    bool muted = false,
    double height = 56,
  }) => Expanded(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: height,
        child: TextButton(
          onPressed: () => press(label),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: muted
                ? const Color(0xFF62748E)
                : operator
                ? const Color(0xFF265EA4)
                : Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: label == '⌫' ? 25 : 32,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> addRemark() async {
    remarkController.text = remark;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Remark'),
        content: TextField(
          controller: remarkController,
          autofocus: true,
          maxLength: 140,
          decoration: const InputDecoration(hintText: 'Payment remark'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, remarkController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (mounted && result != null) {
      setState(() => remark = result);
    }
  }

  Future<void> pay(double debit, String debitCurrency) async {
    final account = context.read<BankingCubit>().state.accounts.firstWhere(
      (a) => a.id == accountId,
    );
    if (!debit.isFinite || debit <= 0 || debit > account.balance) {
      setState(
        () => error = debit > account.balance
            ? 'Insufficient balance'
            : 'Enter an amount greater than zero',
      );
      return;
    }
    setState(() => paying = true);
    Widget confirmationBuilder(BuildContext context) => QrConfirmPage(
      amount: debit,
      currency: debitCurrency,
      recipient: recipient,
      remark: remark,
    );
    final confirmed = await Navigator.of(context).push<bool>(
      PlatformInfo.isIOS
          ? CupertinoPageRoute<bool>(builder: confirmationBuilder)
          : MaterialPageRoute<bool>(builder: confirmationBuilder),
    );
    if (!mounted) return;
    if (confirmed != true) {
      setState(() => paying = false);
      return;
    }
    try {
      final id = context.read<BankingCubit>().transfer(
        accountId,
        recipient,
        debit,
      );
      context.go('/transfer-success/$id');
    } on StateError {
      setState(() {
        paying = false;
        error = 'Payment could not be completed. Check your balance.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<BankingCubit>().state.accounts;
    final account = accounts.firstWhere((a) => a.id == accountId);
    final amount = double.tryParse(input) ?? 0;
    final converted = currency == account.currency
        ? amount
        : currency == 'USD'
        ? amount * 4100
        : amount / 4100;
    final debit = account.currency == 'KHR'
        ? converted.roundToDouble()
        : (converted * 100).roundToDouble() / 100;
    return AppPageScaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'QR Payment',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.chevron_left),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        actions: [
          IconButton(
            tooltip: 'Support',
            onPressed: () => context.push('/support'),
            icon: const Icon(Icons.headset_mic_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: !keypad,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wrap(
                      spacing: 12,
                      children: [
                        Text('Transfer To:', style: TextStyle(fontSize: 16)),
                        Text(
                          recipient,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00667D),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'BANK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD71920),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.qr_code_2,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Account: 000 123 333\nBank: Advance Bank of Asia',
                            style: TextStyle(fontSize: 12, height: 1.5),
                          ),
                        ),
                        const Icon(
                          Icons.monetization_on_outlined,
                          color: Color(0xFFF2F2F2),
                          size: 60,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Pay From:', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: accountId,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 20,
                              ),
                              items: [
                                for (final a in accounts)
                                  DropdownMenuItem(
                                    value: a.id,
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            a.number,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xFFFF5060),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                          child: Text(
                                            a.currency,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFFD71920),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                              onChanged: (value) => setState(() {
                                accountId = value!;
                                error = null;
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => setState(() => keypad = true),
                      borderRadius: BorderRadius.circular(13),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                reverse: true,
                                child: Text(
                                  input.isEmpty ? '0.00' : input,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 42,
                              width: 1,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              color: Colors.grey,
                            ),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  for (final c in ['KHR', 'USD'])
                                    InkWell(
                                      onTap: () => setState(() => currency = c),
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: currency == c
                                              ? Colors.white
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          c == 'USD' ? '\$' : '៛',
                                          style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600,
                                            color: currency == c
                                                ? const Color(0xFF333333)
                                                : const Color(0xFFCCCCCC),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(
                  children: [
                    const Text('Debit Amount:', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD51025),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '${NumberFormat('#,##0.00').format(debit)} ${account.currency}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: addRemark,
                child: Text(
                  remark.isEmpty ? 'Add Remark' : remark,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7474FF),
                    fontSize: 15,
                  ),
                ),
              ),
              if (currency != account.currency)
                const Text(
                  'Demo exchange rate: 1 USD = 4,100 KHR',
                  style: TextStyle(fontSize: 10, color: Colors.black45),
                ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              Container(
                margin: const EdgeInsets.fromLTRB(24, 22, 24, 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5C13), Color(0xFFFFAC08)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 47),
                  ),
                  onPressed: paying ? null : () => pay(debit, account.currency),
                  child: Text(
                    paying ? 'Processing…' : 'Pay',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              if (keypad)
                Container(
                  color: const Color(0xFF203F63),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    10,
                    MediaQuery.paddingOf(context).bottom + 16,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: IconButton(
                          tooltip: 'Hide keypad',
                          onPressed: () => setState(() => keypad = false),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          key('7'),
                          key('8'),
                          key('9'),
                          key('+', operator: true),
                          key('⌫', muted: true),
                        ],
                      ),
                      Row(
                        children: [
                          key('4'),
                          key('5'),
                          key('6'),
                          key('−', operator: true),
                          key('C', muted: true),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    key('1'),
                                    key('2'),
                                    key('3'),
                                    key('×', operator: true),
                                  ],
                                ),
                                Row(
                                  children: [
                                    key('00'),
                                    key('0'),
                                    key('.'),
                                    key('÷', operator: true),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          key('=', operator: true, height: 128),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
