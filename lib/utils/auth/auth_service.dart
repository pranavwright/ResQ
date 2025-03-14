import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:resq/utils/http/token_http.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this dependency

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  List<String> _userRoles = [];
  Map<String, dynamic>? _userProfile;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  List<String> get userRoles => List.from(_userRoles);

  // Get roles - prevent returning null
  List<String> getCurrentUserRoles() {
    return List.from(_userRoles);
  }

  // Get profile
  Map<String, dynamic>? getUserProfile() {
    return _userProfile;
  }

  // Handle different storage mechanisms for web vs mobile
  Future<void> _saveToStorage(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  Future<String?> _readFromStorage(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  Future<void> _deleteFromStorage(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  Future<void> _clearStorage() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      // Only clear auth-related keys, not all prefs
      await prefs.remove('auth_token');
      await prefs.remove('user_roles');
      await prefs.remove('user_profile');
    } else {
      await _secureStorage.deleteAll();
    }
  }

  // Load auth state with better error handling
  Future<void> loadAuthState() async {
    try {
      final token = await _readFromStorage('auth_token');
      final user = await TokenHttp().get('/auth/getUser');
      final roles = user['roles'] as List<dynamic>;
      final rolesString = roles.map((role) => role.toString()).join(',');
      final profile = {
        'email': user['email'],
        'profileImagePath': user['photoUrl'],
      };
      await _saveToStorage('user_roles', rolesString);
      await _saveToStorage('user_profile', json.encode(profile));

      print('AuthService loaded token: ${token?.substring(0, 10)}...');
      print('AuthService loaded roles: $rolesString');

      _token = token;

      if (token != null && token.isNotEmpty) {
        _isAuthenticated = true;
        _userRoles = rolesString?.split(',') ?? [];
        _userProfile = profile;
      } else {
        _isAuthenticated = false;
        _userRoles = [];
        _userProfile = null;
      }
    } catch (e) {
      print('Error loading auth state: $e');
      _isAuthenticated = false;
      _userRoles = [];
      _userProfile = null;
    }
  }

  // Login with complete profile support
  Future<void> login(
    String token,
    List<String> roles, [
    Map<String, dynamic>? profile,
  ]) async {
    try {
      await _saveToStorage('auth_token', token);
      await _saveToStorage('user_roles', roles.join(','));

      if (profile != null) {
        await _saveToStorage('user_profile', json.encode(profile));
        _userProfile = Map<String, dynamic>.from(profile);
      }

      _token = token;
      _isAuthenticated = true;
      _userRoles = List.from(roles);

      print(
        'Login successful - token: ${token.substring(0, 10)}... roles: $roles',
      );
    } catch (e) {
      print('Error during login: $e');
      throw e;
    }
  }

  bool isProfileComplete() {
    if (_userProfile == null) return false;

    // Check for various image fields that might indicate a complete profile
    return (_userProfile!['photoUrl'] != null &&
            _userProfile!['photoUrl'].toString().isNotEmpty) ||
        (_userProfile!['profileImagePath'] != null &&
            _userProfile!['profileImagePath'].toString().isNotEmpty) ||
        (_userProfile![' ImagePath'] != null &&
            _userProfile![' ImagePath']
                .toString()
                .isNotEmpty); // Include the typo field for backward compatibility
  }

  // Update profile with fixed field name
  Future<void> saveUserProfile({
    required String email,
    required String profileImagePath,
  }) async {
    try {
      final currentProfile = _userProfile ?? {};

      // Create the updated profile map with new values
      final updatedProfile = {
        ...currentProfile,
        'email': email,
        'profileImagePath':
            profileImagePath, // Fixed the space before ImagePath
      };

      // Save to storage
      await _saveToStorage('user_profile', json.encode(updatedProfile));
      _userProfile = updatedProfile;

      print('Profile updated: $updatedProfile');
    } catch (e) {
      print('Error updating profile: $e');
      throw e;
    }
  }

  // Get token
  Future<String?> getToken() async {
    if (_token != null) return _token;

    _token = await _readFromStorage('auth_token');
    return _token;
  }

  // Logout
  Future<void> logout() async {
    await _clearStorage();

    _isAuthenticated = false;
    _userRoles = [];
    _userProfile = null;
    _token = null;

    print('Logout successful');
  }
}
