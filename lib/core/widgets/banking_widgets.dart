import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import '../../shared/models/banking.dart';
import '../../app/localization/strings.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = (MediaQuery.textScalerOf(context).scale(18) + 32)
          .clamp(54.0, double.infinity)
          .toDouble();
      final width = constraints.hasBoundedWidth ? constraints.maxWidth : 200.0;
      return SizedBox(
        width: width,
        child: PlatformInfo.isIOS
            ? SizedBox(
                height: height,
                child: AdaptiveButton(
                  label: tr(context, label),
                  onPressed: onPressed,
                  enabled: onPressed != null,
                  style: AdaptiveButtonStyle.filled,
                  size: AdaptiveButtonSize.large,
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  minSize: Size(width, height),
                  borderRadius: BorderRadius.circular(16),
                ),
              )
            : FilledButton.icon(
                onPressed: onPressed,
                icon: icon == null ? const SizedBox.shrink() : Icon(icon),
                label: Text(tr(context, label)),
              ),
      );
    },
  );
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader(this.title, {super.key, this.onTap});
  final String title;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          tr(context, title),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      if (onTap != null)
        TextButton(onPressed: onTap, child: Text(tr(context, 'See all'))),
    ],
  );
}

class AppAccountCard extends StatelessWidget {
  const AppAccountCard({
    super.key,
    required this.account,
    this.hidden = false,
    this.onTap,
  });
  final BankAccount account;
  final bool hidden;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '${account.currency} account',
    child: GestureDetector(
      onTap: onTap,
      child: AdaptiveCard(
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        elevation: 0,
        borderWidth: 0,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: account.currency == 'KHR'
                  ? [const Color(0xFFBE1520), const Color(0xFFE53942)]
                  : [
                      const Color(0xFFD71920),
                      const Color(0xFFAE1018),
                      const Color(0xFF810B12),
                    ],
            ),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.account_balance_rounded,
                      color: Color(0xFFFFE0E2),
                      size: 26,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'KHMER BANK',
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Icons.contactless_outlined, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${account.currency} • ${account.id == 'current' ? 'CURRENT' : 'SAVINGS'}',
                  style: const TextStyle(
                    color: Color(0xFFFFE0E2),
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  tr(context, 'Available balance'),
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  child: Text(
                    hidden ? '••••••' : account.formatted,
                    key: ValueKey(hidden),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.8,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Text(
                      account.name,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Text('••••  7890'),
                    const Icon(
                      Icons.contactless_outlined,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class AppTransactionTile extends StatelessWidget {
  const AppTransactionTile({super.key, required this.transaction, this.onTap});
  final BankTransaction transaction;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final incoming = transaction.amount >= 0;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      onTap: onTap,
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: incoming
              ? const Color(0xFFE4F7EF)
              : Theme.of(context).colorScheme.primary.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          incoming
              ? Icons.south_west
              : transaction.category == 'QR payment'
              ? Icons.coffee_outlined
              : Icons.north_east,
          color: incoming
              ? const Color(0xFF16805A)
              : Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        transaction.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(transaction.category),
      trailing: Text(
        transaction.formatted,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: incoming ? const Color(0xFF16A34A) : null,
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({super.key, this.message = 'No activity yet'});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(40),
    child: Column(
      children: [
        const Icon(Icons.inbox_outlined, size: 48),
        const SizedBox(height: 16),
        Text(message),
      ],
    ),
  );
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Text('Something went wrong'),
      TextButton(onPressed: onRetry, child: const Text('Try again')),
    ],
  );
}

class AppProfileAvatar extends StatelessWidget {
  const AppProfileAvatar({super.key});
  @override
  Widget build(BuildContext context) => const CircleAvatar(
    backgroundColor: Color(0xFFFCE9EB),
    foregroundColor: Color(0xFFAE1018),
    child: Text('AM', style: TextStyle(fontWeight: FontWeight.w700)),
  );
}
