import 'core/storage/session_store.dart';
import 'shared/bloc/banking_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionStore = SessionStore();
  bool signedIn;
  try {
    signedIn = await sessionStore.restore();
  } catch (_) {
    signedIn = false;
  }
  runApp(
    BlocProvider(
      create: (_) =>
          BankingCubit(sessionStore: sessionStore, signedIn: signedIn),
      child: const KhmerBankApp(),
    ),
  );
}
