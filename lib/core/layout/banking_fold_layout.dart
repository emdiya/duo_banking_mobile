import 'package:flutter/material.dart';
import 'package:foldable/foldable.dart';
import 'banking_pane_geometry.dart';

class BankingFoldLayout extends StatelessWidget {
  const BankingFoldLayout({super.key, required this.primary, this.companion});
  final Widget primary;
  final Widget? companion;

  @override
  Widget build(BuildContext context) => FoldAwareBuilder(
    builder: (context, constraints, fold) {
      final panes = bankingPanes(
        size: constraints.biggest,
        regularWidth: companion != null && fold.isRegularWidth,
        allowWidthFallback:
            companion != null &&
            fold.horizontalSizeClass == SizeClass.unspecified,
        division: fold.spansDivision ? fold.divisionRect : null,
        occlusions: fold.occlusionRects,
      );
      // Keep the navigator at a stable keyed position across fold/size changes.
      // Only its bounds change, preserving forms, tab stacks and scroll state.
      return Stack(
        children: [
          Positioned.fromRect(
            key: const ValueKey('banking-primary-pane'),
            rect: panes.primary,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: primary,
              ),
            ),
          ),
          if (panes.secondary != null && companion != null)
            Positioned.fromRect(
              key: const ValueKey('banking-companion-pane'),
              rect: panes.secondary!,
              child: companion!,
            ),
        ],
      );
    },
  );
}
