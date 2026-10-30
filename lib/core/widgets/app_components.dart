import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'adaptive_controls.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
  });
  final String label;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    obscureText: obscureText,
    keyboardType: keyboardType,
    decoration: InputDecoration(labelText: label),
  );
}

class AppCurrencyInput extends StatelessWidget {
  const AppCurrencyInput({
    super.key,
    required this.currency,
    this.controller,
    this.validator,
  });
  final String currency;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: 'Amount', prefixText: '$currency  '),
  );
}

class AppCurrencySelector extends StatelessWidget {
  const AppCurrencySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => AppAdaptiveSegments<String>(
    values: const ['USD', 'KHR'],
    labels: const ['USD', 'KHR'],
    value: value,
    onChanged: onChanged,
  );
}

class AppBalanceDisplay extends StatelessWidget {
  const AppBalanceDisplay({
    super.key,
    required this.balance,
    required this.hidden,
  });
  final String balance;
  final bool hidden;
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200),
    child: Text(
      hidden ? '••••••' : balance,
      key: ValueKey(hidden),
      style: Theme.of(context).textTheme.headlineLarge,
    ),
  );
}

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.loading,
    required this.child,
  });
  final bool loading;
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      if (loading)
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
    ],
  );
}

class AppShimmerCard extends StatelessWidget {
  const AppShimmerCard({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading account',
    child: AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16,
              width: 100,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 24),
            const LinearProgressIndicator(),
            const SizedBox(height: 24),
            Container(
              height: 24,
              width: 160,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    ),
  );
}

class AppConfirmationDialog extends StatelessWidget {
  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
  });
  final String title, message;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Confirm'),
      ),
    ],
  );
}

class AppSuccessAnimation extends StatelessWidget {
  const AppSuccessAnimation({super.key});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(
      begin: MediaQuery.disableAnimationsOf(context) ? 1 : .6,
      end: 1,
    ),
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutBack,
    builder: (_, value, child) => Transform.scale(scale: value, child: child),
    child: const Icon(Icons.check_circle, size: 96, color: Color(0xFF16A34A)),
  );
}
