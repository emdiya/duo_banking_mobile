import 'package:flutter/material.dart';
import '../../../app/localization/strings.dart';

typedef LoginActionBuilder =
    Widget Function(BuildContext context, bool busy, VoidCallback submit);

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.onLogin,
    required this.onForgot,
    required this.onRegister,
    required this.onBiometric,
    this.actionBuilder,
    this.onRememberChanged,
  });
  final Future<void> Function() onLogin;
  final VoidCallback onForgot, onRegister, onBiometric;
  final LoginActionBuilder? actionBuilder;
  final ValueChanged<bool>? onRememberChanged;
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final form = GlobalKey<FormState>();
  final password = TextEditingController();
  bool obscure = true, remember = true, busy = false;
  String? error;

  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy) return;
    FocusScope.of(context).unfocus();
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.onLogin();
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Unable to sign in. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Form(
    key: form,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final fields = <Widget>[
          const Icon(
            Icons.account_balance_rounded,
            size: 36,
            color: Color(0xFFD71920),
          ),
          const SizedBox(height: 16),
          Text(
            tr(context, 'Welcome back'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(tr(context, 'Sign in to Khmer Bank')),
          const SizedBox(height: 24),
          TextFormField(
            key: const Key('identity'),
            enabled: !busy,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: InputDecoration(
              labelText: tr(context, 'Username or phone number'),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'This field is required'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('password'),
            controller: password,
            enabled: !busy,
            obscureText: obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => submit(),
            decoration: InputDecoration(
              labelText: tr(context, 'Password'),
              suffixIcon: IconButton(
                tooltip: 'Toggle password visibility',
                onPressed: () => setState(() => obscure = !obscure),
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) =>
                (value?.length ?? 0) < 6 ? 'Use at least 6 characters' : null,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: remember,
            onChanged: busy
                ? null
                : (value) {
                    setState(() => remember = value!);
                    widget.onRememberChanged?.call(remember);
                  },
            title: Text(tr(context, 'Remember me')),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: busy ? null : widget.onForgot,
              child: Text(tr(context, 'Forgot password?')),
            ),
          ),
          OutlinedButton.icon(
            onPressed: busy ? null : widget.onBiometric,
            icon: const Icon(Icons.fingerprint),
            label: Text(tr(context, 'Biometric login')),
          ),
          TextButton(
            onPressed: busy ? null : widget.onRegister,
            child: Text(tr(context, 'Create account')),
          ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ];
        final action = Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: SizedBox(
            width: double.infinity,
            child:
                widget.actionBuilder?.call(context, busy, submit) ??
                FilledButton(
                  key: const Key('login-submit'),
                  onPressed: busy ? null : submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: Text(tr(context, busy ? 'Signing in…' : 'Login')),
                ),
          ),
        );
        // Keep the CTA above the keyboard; very short windows can scroll everything.
        if (constraints.maxHeight < 220) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: fields,
                  ),
                ),
                action,
              ],
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView(
                key: const Key('login-fields'),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                children: fields,
              ),
            ),
            action,
          ],
        );
      },
    ),
  );
}
