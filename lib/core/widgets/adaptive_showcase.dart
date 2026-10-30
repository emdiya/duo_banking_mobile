import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'adaptive_controls.dart';

/// Exercises adaptive controls without changing banking data.
class AdaptiveControlsShowcase extends StatefulWidget {
  const AdaptiveControlsShowcase({super.key});
  @override
  State<AdaptiveControlsShowcase> createState() =>
      _AdaptiveControlsShowcaseState();
}

class _AdaptiveControlsShowcaseState extends State<AdaptiveControlsShowcase> {
  bool enabled = true;
  double limit = .5;
  String currency = 'USD';
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Platform controls', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(
        PlatformInfo.isIOS
            ? 'Native on iOS 26+, Cupertino on earlier iOS.'
            : 'Material controls on this platform.',
      ),
      const SizedBox(height: 16),
      AppAdaptiveSegments<String>(
        values: const ['USD', 'KHR'],
        labels: const ['USD', 'KHR'],
        value: currency,
        onChanged: (value) => setState(() => currency = value),
      ),
      const SizedBox(height: 16),
      AppAdaptiveSwitchTile(
        title: const Text('Notifications preview'),
        value: enabled,
        onChanged: (value) => setState(() => enabled = value),
      ),
      Text('Spending limit preview: ${(limit * 100).round()}%'),
      AppAdaptiveSlider(
        value: limit,
        divisions: 10,
        onChanged: (value) => setState(() => limit = value),
      ),
      const SizedBox(height: 16),
      for (final style in [
        AdaptiveButtonStyle.filled,
        AdaptiveButtonStyle.tinted,
        AdaptiveButtonStyle.gray,
        AdaptiveButtonStyle.bordered,
        AdaptiveButtonStyle.plain,
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AdaptiveButton(
            label: '${style.name} button',
            style: style,
            size: AdaptiveButtonSize.large,
            onPressed: () => AdaptiveSnackBar.show(
              context,
              message: '${style.name} button pressed',
            ),
          ),
        ),
      const AdaptiveButton(
        label: 'Disabled native button',
        onPressed: null,
        enabled: false,
      ),
      const SizedBox(height: 24),
    ],
  );
}
