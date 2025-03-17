import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:resq/utils/http/token_http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
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

  List<String> getCurrentUserRoles() {
    return List.from(_userRoles);
  }

  Map<String, dynamic>? getUserProfile() {
    return _userProfile;
  }

  Future<void> _saveToStorage(String key, String value) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
      } else {
        await _secureStorage.write(key: key, value: value);
      }
    } catch (e) {
      print('Error saving to storage: $e');
      throw e; // Rethrow to let caller handle
    }
  }

  Future<String?> _readFromStorage(String key) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);
      } else {
        return await _secureStorage.read(key: key);
      }
    } catch (e) {
      print('Error reading from storage: $e');
      return null;
    }
  }

  Future<void> _deleteFromStorage(String key) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      } else {
        await _secureStorage.delete(key: key);
      }
    } catch (e) {
      print('Error deleting from storage: $e');
      throw e; // Rethrow
    }
  }

  Future<void> _clearStorage() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_roles');
        await prefs.remove('user_profile');
      } else {
        await _secureStorage.deleteAll();
      }
    } catch (e) {
      print('Error clearing storage: $e');
      throw e; // Rethrow
    }
  }

  Future<void> loadAuthState() async {
  try {
    final token = await _readFromStorage('auth_token');
    if (token == null || token.isEmpty) {
      _isAuthenticated = false;
      _userRoles = [];
      _userProfile = null;
      return;
    }

    // Log auth token first few chars for debugging
    print('Loaded token: ${token}...');
    
    try {
      final user = await TokenHttp().get('/auth/getUser');
      if (user == null) {
        print('User data is null from API');
        _isAuthenticated = false;
        _userRoles = [];
        _userProfile = null;
        // await _clearStorage();
        return;
      }
      
      // Check if roles exists and is a list
      final roles = user['roles'];
      if (roles == null) {
        print('Roles not found in user data');
        _isAuthenticated = false;
        _userRoles = [];
        _userProfile = null;
        // await _clearStorage();
        return;
      }
      
      // Convert roles to List<String> and handle non-list responses
      List<String> rolesList;
      if (roles is List) {
        rolesList = roles.map((role) => role.toString()).toList();
      } else if (roles is String) {
        rolesList = [roles];
      } else {
        print('Unexpected roles format: $roles');
        rolesList = [];
      }
      
      final profile = {
        'email': user['emailId'] ?? '',
        'profileImagePath': user['photoUrl'] ?? '',
      };
      
      // Save updated data to storage
      await _saveToStorage('user_roles', rolesList.join(','));
      await _saveToStorage('user_profile', json.encode(profile));
      
      // Update in-memory state
      _token = token;
      _userRoles = rolesList;
      _userProfile = profile;
      _isAuthenticated = rolesList.isNotEmpty;
      
    } catch (e) {
      print('API error in loadAuthState: $e');
      // Keep token but mark as unauthenticated if API error occurs
      _token = token;
      _isAuthenticated = false;
      _userRoles = [];
      _userProfile = null;
    }
  } catch (e) {
    print('General error in loadAuthState: $e');
    _isAuthenticated = false;
    _userRoles = [];
    _userProfile = null;
  }
}

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

    return (_userProfile!['photoUrl'] != null &&
            _userProfile!['photoUrl'].toString().isNotEmpty) ||
        (_userProfile!['profileImagePath'] != null &&
            _userProfile!['profileImagePath'].toString().isNotEmpty);
  }

  Future<void> saveUserProfile({
    required String email,
    required String profileImagePath,
  }) async {
    try {
      final currentProfile = _userProfile ?? {};
      final updatedProfile = {
        ...currentProfile,
        'email': email,
        'profileImagePath': profileImagePath,
      };

      await _saveToStorage('user_profile', json.encode(updatedProfile));
      _userProfile = updatedProfile;

      print('Profile updated: $updatedProfile');
    } catch (e) {
      print('Error updating profile: $e');
      throw e;
    }
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;

    _token = await _readFromStorage('auth_token');
    return _token;
  }

  Future<void> logout() async {
    await _clearStorage();

    _isAuthenticated = false;
    _userRoles = [];
    _userProfile = null;
    _token = null;

    print('Logout successful');
  }
}
