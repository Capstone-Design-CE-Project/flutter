import 'package:flutter/foundation.dart';

abstract interface class AuthenticationState {
  bool get isAuthenticated;
}

class AuthSession extends ChangeNotifier implements AuthenticationState {
  bool _isAuthenticated = false;

  @override
  bool get isAuthenticated => _isAuthenticated;

  void signIn() {
    if (_isAuthenticated) return;
    _isAuthenticated = true;
    notifyListeners();
  }

  void signOut() {
    if (!_isAuthenticated) return;
    _isAuthenticated = false;
    notifyListeners();
  }
}
