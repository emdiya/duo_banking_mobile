import '../../../core/widgets/app_page_scaffold.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/banking_widgets.dart';
import '../../../shared/bloc/banking_cubit.dart';
import '../../../shared/models/banking.dart';

class QrPage extends StatefulWidget {
  const QrPage({super.key, this.receive = false});
  final bool receive;
  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  final amountController = TextEditingController();
  String accountId = 'usd';
  bool flash = false;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<BankingCubit>().state.accounts;
    final account = accounts.firstWhere((a) => a.id == accountId);
    final amount = double.tryParse(amountController.text);
    final invalidAmount =
        amountController.text.isNotEmpty &&
        (amount == null || !amount.isFinite || amount <= 0);
    final formattedAmount = !invalidAmount && amount != null
        ? NumberFormat.currency(
            symbol: account.currency == 'USD' ? '\$' : '៛',
            decimalDigits: account.currency == 'USD' ? 2 : 0,
          ).format(amount)
        : null;

    if (widget.receive) {
      return AppPageScaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            'My QR',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.cancel_outlined),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Show this QR to receive money',
                style: TextStyle(fontSize: 19, color: Color(0xFF333333)),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 393),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(46, 24, 46, 24),
                children: [
                  _ReceiveCard(amount: formattedAmount),
                  const SizedBox(height: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5C13), Color(0xFFFFAC08)],
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(40),
                      ),
                      icon: const Icon(Icons.wallet_outlined, size: 23),
                      label: const Text('Set Amount'),
                      onPressed: () async {
                        final result =
                            await showModalBottomSheet<
                              ({String amount, String accountId})
                            >(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => _SetAmountSheet(
                                initialAmount: amountController.text,
                                initialAccountId: accountId,
                                currencies: {
                                  for (final a in accounts) a.id: a.currency,
                                },
                              ),
                            );
                        if (!mounted || result == null) return;
                        setState(() {
                          amountController.text = result.amount;
                          accountId = result.accountId;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 13,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Receive accounts:',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final currency
                            in accounts.map((a) => a.currency).toSet())
                          for (final a in [
                            account.currency == currency
                                ? account
                                : accounts.firstWhere(
                                    (a) => a.currency == currency,
                                  ),
                          ])
                            InkWell(
                              onTap: () async {
                                final selected =
                                    await showModalBottomSheet<String>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => _ReceiveAccountSheet(
                                        accounts: accounts
                                            .where(
                                              (item) =>
                                                  item.currency == a.currency,
                                            )
                                            .toList(),
                                        selectedId: accountId,
                                        defaultId: accounts
                                            .firstWhere(
                                              (item) =>
                                                  item.currency == a.currency,
                                            )
                                            .id,
                                      ),
                                    );
                                if (!mounted || selected == null) return;
                                setState(() => accountId = selected);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: a.currency == 'USD'
                                            ? const Color(0xFFB3A600)
                                            : const Color(0xFFD51025),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        a.currency,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        a.number,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Icon(
                                      accountId == a.id
                                          ? Icons.keyboard_arrow_down
                                          : Icons.keyboard_arrow_right,
                                      size: 20,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final action in [
                        (Icons.download_outlined, 'Download'),
                        (Icons.ios_share_outlined, 'Share'),
                      ]) ...[
                        if (action.$2 == 'Share') const SizedBox(width: 12),
                        Expanded(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF333333),
                              minimumSize: const Size.fromHeight(40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            icon: Icon(
                              action.$1,
                              size: 21,
                              color: const Color(0xFF697B98),
                            ),
                            label: Text(
                              action.$2,
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () => AdaptiveSnackBar.show(
                              context,
                              message: 'Demo preview only • No image exported',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          widget.receive ? 'Receive money' : 'Scan & pay',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          widget.receive
              ? 'Your personal payment card, in dollars or riel.'
              : 'Point your camera at a merchant’s QR code.',
        ),
        const SizedBox(height: 24),
        if (!widget.receive) ...[
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF201A1C),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  const Text(
                    'KHQR • SCANNER PREVIEW',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFFF626D),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: FractionallySizedBox(
                              widthFactor: .65,
                              heightFactor: .65,
                              child: FittedBox(
                                child: Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Align QR code within the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Simulator preview • Camera is not connected',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: 'Simulate QR scan',
            icon: Icons.qr_code_scanner,
            onPressed: () => context.push('/qr-payment'),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => flash = !flash),
                icon: Icon(flash ? Icons.flash_on : Icons.flash_off),
                label: Text(flash ? 'Flash preview on' : 'Flash preview off'),
              ),
              TextButton.icon(
                onPressed: () => context.push('/my-qr'),
                icon: const Icon(Icons.qr_code_2),
                label: const Text('My QR'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        const Text(
          'Khmer Bank • Fictional payment demo',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

class _ReceiveCard extends StatelessWidget {
  const _ReceiveCard({this.amount});
  final String? amount;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Decorative KHQR demo. Not valid for payment.',
    child: Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipPath(
            clipper: const _HeaderClipper(),
            child: Container(
              height: 80,
              color: const Color(0xFFEF1016),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 12),
              child: const Text(
                'KHQR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alex Morgan',
                  style: TextStyle(color: Color(0xFF333333), fontSize: 14),
                ),
                Text(
                  amount ?? '0.00',
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned.fill(
                        child: FittedBox(
                          child: Icon(Icons.qr_code_2, color: Colors.black),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF1016),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.account_balance_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'DEMO • NOT VALID FOR PAYMENT',
                    style: TextStyle(fontSize: 8, color: Colors.black38),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _HeaderClipper extends CustomClipper<Path> {
  const _HeaderClipper();
  @override
  Path getClip(Size size) => Path()
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(size.width - 30, size.height - 26)
    ..lineTo(0, size.height - 26)
    ..close();
  @override
  bool shouldReclip(_HeaderClipper oldClipper) => false;
}

class _SetAmountSheet extends StatefulWidget {
  const _SetAmountSheet({
    required this.initialAmount,
    required this.initialAccountId,
    required this.currencies,
  });
  final String initialAmount, initialAccountId;
  final Map<String, String> currencies;

  @override
  State<_SetAmountSheet> createState() => _SetAmountSheetState();
}

class _SetAmountSheetState extends State<_SetAmountSheet> {
  late String input = widget.initialAmount;
  late String accountId = widget.initialAccountId;
  double? operand;
  String? operation;
  bool replace = false;
  String? error;

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
    double? height,
  }) => Expanded(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: height ?? 56,
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

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    bottom: false,
    child: SingleChildScrollView(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: ColoredBox(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF555555),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 30),
              const Icon(
                Icons.monetization_on_outlined,
                size: 70,
                color: Color(0xFFCECECE),
              ),
              const SizedBox(height: 18),
              const Text(
                'Set Amount',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
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
                      child: Semantics(
                        label: 'Amount',
                        value: input.isEmpty ? '0' : input,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            input.isEmpty ? '0' : input,
                            style: const TextStyle(
                              fontSize: 36,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 42,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      color: Colors.grey,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: accountId,
                          isDense: true,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                          items: [
                            for (final entry in widget.currencies.entries)
                              DropdownMenuItem(
                                value: entry.key,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: entry.value == 'USD'
                                        ? const Color(0xFFB3A600)
                                        : const Color(0xFFD51025),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => accountId = value!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),
              Container(
                color: const Color(0xFFF2F2F2),
                padding: const EdgeInsets.all(24),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5C13), Color(0xFFFFAC08)],
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(47),
                    ),
                    icon: const Icon(
                      Icons.qr_code_2,
                      color: Color(0xFFD51025),
                      size: 27,
                    ),
                    label: const Text(
                      'Generate KHQR',
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      final value = double.tryParse(input);
                      if (value == null || !value.isFinite || value <= 0) {
                        setState(
                          () => error = 'Enter an amount greater than zero',
                        );
                        return;
                      }
                      Navigator.pop(context, (
                        amount: input,
                        accountId: accountId,
                      ));
                    },
                  ),
                ),
              ),
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
                        tooltip: 'Close amount input',
                        onPressed: () => Navigator.pop(context),
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
    ),
  );
}

class _ReceiveAccountSheet extends StatelessWidget {
  const _ReceiveAccountSheet({
    required this.accounts,
    required this.selectedId,
    required this.defaultId,
  });
  final List<BankAccount> accounts;
  final String selectedId, defaultId;

  @override
  Widget build(BuildContext context) {
    final activeId = accounts.any((a) => a.id == selectedId)
        ? selectedId
        : defaultId;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .8,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Material(
          color: const Color(0xFFF2F2F2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF555555),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 22, 16, 12),
                      child: Text(
                        'Select account to receive:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    24,
                    12,
                    MediaQuery.paddingOf(context).bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final account in accounts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Semantics(
                            selected: account.id == activeId,
                            button: true,
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => Navigator.pop(context, account.id),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    12,
                                    14,
                                    12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: [
                                                if (account.id == defaultId)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFFF8314,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            3,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'Default',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                Text(
                                                  account.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF444444),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              spacing: 12,
                                              children: [
                                                Text(
                                                  account.number,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF444444),
                                                  ),
                                                ),
                                                const Text(
                                                  '|',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        account.currency ==
                                                            'USD'
                                                        ? const Color(
                                                            0xFFB3A600,
                                                          )
                                                        : const Color(
                                                            0xFFD51025,
                                                          ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          3,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    account.currency,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        account.id == activeId
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        size: 21,
                                        color: account.id == activeId
                                            ? const Color(0xFFFF7412)
                                            : const Color(0xFFB8B8B8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
