import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  List<String> _userRoles = [];

  bool get isAuthenticated => _isAuthenticated;
  List<String> get userRoles => List.from(_userRoles);

  // Load authentication state at startup
  Future<void> loadAuthState() async {
    final token = await _storage.read(key: 'auth_token');
    final userRoles = await _storage.read(key: 'user_roles');
    if (token != null) {
      _isAuthenticated = true;
      _userRoles = userRoles?.split(',') ?? [];
    } else {
      _isAuthenticated = false;
      _userRoles = [];
    }
  }

  Future<void> login(String token, List<String> roles) async {
    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(
      key: 'user_roles',
      value: roles.join(','),
    ); 

    _userRoles = List.from(roles);
    _isAuthenticated = true;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_roles'); 
    _userRoles = [];
    _isAuthenticated = false;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token') ?? '';
  }

  bool hasRole(String role) {
    return _userRoles.contains(role);
  }

  bool hasAnyRole(List<String> roles) {
    return _userRoles.any((role) => roles.contains(role));
  }

  // Added method to change roles for testing purposes
  Future<void> updateRoles(List<String> newRoles) async {
    await _storage.write(key: 'user_roles', value: newRoles.join(','));
    _userRoles = List.from(newRoles);
  }

  // Added method to get current user roles
  List<String> getCurrentUserRoles() {
    return List.from(_userRoles);
  }
}
