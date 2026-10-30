import '../../features/support/presentation/support_center_page.dart';
import '../../features/qr_payment/presentation/qr_payment_page.dart';
import '../../features/mini_apps/presentation/mini_apps_page.dart';
import '../../features/payments/presentation/all_payments_page.dart';
import '../../features/payments/presentation/payments_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../core/layout/banking_fold_layout.dart';
import '../../core/widgets/banking_companion.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/bloc/banking_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/accounts/presentation/accounts_page.dart';
import '../../features/transactions/presentation/transactions_page.dart';
import '../../features/transfers/presentation/transfer_page.dart';
import '../../features/auth/presentation/auth_page.dart';
import '../../features/profile/presentation/profile_pages.dart';
import '../../features/cards/presentation/cards_page.dart';
import '../../features/qr_payment/presentation/qr_page.dart';
import '../../features/analytics/presentation/analytics_page.dart';
import '../../core/widgets/demo_form_page.dart';
import '../localization/strings.dart';

GoRouter createRouter({String initialLocation = '/splash'}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
    for (final mode in ['login', 'register', 'otp', 'forgot', 'reset'])
      GoRoute(
        path: '/$mode',
        builder: (_, _) => AuthPage(mode: mode),
      ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => BankingShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/home', builder: (_, _) => const HomePage())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/accounts', builder: (_, _) => const AccountsPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/scan', builder: (_, _) => const QrPage())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/cards', builder: (_, _) => const CardsPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
          ],
        ),
      ],
    ),
    for (final entry in <String, Widget>{
      '/new-account': const DemoFormPage(
        title: 'New Account',
        fields: ['Account name', 'Currency'],
      ),
      '/support': const SupportCenterPage(),
      '/loans': const DemoFormPage(
        title: 'Loan inquiry',
        fields: ['Loan amount', 'Phone number'],
      ),
      '/exchange-rate': const DemoFormPage(
        title: 'Exchange currency',
        fields: ['Amount'],
      ),
      '/auto-pay': const DemoFormPage(
        title: 'Set up Auto-Pay',
        fields: ['Payee', 'Amount'],
      ),
      '/transactions': const TransactionsPage(),
      '/transfer': const TransferPage(),
      '/transfer-failure': const TransferResultPage(),
      '/my-qr': const QrPage(receive: true),
      '/card-details': const CardsPage(details: true),
      '/settings': const SettingsPage(),
      '/security': const SecurityPage(),
      '/notifications': const NotificationsPage(),
      '/analytics': const AnalyticsPage(),
      '/showcase': const ShowcasePage(),
      '/top-up': const DemoFormPage(
        title: 'Mobile top-up',
        fields: ['Phone number', 'Amount'],
      ),
      '/bills': const PaymentsPage(),
      '/mini-apps': const MiniAppsPage(),
      '/qr-payment': const QrPaymentPage(),
      '/edit-profile': const DemoFormPage(
        title: 'Edit profile',
        fields: ['Full name', 'Phone number', 'Email address'],
      ),
      '/change-pin': const DemoFormPage(
        title: 'Change demo PIN',
        fields: ['Current PIN', 'New PIN', 'Confirm PIN'],
      ),
    }.entries)
      GoRoute(
        path: entry.key,
        builder: (context, _) =>
            (entry.key == '/my-qr' ||
                entry.key == '/bills' ||
                entry.key == '/mini-apps' ||
                entry.key == '/qr-payment' ||
                entry.key == '/support')
            ? entry.value
            : DetailShell(child: entry.value),
      ),
    GoRoute(
      path: '/payments-all',
      builder: (_, state) =>
          AllPaymentsPage(category: state.uri.queryParameters['category']),
    ),
    GoRoute(
      path: '/bill-payment',
      builder: (_, state) => DetailShell(
        child: DemoFormPage(
          title: state.extra is String ? state.extra as String : 'Pay a bill',
          fields: const ['Provider', 'Customer reference', 'Amount'],
        ),
      ),
    ),
    GoRoute(
      path: '/account/:id',
      builder: (_, state) =>
          DetailShell(child: AccountsPage(id: state.pathParameters['id'])),
    ),
    GoRoute(
      path: '/transaction/:id',
      builder: (_, state) =>
          DetailShell(child: TransactionsPage(id: state.pathParameters['id'])),
    ),
    GoRoute(
      path: '/transfer-success/:id',
      builder: (_, state) => DetailShell(
        child: TransferResultPage(id: state.pathParameters['id']),
      ),
    ),
  ],
);

