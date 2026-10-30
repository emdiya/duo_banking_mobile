import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

/// Uses the adaptive navigation toolbar on iOS while retaining page actions.
class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    this.appBar,
    this.backgroundColor,
    required this.body,
  });

  final AppBar? appBar;
  final Color? backgroundColor;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final bar = appBar;
    if (!PlatformInfo.isIOS) {
      return Scaffold(
        appBar: bar,
        backgroundColor: backgroundColor,
        body: body,
      );
    }
    return AdaptiveScaffold(
      backgroundColor: backgroundColor,
      appBar: bar == null
          ? null
          : AdaptiveAppBar(
              title: bar.title is Text ? (bar.title as Text).data : null,
              titleWidget: bar.title is Text ? null : bar.title,
              leading: bar.leading,
              useNativeToolbar: true,
              actions: [
                for (final action in bar.actions ?? const <Widget>[])
                  AdaptiveAppBarAction(iconWidget: action),
              ],
            ),
      body: bar?.bottom == null
          ? body
          : Column(
              children: [
                bar!.bottom!,
                Expanded(child: body),
              ],
            ),
    );
  }
}
