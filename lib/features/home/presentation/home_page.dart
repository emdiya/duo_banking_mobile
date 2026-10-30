import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/bloc/banking_cubit.dart';
import '../../../core/widgets/banking_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currency = 'KHR';
  String search = '';
  static const services = [
    (Icons.account_balance_wallet_outlined, 'Accounts', '/accounts'),
    (Icons.monetization_on_outlined, 'Loans', '/loans'),
    (Icons.receipt_long_outlined, 'Payments', '/bills'),
    (Icons.credit_card_outlined, 'Cards', '/cards'),
    (Icons.currency_exchange, 'Exchange Rate', '/exchange-rate'),
    (Icons.event_repeat_outlined, 'Auto-Pay', '/auto-pay'),
    (Icons.grid_view_outlined, 'Services', '/mini-apps'),
  ];
  void open(String path) {
    if (['/accounts', '/cards', '/scan'].contains(path)) {
      context.go(path);
    } else {
      context.push(path);
    }
  }

  BoxDecoration panel() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
  );

  Widget service(
    (IconData, String, String) item, {
    bool large = false,
  }) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () => open(item.$3),
        child: Container(
          constraints: BoxConstraints(minHeight: large ? 80 : 84),
          decoration: large
              ? BoxDecoration(
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  borderRadius: BorderRadius.circular(9),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(large ? 0 : 10),
                decoration: large
                    ? null
                    : BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF0F0F0)),
                      ),
                child: Icon(item.$1, size: 23, color: const Color(0xFF657793)),
              ),
              const SizedBox(height: 8),
              Text(
                item.$2,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF222222)),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BankingCubit>().state;
    final balance = state.accounts.fold<double>(
      0,
      (sum, a) =>
          sum +
          (a.currency == currency
              ? a.balance
              : currency == 'KHR'
              ? a.balance * 4100
              : a.balance / 4100),
    );
    final filtered = services
        .where((s) => s.$2.toLowerCase().contains(search.toLowerCase()))
        .toList();
    return ColoredBox(
      color: const Color(0xFFF2F2F2),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _HomeHeader(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 10),
                  decoration: panel(),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: currency,
                                isDense: true,
                                icon: const Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20,
                                  ),
                                ),
                                items: [
                                  for (final c in ['KHR', 'USD'])
                                    DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        'Est. Total Balance ($c)',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF8795A3),
                                        ),
                                      ),
                                    ),
                                ],
                                onChanged: (value) =>
                                    setState(() => currency = value!),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  currency == 'USD'
                                      ? Icons.paid_outlined
                                      : Icons.monetization_on_outlined,
                                  color: const Color(0xFF657793),
                                  size: 25,
                                ),
                                const SizedBox(width: 9),
                                Flexible(
                                  child: Text(
                                    state.hidden
                                        ? '••••••'
                                        : NumberFormat(
                                            '#,##0.00',
                                          ).format(balance),
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF222222),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: state.hidden ? 'Show balance' : 'Hide balance',
                        onPressed: context.read<BankingCubit>().visibility,
                        icon: Icon(
                          state.hidden
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 22,
                          color: const Color(0xFF657793),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final action in [
                      (
                        Icons.south_west,
                        'Receive',
                        '/my-qr',
                        const Color(0xFF00C76A),
                      ),
                      (
                        Icons.north_east,
                        'Transfer',
                        '/transfer',
                        const Color(0xFFFF2544),
                      ),
                    ]) ...[
                      if (action.$2 == 'Transfer') const SizedBox(width: 12),
                      Expanded(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF333333),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          onPressed: () => open(action.$3),
                          icon: Icon(action.$1, color: action.$4, size: 25),
                          label: Text(
                            action.$2,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(7, 12, 7, 12),
                  decoration: panel(),
                  child: Column(
                    children: [
                      if (search.isEmpty) ...[
                        Row(
                          children: [
                            for (final s in services.take(3))
                              service(s, large: true),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 11),
                          child: Divider(height: 1, color: Color(0xFFF3F3F3)),
                        ),
                        Row(
                          children: [
                            for (final s in services.skip(3)) service(s),
                          ],
                        ),
                        Row(
                          children: [
                            const Spacer(),
                            for (var i = 0; i < 6; i++)
                              Container(
                                width: i == 0 ? 18 : 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: i == 0
                                      ? const Color(0xFF63718A)
                                      : const Color(0xFFF1F1F1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => context.push('/showcase'),
                              child: const Text(
                                'All Products  ›',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF7474FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No matching services'),
                        )
                      else
                        for (final s in filtered)
                          ListTile(
                            leading: Icon(s.$1, color: const Color(0xFF657793)),
                            title: Text(s.$2),
                            onTap: () => open(s.$3),
                          ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: TextField(
                          onChanged: (value) => setState(() => search = value),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search for a service',
                            hintStyle: const TextStyle(
                              color: Color(0xFFCACACA),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFFCACACA),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFEEEEEE),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'News & Promotions',
                  style: TextStyle(fontSize: 13, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 140,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF203A3D),
                        Color(0xFF8B7840),
                        Color(0xFFE7CF8E),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        right: 15,
                        top: 12,
                        child: Icon(
                          Icons.account_balance_outlined,
                          size: 130,
                          color: Color(0x55FFFFFF),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GROW YOUR SAVINGS',
                              style: TextStyle(
                                color: Color(0xFFFFE1A0),
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Build a brighter future.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Explore your savings accounts',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(onTap: () => context.go('/accounts')),
                        ),
                      ),
                      const Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            '●  ●  ━  ●  ●',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
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
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  Widget action(
      BuildContext context, {
        required String label,
        required IconData icon,
        required String path,
        bool prominent = false,
      }) =>
      Tooltip(
        message: label,
        child: Semantics(
          label: label,
          button: true,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: PlatformInfo.isIOS
                  ? AdaptiveButton.icon(
                icon: icon,
                iconColor: prominent
                    ? const Color(0xFFD71920)
                    : const Color(0xFF657793),
                onPressed: () => context.push(path),
                style: prominent
                    ? AdaptiveButtonStyle.tinted
                    : AdaptiveButtonStyle.gray,
                color: const Color(0xFFD71920),
                size: AdaptiveButtonSize.large,
              )
                  : IconButton.filledTonal(
                tooltip: label,
                onPressed: () => context.push(path),
                alignment: Alignment.center,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: prominent
                      ? const Color(0xFFFCE9EB)
                      : const Color(0xFFF3F5F7),
                  foregroundColor: prominent
                      ? const Color(0xFFD71920)
                      : const Color(0xFF657793),
                ),
                icon: Icon(icon, size: 23),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEBEDF0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_rounded,
                size: 16,
                color: Color(0xFFD71920),
              ),
              SizedBox(width: 7),
              Text(
                'KHMER BANK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: Color(0xFFAE1018),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Tooltip(
                message: 'Your profile',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => context.go('/profile'),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: AppProfileAvatar(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF657793),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Alex Morgan',
                      style: TextStyle(
                        fontSize: 19,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.4,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              action(
                context,
                label: 'Notifications',
                icon: Icons.notifications_outlined,
                path: '/notifications',
              ),
              const SizedBox(width: 8),
              action(
                context,
                label: 'My QR',
                icon: Icons.qr_code_2,
                path: '/my-qr',
                prominent: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
