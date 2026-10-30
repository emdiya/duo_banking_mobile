import 'package:duo_banking_lab/core/widgets/app_toolbar_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('hosted toolbar supports tooltips, menus and rebuilds', (
    tester,
  ) async {
    Widget app(String label) => MaterialApp(
      builder: (context, navigator) => AppToolbarOverlay(
        child: Material(
          child: Column(
            children: [
              IconButton(
                tooltip: label,
                onPressed: () {},
                icon: const Icon(Icons.arrow_back),
              ),
              PopupMenuButton<String>(
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'settings',
                    child: Text('Settings'),
                  ),
                ],
              ),
              Expanded(child: navigator!),
            ],
          ),
        ),
      ),
      home: const Scaffold(body: Text('Page content')),
    );

    await tester.pumpWidget(app('Back to home'));
    expect(tester.takeException(), isNull);
    await tester.longPress(find.byTooltip('Back to home'));
    await tester.pumpAndSettle();
    expect(find.text('Back to home'), findsOneWidget);
    await tester.pumpWidget(app('Updated back label'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Updated back label'), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
