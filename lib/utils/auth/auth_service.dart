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
  String _disasterId = '';
  List<String> _userRoles = [];
  Map<String, dynamic>? _userProfile;
  String? _token;
  String? _assignPlace;


  String? get assignPlace => _assignPlace;
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
      throw e;
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
      throw e;
    }
  }

  Future<void> _clearStorage() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_roles');
        await prefs.remove('user_profile');
        await prefs.remove('disaster_id');
      } else {
        await _secureStorage.deleteAll();
      }
    } catch (e) {
      print('Error clearing storage: $e');
      throw e;
    }
  }

  Future<void> loadAuthState() async {
    try {
      final token = await _readFromStorage('auth_token');
      final disasterId = await _readFromStorage('disaster_id');

      if (token == null || token.isEmpty) {
        _isAuthenticated = false;
        _userRoles = [];
        _userProfile = null;
        _disasterId = '';
        return;
      }

      print('Loaded token: ${token.substring(0, 10)}...');

      try {
        final user = await TokenHttp().get('/auth/getUser');
        if (user == null) {
          print('User data is null from API');
          _isAuthenticated = false;
          _userRoles = [];
          _userProfile = null;
          _disasterId = '';
          return;
        }

        final rolesData = user['roles'];
        if (rolesData == null) {
          print('Roles not found in user data');
          _isAuthenticated = false;
          _userRoles = [];
          _userProfile = null;
          _disasterId = '';
          return;
        }

        String assignPlace = '';
        List<String> rolesList = [];
        if (rolesData is List) {
          for (var roleData in rolesData) {
            if (roleData['disasterId'] == disasterId) {
              rolesList = List<String>.from(roleData['roles'].map((role) => role.toString()));
              assignPlace = roleData['assignPlace'] ?? '';
              break;
            }
          }
        }
        
        if (rolesList.isEmpty){
          print('Roles not found for current disaster id');
          _isAuthenticated = false;
          _userRoles = [];
          _userProfile = null;
          _disasterId = '';
          return;
        }

        final profile = {
          'email': user['emailId'] ?? '',
          'profileImagePath': user['photoUrl'] ?? '',
        };

        await _saveToStorage('user_profile', json.encode(profile));
        await _saveToStorage('disaster_id', disasterId ?? '');
        await _saveToStorage('assigned_place', assignPlace);

        _token = token;
        _userRoles = rolesList;
        _userProfile = profile;
        _isAuthenticated = rolesList.isNotEmpty;
        _disasterId = disasterId ?? '';
      } catch (e) {
        print('API error in loadAuthState: $e');
        _token = token;
        _isAuthenticated = false;
        _userRoles = [];
        _userProfile = null;
        _disasterId = '';
      }
    } catch (e) {
      print('General error in loadAuthState: $e');
      _isAuthenticated = false;
      _userRoles = [];
      _userProfile = null;
      _disasterId = '';
    }
  }

  Future<void> changeDisaster(
    String disasterId,
    List<String> roles,
  ) async {
    try {
      await _saveToStorage('disaster_id', disasterId);
      _userRoles = List.from(roles);

      _disasterId = disasterId;

      print('Disaster changed to: $disasterId');
    } catch (e) {
      print('Error changing disaster: $e');
      throw e;
    }
  }

  Future<void> login(
    String token,
    List<String> roles,
    String disasterId, [
    String? assignPlace,
  ]) async {
    try {
      await _saveToStorage('auth_token', token);
      await _saveToStorage('disaster_id', disasterId);
      await _saveToStorage('assigned_place', assignPlace ?? '');

      _token = token;
      _isAuthenticated = true;
      _userRoles = List.from(roles);
      _disasterId = disasterId;
      _assignPlace = assignPlace;

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

    return (_userProfile!['profileImagePath'] != null &&
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
    _disasterId = '';

    print('Logout successful');
  }

  String getDisasterId() {
    return _disasterId;
  }
}