String _detailTitle(BuildContext context) {
  final path = GoRouterState.of(context).uri.path;
  if (path.startsWith('/account/')) return 'Account details';
  if (path.startsWith('/transaction/')) return 'Transaction details';
  if (path.startsWith('/transfer-success/')) return 'Transfer complete';
  return const {
        '/new-account': 'New Account',
        '/support': 'Support',
        '/loans': 'Loans',
        '/exchange-rate': 'Exchange Rate',
        '/auto-pay': 'Auto-Pay',
        '/transactions': 'Transactions',
        '/transfer': 'Transfer',
        '/transfer-failure': 'Transfer unsuccessful',
        '/my-qr': 'My QR',
        '/card-details': 'Card details',
        '/settings': 'Settings',
        '/security': 'Security',
        '/notifications': 'Notifications',
        '/analytics': 'Spending insights',
        '/showcase': 'UI showcase',
        '/top-up': 'Mobile top-up',
        '/bills': 'Payments',
        '/bill-payment': 'Pay a bill',
        '/qr-payment': 'QR payment',
        '/edit-profile': 'Edit profile',
        '/change-pin': 'Change PIN',
      }[path] ??
      'Khmer Bank';
}

class DetailShell extends StatelessWidget {
  const DetailShell({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => AdaptiveScaffold(
    appBar: AdaptiveAppBar(
      title: tr(context, _detailTitle(context)),
      useNativeToolbar: true,
      leading: context.canPop()
          ? null
          : IconButton(
              tooltip: tr(context, 'Home'),
              icon: const Icon(Icons.home_outlined),
              onPressed: () => context.go('/home'),
            ),
    ),
    body: SafeArea(
      child: BankingFoldLayout(
        primary: child,
        companion: const BankingCompanion(),
      ),
    ),
  );
}

class BankingShell extends StatelessWidget {
  const BankingShell({super.key, required this.shell});
  final StatefulNavigationShell shell;
  static const tabs = [
    (Icons.home_outlined, Icons.home_rounded, 'house', 'house.fill', 'Home'),
    (
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet,
      'wallet.pass',
      'wallet.pass.fill',
      'Accounts',
    ),
    (
      Icons.qr_code_scanner,
      Icons.qr_code_scanner,
      'qrcode.viewfinder',
      'qrcode.viewfinder',
      'Scan QR',
    ),
    (
      Icons.credit_card_outlined,
      Icons.credit_card,
      'creditcard',
      'creditcard.fill',
      'Cards',
    ),
    (
      Icons.person_outline,
      Icons.person,
      'person.crop.circle',
      'person.crop.circle.fill',
      'Profile',
    ),
  ];
  void selectTab(int index) =>
      shell.goBranch(index, initialLocation: index == shell.currentIndex);

  Widget _homeDestination(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool prominent = false,
  }) => Expanded(
    child: InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(prominent ? 15 : 8),
            decoration: prominent
                ? const BoxDecoration(
                    color: Color(0xFFD51D2B),
                    shape: BoxShape.circle,
                  )
                : null,
            child: Icon(
              icon,
              size: 25,
              color: prominent
                  ? Colors.white
                  : label == 'Home'
                  ? Colors.black
                  : Colors.grey,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: label == 'Home' ? FontWeight.w600 : FontWeight.normal,
              color: label == 'Support' ? Colors.grey : Colors.black,
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (!PlatformInfo.isIOS && shell.currentIndex == 1) {
      return Scaffold(
        body: BankingFoldLayout(
          primary: shell,
          companion: const BankingCompanion(),
        ),
      );
    }
    if (!PlatformInfo.isIOS && shell.currentIndex == 0) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BankingFoldLayout(
            primary: shell,
            companion: const BankingCompanion(),
          ),
        ),
        bottomNavigationBar: keyboardVisible
            ? null
            : SafeArea(
                top: false,
                child: SizedBox(
                  height: 88,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _homeDestination(
                        context,
                        Icons.home_outlined,
                        'Home',
                        () => selectTab(0),
                      ),
                      _homeDestination(
                        context,
                        Icons.qr_code_scanner,
                        'QR Scan',
                        () => selectTab(2),
                        prominent: true,
                      ),
                      _homeDestination(
                        context,
                        Icons.help_outline,
                        'Support',
                        () => context.push('/support'),
                      ),
                    ],
                  ),
                ),
              ),
      );
    }
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: true,
      minimizeBehavior: TabBarMinimizeBehavior.onScrollDown,
      tabBarHidden: keyboardVisible,
      appBar:
          PlatformInfo.isIOS &&
              shell.currentIndex != 0 &&
              shell.currentIndex != 1
          ? AdaptiveAppBar(
              title: tr(context, tabs[shell.currentIndex].$5),
              useNativeToolbar: true,
              actions: [
                AdaptiveAppBarAction(
                  iosSymbol: 'bell',
                  icon: Icons.notifications_outlined,
                  label: tr(context, 'Notifications'),
                  onPressed: () => context.push('/notifications'),
                ),
                AdaptiveAppBarAction(
                  iosSymbol: 'gearshape',
                  icon: Icons.settings_outlined,
                  label: tr(context, 'Settings'),
                  onPressed: () => context.push('/settings'),
                ),
                AdaptiveAppBarAction(
                  iosSymbol: 'ellipsis',
                  icon: Icons.more_horiz,
                  label: tr(context, 'More'),
                  menuItems: [
                    AdaptivePopupMenuItem(
                      label: context.watch<BankingCubit>().state.hidden
                          ? 'Show balance'
                          : 'Hide balance',
                      icon: context.watch<BankingCubit>().state.hidden
                          ? 'eye'
                          : 'eye.slash',
                    ),
                    const AdaptivePopupMenuItem(
                      label: 'UI showcase',
                      icon: 'square.grid.2x2',
                    ),
                  ],
                  onMenuItemSelected: (index, item) {
                    if (index == 0) {
                      context.read<BankingCubit>().visibility();
                    }
                    if (index == 1) {
                      context.push('/showcase');
                    }
                  },
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: BankingFoldLayout(
          primary: shell,
          companion: const BankingCompanion(),
        ),
      ),
      bottomNavigationBar: keyboardVisible
          ? null
          : AdaptiveBottomNavigationBar(
              useNativeBottomBar: true,
              selectedIndex: shell.currentIndex,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              onTap: selectTab,
              items: [
                for (final tab in tabs)
                  AdaptiveNavigationDestination(
                    icon: PlatformInfo.isIOS ? tab.$3 : tab.$1,
                    selectedIcon: PlatformInfo.isIOS ? tab.$4 : tab.$2,
                    label: tr(context, tab.$5),
                  ),
              ],
              // Keep the existing Material 3 navigation on Android.
              bottomNavigationBar: PlatformInfo.isIOS
                  ? null
                  : NavigationBar(
                      selectedIndex: shell.currentIndex,
                      onDestinationSelected: selectTab,
                      destinations: [
                        for (final tab in tabs)
                          NavigationDestination(
                            icon: Icon(tab.$1),
                            selectedIcon: Icon(tab.$2),
                            label: tr(context, tab.$5),
                          ),
                      ],
                    ),
            ),
    );
  }
}
