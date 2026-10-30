import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../../../core/widgets/adaptive_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/bloc/banking_cubit.dart';
import '../../../core/widgets/banking_widgets.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key, this.details = false});
  final bool details;
  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  bool visible = false;
  double limit = 2000;
  @override
  Widget build(BuildContext context) {
    final state = context.watch<BankingCubit>().state;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          widget.details ? 'Card details' : 'Your everyday companion.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        const Text('Virtual by design. Fictional by nature.'),
        const SizedBox(height: 28),
        AdaptiveCard(
          margin: EdgeInsets.zero,
          color: Colors.transparent,
          elevation: 0,
          borderWidth: 0,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF65141F), Color(0xFFA81C2D)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'KHMER BANK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'VIRTUAL • DEMO',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Icon(Icons.memory, color: Color(0xFFDCC493), size: 36),
                const SizedBox(height: 24),
                Text(
                  visible ? '0000 0000 0000 7890' : '••••  ••••  ••••  7890',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ALEX MORGAN',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    Text('12/29', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        AppAdaptiveSwitchTile(
          title: const Text('Freeze card'),
          subtitle: Text(
            state.frozen
                ? 'Your demo card is frozen'
                : 'Your demo card is active',
          ),
          value: state.frozen,
          onChanged: context.read<BankingCubit>().freeze,
        ),
        if (widget.details) ...[
          AppAdaptiveSwitchTile(
            title: const Text('Show fictional details'),
            value: visible,
            onChanged: (v) => setState(() => visible = v),
          ),
          const SizedBox(height: 20),
          Text('Monthly limit: \$${limit.toStringAsFixed(0)}'),
          AppAdaptiveSlider(
            value: limit,
            min: 100,
            max: 5000,
            divisions: 49,
            onChanged: (v) => setState(() => limit = v),
          ),
          const AppSectionHeader('Card activity'),
          for (final t in state.transactions.take(5))
            AppTransactionTile(transaction: t),
        ] else
          AppPrimaryButton(
            label: 'View card details',
            onPressed: () => context.push('/card-details'),
          ),
      ],
    );
  }
}
