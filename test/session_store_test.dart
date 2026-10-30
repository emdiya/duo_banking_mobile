import 'package:duo_banking_lab/core/storage/session_store.dart';
import 'package:duo_banking_lab/shared/bloc/banking_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('remembered login survives a new session store', () async {
    final cubit = BankingCubit();
    addTearDown(cubit.close);
    expect(await SessionStore().restore(), isFalse);
    await cubit.signIn(remember: true);
    expect(cubit.state.signedIn, isTrue);
    expect(await SessionStore().restore(), isTrue);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getKeys(), {SessionStore.sessionKey});
  });

  test('unchecked remember removes a previous saved session', () async {
    final cubit = BankingCubit();
    addTearDown(cubit.close);
    await cubit.signIn(remember: true);
    await cubit.signIn(remember: false);
    expect(cubit.state.signedIn, isTrue);
    expect(await SessionStore().restore(), isFalse);
  });

  test('logout clears persisted session and in-memory banking state', () async {
    final cubit = BankingCubit();
    addTearDown(cubit.close);
    await cubit.signIn(remember: true);
    cubit.freeze(true);
    await cubit.signOut();
    expect(cubit.state.signedIn, isFalse);
    expect(cubit.state.frozen, isFalse);
    expect(await SessionStore().restore(), isFalse);
  });
}
