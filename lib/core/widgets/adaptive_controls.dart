import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

/// Shared controls preserve Material 3 behavior off iOS.
class AppAdaptiveSwitchTile extends StatelessWidget {
  const AppAdaptiveSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.contentPadding,
  });
  final Widget title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) => PlatformInfo.isIOS
      ? ListTile(
          contentPadding: contentPadding,
          title: title,
          subtitle: subtitle,
          trailing: AdaptiveSwitch(value: value, onChanged: onChanged),
          onTap: () => onChanged(!value),
        )
      : SwitchListTile(
          contentPadding: contentPadding,
          title: title,
          subtitle: subtitle,
          value: value,
          onChanged: onChanged,
        );
}

class AppAdaptiveSlider extends StatelessWidget {
  const AppAdaptiveSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
  });
  final double value, min, max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => PlatformInfo.isIOS
      ? AdaptiveSlider(
          value: value,
          min: min,
          max: max,
          onChanged: (next) {
            if (divisions == null) {
              onChanged(next);
              return;
            }
            final step = (max - min) / divisions!;
            onChanged(
              (min + ((next - min) / step).round() * step)
                  .clamp(min, max)
                  .toDouble(),
            );
          },
        )
      : Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        );
}

class AppAdaptiveSegments<T> extends StatelessWidget {
  const AppAdaptiveSegments({
    super.key,
    required this.values,
    required this.labels,
    required this.value,
    required this.onChanged,
  }) : assert(values.length == labels.length);
  final List<T> values;
  final List<String> labels;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => PlatformInfo.isIOS
      ? AdaptiveSegmentedControl(
          labels: labels,
          selectedIndex: values.indexOf(value),
          onValueChanged: (index) => onChanged(values[index]),
        )
      : SegmentedButton<T>(
          segments: [
            for (var i = 0; i < values.length; i++)
              ButtonSegment(value: values[i], label: Text(labels[i])),
          ],
          selected: {value},
          onSelectionChanged: (selected) => onChanged(selected.first),
        );
}
