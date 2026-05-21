import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool  _loading = false;
  String? _error;

  User?   get user    => _user;
  bool    get loading => _loading;
  String? get error   => _error;
  bool    get isLoggedIn => _user != null;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }

  Future<void> initFromStorage() async {
    _setLoading(true);
    try {
      _user = await AuthService.fetchMe();
    } catch (_) {
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true); _setError(null);
    try {
      final result = await AuthService.login(username, password);
      _user = result.user;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> googleLogin(String idToken) async {
    _setLoading(true); _setError(null);
    try {
      final result = await AuthService.googleLogin(idToken);
      _user = result.user;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await StorageService.deleteToken();
    _user = null;
    notifyListeners();
  }
}
