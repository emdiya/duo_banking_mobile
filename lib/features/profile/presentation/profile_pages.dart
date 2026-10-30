import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../../../core/widgets/adaptive_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/bloc/banking_cubit.dart';
import '../../../core/widgets/banking_widgets.dart';
import '../../../app/localization/strings.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        tr(context, 'Profile'),
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 32),
      const Center(child: AppProfileAvatar()),
      const SizedBox(height: 16),
      Center(
        child: Text(
          'Alex Morgan',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      const Center(child: Text('Customer DEMO0001')),
      const SizedBox(height: 24),
      const ListTile(
        leading: Icon(Icons.phone_outlined),
        title: Text('+855 12 000 000'),
      ),
      const ListTile(
        leading: Icon(Icons.mail_outline),
        title: Text('alex@example.com'),
      ),
      for (final item in [
        (Icons.person_outline, 'Edit profile', '/edit-profile'),
        (Icons.settings_outlined, 'Settings', '/settings'),
        (Icons.shield_outlined, 'Security', '/security'),
        (Icons.insights_outlined, 'Spending insights', '/analytics'),
        (Icons.palette_outlined, 'UI showcase', '/showcase'),
      ])
        AdaptiveCard(
          child: ListTile(
            leading: Icon(item.$1),
            title: Text(tr(context, item.$2)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(item.$3),
          ),
        ),
      const SizedBox(height: 24),
      TextButton(
        onPressed: () async {
          try {
            await context.read<BankingCubit>().signOut();
            if (context.mounted) context.go('/login');
          } catch (_) {
            if (context.mounted) {
              AdaptiveSnackBar.show(
                context,
                message: 'Unable to clear session. Please try again.',
              );
            }
          }
        },
        child: Text(tr(context, 'Logout')),
      ),
    ],
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<BankingCubit>().state;
    final controller = context.read<BankingCubit>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          tr(context, 'Settings'),
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 24),
        Text(tr(context, 'Language')),
        const SizedBox(height: 12),
        AppAdaptiveSegments<bool>(
          values: const [false, true],
          labels: const ['English', 'ខ្មែរ'],
          value: state.khmer,
          onChanged: controller.language,
        ),
        const SizedBox(height: 28),
        const Text('Appearance'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(mode.name),
                selected: state.theme == mode,
                onSelected: (_) => controller.theme(mode),
              ),
          ],
        ),
        const SizedBox(height: 24),
        AppAdaptiveSwitchTile(
          contentPadding: EdgeInsets.zero,
          title: Text(tr(context, 'Notifications')),
          value: state.notifications,
          onChanged: controller.notifications,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(tr(context, 'Security')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/security'),
        ),
        const AboutListTile(
          applicationName: 'Khmer Bank',
          applicationVersion: '1.0.0',
          applicationLegalese: 'A fictional banking UI laboratory.',
        ),
      ],
    );
  }
}

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});
  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool biometric = false;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('Security', style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 24),
      AppAdaptiveSwitchTile(
        title: const Text('Biometric simulation'),
        subtitle: const Text('No biometric data is collected'),
        value: biometric,
        onChanged: (v) => setState(() => biometric = v),
      ),
      for (final label in ['Change password', 'Change PIN'])
        ListTile(
          title: Text(label),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(
            label == 'Change password' ? '/reset' : '/change-pin',
          ),
        ),
      const Divider(),
      const ListTile(
        leading: Icon(Icons.phone_iphone),
        title: Text('This device'),
        subtitle: Text('Demo session • Active now'),
      ),
      ListTile(
        title: const Text('End other demo sessions'),
        onTap: () => AdaptiveSnackBar.show(
          context,
          message: 'Other demo sessions ended',
        ),
      ),
    ],
  );
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final read = context.watch<BankingCubit>().state.read;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AppSectionHeader('Notifications'),
        TextButton(
          onPressed: context.read<BankingCubit>().markRead,
          child: const Text('Mark all as read'),
        ),
        for (final item in [
          (
            'Your salary has arrived',
            'A deposit of \$2,450.00 was added to your savings.',
          ),
          ('A safer way to bank', 'Review your demo security preferences.'),
          (
            'Your October overview',
            'Your monthly spending insights are ready.',
          ),
        ])
          AdaptiveCard(
            child: ListTile(
              leading: Icon(
                read
                    ? Icons.notifications_none
                    : Icons.notifications_active_outlined,
              ),
              title: Text(
                item.$1,
                style: TextStyle(
                  fontWeight: read ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(item.$2),
              onTap: context.read<BankingCubit>().markRead,
            ),
          ),
      ],
    );
  }
}
