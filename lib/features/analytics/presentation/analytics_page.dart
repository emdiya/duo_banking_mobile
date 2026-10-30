import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../../../core/widgets/adaptive_controls.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/banking_widgets.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool monthly = true;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'Your money, in perspective.',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 24),
      AppAdaptiveSegments<bool>(
        values: const [false, true],
        labels: const ['Weekly', 'Monthly'],
        value: monthly,
        onChanged: (value) => setState(() => monthly = value),
      ),
      const SizedBox(height: 24),
      AdaptiveCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total spending'),
              Text(
                monthly ? '\$1,284.50' : '\$312.25',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration:
                                    MediaQuery.disableAnimationsOf(context)
                                    ? Duration.zero
                                    : const Duration(milliseconds: 350),
                                height:
                                    (monthly
                                            ? [65, 100, 80, 140, 115, 160, 90]
                                            : [
                                                100,
                                                60,
                                                120,
                                                80,
                                                150,
                                                95,
                                                70,
                                              ])[i]
                                        .toDouble(),
                                decoration: BoxDecoration(
                                  color: i == 5
                                      ? const Color(0xFFD71920)
                                      : const Color(0xFFF7CED3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i]),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      const AppSectionHeader('Cash flow'),
      const ListTile(
        leading: Icon(Icons.south_west, color: Colors.green),
        title: Text('Income'),
        trailing: Text('\$2,450.00'),
      ),
      const ListTile(
        leading: Icon(Icons.north_east),
        title: Text('Expenses'),
        trailing: Text('\$1,284.50'),
      ),
      const SizedBox(height: 24),
      const AppSectionHeader('By category'),
      for (final row in [
        ('Shopping', .38),
        ('Food & coffee', .27),
        ('Transport', .20),
        ('Bills & utilities', .15),
      ])
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  Text(row.$1),
                  const Spacer(),
                  Text('${(row.$2 * 100).round()}%'),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: row.$2,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
    ],
  );
}
