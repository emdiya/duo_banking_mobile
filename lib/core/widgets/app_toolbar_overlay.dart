import 'package:flutter/widgets.dart';

/// Gives toolbar widgets hosted above the Navigator an overlay for tooltips
/// and popup menus. The Navigator retains its own route overlay below this.
class AppToolbarOverlay extends StatelessWidget {
  const AppToolbarOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Overlay.wrap(child: child);
}
