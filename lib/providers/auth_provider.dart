import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  bool _authenticated = false;
  bool get isAuthenticated => _authenticated;

  Future<void> loadSession() async {
    final token = await _secureStorage.read(key: 'pomodorx_token');
    _authenticated = token != null;
    notifyListeners();
  }

  Future<void> login(String pin) async {
    await _secureStorage.write(key: 'pomodorx_token', value: pin);
    _authenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'pomodorx_token');
    _authenticated = false;
    notifyListeners();
  }
}
