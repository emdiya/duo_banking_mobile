import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/bloc/banking_cubit.dart';
import 'login_form.dart';
import '../../../core/layout/banking_fold_layout.dart';
import '../../../app/localization/strings.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/banking_widgets.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.mode = 'login'});
  final String mode;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final form = GlobalKey<FormState>();
  final password = TextEditingController();
  bool hidden = true, remember = true, terms = false, busy = false;
  String? error;
  int seconds = 30;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    if (widget.mode == 'otp') {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && seconds > 0) setState(() => seconds--);
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == 'login') {
      return AdaptiveScaffold(
        resizeToAvoidBottomInset: true,
        appBar: AdaptiveAppBar(
          title: tr(context, 'Login'),
          useNativeToolbar: true,
        ),
        body: SafeArea(
          child: BankingFoldLayout(
            primary: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: LoginForm(
                  onRememberChanged: (value) => remember = value,
                  onLogin: () async {
                    await Future<void>.delayed(
                      const Duration(milliseconds: 400),
                    );
                    if (!context.mounted) return;
                    await context.read<BankingCubit>().signIn(
                      remember: remember,
                    );
                    if (context.mounted) context.go('/home');
                  },
                  onForgot: () => context.push('/forgot'),
                  onRegister: () => context.push('/register'),
                  onBiometric: () => AdaptiveSnackBar.show(
                    context,
                    message:
                        'Biometric demo: sign in with your demo credentials.',
                  ),
                  actionBuilder: (context, busy, submit) => AppPrimaryButton(
                    key: const Key('login-submit'),
                    label: busy ? 'Signing in…' : 'Login',
                    onPressed: busy ? null : submit,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    final register = widget.mode == 'register';
    final otp = widget.mode == 'otp';
    final forgot = widget.mode == 'forgot';
    final reset = widget.mode == 'reset';
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: tr(
          context,
          widget.mode == 'login'
              ? 'Login'
              : widget.mode == 'register'
              ? 'Create account'
              : 'Verification',
        ),
        useNativeToolbar: true,
      ),
      body: SafeArea(
        child: BankingFoldLayout(
          primary: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                padding: const EdgeInsets.all(28),
                children: [
                  const Icon(
                    Icons.account_balance_rounded,
                    size: 56,
                    color: Color(0xFFD71920),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    register
                        ? 'Your next chapter starts here.'
                        : otp
                        ? 'Verify it’s you'
                        : forgot
                        ? 'Let’s get you back in.'
                        : reset
                        ? 'A fresh start'
                        : 'Welcome back',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    otp
                        ? 'Enter the six-digit demo code: 123456'
                        : 'Khmer Bank • Your everyday banking, inspired by Cambodia.',
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: form,
                    child: Column(
                      children: [
                        if (register) ...[
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                            ),
                            validator: requiredField,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v != null && v.contains('@')
                                ? null
                                : 'Enter a valid email',
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (!reset) ...[
                          TextFormField(
                            key: const Key('identity'),
                            decoration: InputDecoration(
                              labelText: otp
                                  ? 'Verification code'
                                  : forgot
                                  ? 'Email or phone number'
                                  : 'Username or phone number',
                            ),
                            keyboardType: otp
                                ? TextInputType.number
                                : TextInputType.text,
                            maxLength: otp ? 6 : null,
                            validator: (v) => otp
                                ? v == '123456'
                                      ? null
                                      : 'Use the demo code 123456'
                                : requiredField(v),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (!otp && !forgot) ...[
                          TextFormField(
                            key: const Key('password'),
                            controller: password,
                            obscureText: hidden,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                tooltip: 'Toggle password visibility',
                                onPressed: () =>
                                    setState(() => hidden = !hidden),
                                icon: Icon(
                                  hidden
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (v) => (v?.length ?? 0) < 6
                                ? 'Use at least 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          if (register || reset)
                            TextFormField(
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Confirm password',
                              ),
                              validator: (v) => v != password.text
                                  ? 'Passwords must match'
                                  : null,
                            ),
                        ],
                        if (register)
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: terms,
                            onChanged: (v) => setState(() => terms = v!),
                            title: const Text(
                              'I agree to the demo terms of use',
                            ),
                          ),
                        if (!register && !otp && !forgot && !reset) ...[
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: remember,
                            onChanged: (v) => setState(() => remember = v!),
                            title: const Text('Remember me'),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot'),
                              child: const Text('Forgot password?'),
                            ),
                          ),
                        ],
                        if (error != null)
                          Text(
                            error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        const SizedBox(height: 20),
                        if (busy)
                          const CircularProgressIndicator()
                        else
                          AppPrimaryButton(
                            label: register
                                ? 'Create account'
                                : otp
                                ? 'Verify'
                                : forgot || reset
                                ? 'Continue'
                                : 'Login',
                            onPressed: () async {
                              if (!form.currentState!.validate()) return;
                              if (register && !terms) {
                                setState(
                                  () => error = 'Please accept the demo terms',
                                );
                                return;
                              }
                              setState(() => busy = true);
                              await Future<void>.delayed(
                                const Duration(milliseconds: 400),
                              );
                              if (!context.mounted) return;
                              final destination = register || forgot
                                  ? '/otp${forgot ? '?reset=true' : ''}'
                                  : otp &&
                                        GoRouterState.of(
                                              context,
                                            ).uri.queryParameters['reset'] ==
                                            'true'
                                  ? '/reset'
                                  : '/home';
                              try {
                                if (destination == '/home') {
                                  await context.read<BankingCubit>().signIn(
                                    remember: remember,
                                  );
                                }
                                if (context.mounted) context.go(destination);
                              } catch (_) {
                                if (mounted) {
                                  setState(() {
                                    busy = false;
                                    error =
                                        'Unable to save session. Please try again.';
                                  });
                                }
                              }
                            },
                          ),
                        if (otp)
                          TextButton(
                            onPressed: seconds == 0
                                ? () => setState(() => seconds = 30)
                                : null,
                            child: Text(
                              seconds == 0
                                  ? 'Resend code'
                                  : 'Resend in ${seconds}s',
                            ),
                          ),
                        if (!register && !otp && !forgot && !reset) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => AdaptiveSnackBar.show(
                              context,
                              message:
                                  'Biometric demo: sign in with your demo credentials.',
                            ),
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Biometric login'),
                          ),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            child: const Text(
                              'New to Khmer Bank? Create an account',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'DEMO ONLY • NO REAL BANKING',
                      style: TextStyle(fontSize: 10, letterSpacing: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? requiredField(String? v) =>
      v == null || v.trim().isEmpty ? 'This field is required' : null;
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        context.go(
          context.read<BankingCubit>().state.signedIn ? '/home' : '/onboarding',
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: Color(0xFFD71920),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_rounded, color: Colors.white, size: 80),
          Text(
            'Khmer Bank',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'CAMBODIA • DEMO BANKING',
            style: TextStyle(color: Colors.white70, letterSpacing: 2),
          ),
          SizedBox(height: 40),
          CircularProgressIndicator(color: Colors.white),
        ],
      ),
    ),
  );
}
