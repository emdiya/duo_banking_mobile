import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/strings.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int page = 0;
  static const pages = [
    (
      Icons.account_balance_wallet_outlined,
      'A fresh perspective on your money.',
      'All your accounts. One beautifully simple place.',
    ),
    (
      Icons.qr_code_rounded,
      'Life moves fast. So can your money.',
      'Transfers and QR payments, without the friction.',
    ),
    (
      Icons.shield_outlined,
      'Your peace of mind, built right in.',
      'Explore banking safely with fictional demo data.',
    ),
  ];

  void showPage(int index) =>
      setState(() => page = index.clamp(0, pages.length - 1));
  void login() => context.go('/login');

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final illustrationSize = (constraints.maxHeight * .22)
              .clamp(88.0, 156.0)
              .toDouble();
          final item = pages[page];
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -200) showPage(page + 1);
              if (velocity > 200) showPage(page - 1);
            },
            child: SingleChildScrollView(
              key: const Key('onboarding-scroll'),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: login,
                              child: Text(tr(context, 'Skip')),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 200),
                            child: Column(
                              key: ValueKey(page),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: illustrationSize,
                                  height: illustrationSize,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: .08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item.$1,
                                    size: illustrationSize * .52,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  tr(context, item.$2),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  tr(context, item.$3),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              for (var i = 0; i < pages.length; i++)
                                Semantics(
                                  selected: i == page,
                                  label: '${tr(context, 'Page')} ${i + 1}',
                                  button: true,
                                  child: InkWell(
                                    onTap: () => showPage(i),
                                    borderRadius: BorderRadius.circular(24),
                                    child: SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: Center(
                                        child: AnimatedContainer(
                                          duration:
                                              MediaQuery.disableAnimationsOf(
                                                context,
                                              )
                                              ? Duration.zero
                                              : const Duration(
                                                  milliseconds: 150,
                                                ),
                                          width: i == page ? 24 : 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: i == page
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.outlineVariant,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              key: const Key('onboarding-next'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                              onPressed: page == pages.length - 1
                                  ? login
                                  : () => showPage(page + 1),
                              child: Text(
                                tr(
                                  context,
                                  page == pages.length - 1
                                      ? 'Get started'
                                      : 'Next',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              key: const Key('onboarding-login'),
                              onPressed: login,
                              child: Text(
                                tr(context, 'Login'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
