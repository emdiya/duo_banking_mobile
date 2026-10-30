import 'fold_diagnostics.dart';
import 'adaptive_showcase.dart';
import 'package:flutter/material.dart';
import 'banking_widgets.dart';

class DemoFormPage extends StatefulWidget {
  const DemoFormPage({super.key, required this.title, required this.fields});
  final String title;
  final List<String> fields;
  @override
  State<DemoFormPage> createState() => _DemoFormPageState();
}

class _DemoFormPageState extends State<DemoFormPage> {
  final form = GlobalKey<FormState>();
  bool success = false;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(widget.title, style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 12),
      const Text('Safe demo • No real payment or profile changes'),
      const SizedBox(height: 28),
      if (success)
        const AppEmptyState(message: 'Demo request completed successfully')
      else
        Form(
          key: form,
          child: Column(
            children: [
              for (final field in widget.fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: field),
                    obscureText: field.contains('PIN'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'This field is required'
                        : field == 'Amount' &&
                              (double.tryParse(v) == null ||
                                  !double.parse(v).isFinite ||
                                  double.parse(v) <= 0)
                        ? 'Enter a valid amount'
                        : null,
                  ),
                ),
              AppPrimaryButton(
                label: 'Confirm demo request',
                onPressed: () {
                  if (form.currentState!.validate()) {
                    setState(() => success = true);
                  }
                },
              ),
            ],
          ),
        ),
    ],
  );
}

class ShowcasePage extends StatelessWidget {
  const ShowcasePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const AppSectionHeader('UI showcase'),
      const SizedBox(height: 24),
      const AdaptiveControlsShowcase(),
      const FoldDiagnostics(),
      const SizedBox(height: 24),
      const SizedBox(height: 16),
      AppPrimaryButton(label: 'Primary action', onPressed: () {}),
      const SizedBox(height: 16),
      const AppPrimaryButton(label: 'Disabled action', onPressed: null),
      const SizedBox(height: 24),
      const TextField(
        decoration: InputDecoration(
          labelText: 'Text input',
          helperText: 'Helpful supporting text',
        ),
      ),
      const SizedBox(height: 24),
      const AppProfileAvatar(),
      const SizedBox(height: 24),
      const LinearProgressIndicator(),
      const AppEmptyState(),
      AppErrorState(onRetry: () {}),
      const SizedBox(height: 24),
      const Text('Confirmation dialog'),
      TextButton(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm demo action?'),
            content: const Text('Preview of a reusable confirmation pattern.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ),
        child: const Text('Open dialog'),
      ),
    ],
  );
}
