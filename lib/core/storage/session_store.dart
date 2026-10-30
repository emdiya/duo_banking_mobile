import 'package:shared_preferences/shared_preferences.dart';

/// Persists only the demo sign-in flag, never credentials or banking data.
class SessionStore {
  static const sessionKey = 'demo_session_signed_in';

  Future<bool> restore() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(sessionKey) ?? false;
  }

  Future<void> save({required bool remember}) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = remember
        ? await preferences.setBool(sessionKey, true)
        : await preferences.remove(sessionKey);
    if (!saved) throw StateError('Unable to save session');
  }

  Future<void> clear() => save(remember: false);
}
