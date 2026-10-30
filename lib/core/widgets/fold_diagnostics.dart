import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:foldable/foldable.dart';

/// Development showcase only. Angle frames never drive banking layout.
class FoldDiagnostics extends StatelessWidget {
  const FoldDiagnostics({super.key});
  @override
  Widget build(BuildContext context) {
    final status = DuoMediaQuery.statusOf(context);
    final width = DuoMediaQuery.horizontalSizeClassOf(context);
    final regions = DuoMediaQuery.regionsOf(context);
    return AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fold diagnostics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text('Posture: ${status.name}'),
            Text('Horizontal size class: ${width.name}'),
            Text(
              'Active reserved regions: ${regions.where((region) => region.isActive).length}',
            ),
            const _LiveAngle(),
            const SizedBox(height: 8),
            const Text(
              'Display-feature bridge: off',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveAngle extends StatefulWidget {
  const _LiveAngle();
  @override
  State<_LiveAngle> createState() => _LiveAngleState();
}

class _LiveAngleState extends State<_LiveAngle> {
  late final Stream<double> angles = Foldable.hingeAngleStream;
  @override
  Widget build(BuildContext context) => StreamBuilder<double>(
    stream: angles,
    builder: (context, snapshot) {
      if (snapshot.hasError) return const Text('Hinge reading unavailable');
      if (snapshot.hasData) {
        return Text('Hinge: ${snapshot.data!.toStringAsFixed(1)}°');
      }
      if (snapshot.connectionState == ConnectionState.done) {
        return const Text('No hinge on this device');
      }
      return const Text('Waiting for hinge reading…');
    },
  );
}
