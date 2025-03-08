import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  List<String> _userRoles = [];
  bool _isProfileCompleted = false;
  
  // Caching to improve performance
  String? _cachedToken;
  String? _cachedEmail;
  String? _cachedProfileImagePath;
  Map<String, String?>? _cachedUserProfile;

  bool get isAuthenticated => _isAuthenticated;
  List<String> get userRoles => List.from(_userRoles);
  bool get isProfileCompleted => _isProfileCompleted;

  // Load authentication state at startup - optimized with parallel reads
  Future<void> loadAuthState() async {
    try {
      // Read all values in parallel instead of sequentially
      final futures = await Future.wait([
        _storage.read(key: 'auth_token'),
        _storage.read(key: 'user_roles'),
        _storage.read(key: 'profile_completed')
      ]);
      
      final token = futures[0];
      final rolesString = futures[1];
      final profileCompleted = futures[2];
      
      print('AuthService: Loaded Token -> $token');
      print('AuthService: Loaded Roles -> $rolesString');
      print('AuthService: Loaded Profile Completed -> $profileCompleted');

      // Update cache
      _cachedToken = token;

      if (token != null) {
        _isAuthenticated = true;
        _userRoles = rolesString != null ? rolesString.split(',') : [];
        _isProfileCompleted = profileCompleted == 'true';
      } else {
        _isAuthenticated = false;
        _userRoles = [];
        _isProfileCompleted = false;
      }
    } catch (e) {
      print('Error loading auth state: $e');
      // Set default values on error
      _isAuthenticated = false;
      _userRoles = [];
      _isProfileCompleted = false;
    }
  }

  Future<void> login(String token, List<String> roles) async {
    // Update storage
    await Future.wait([
      _storage.write(key: 'auth_token', value: token),
      _storage.write(key: 'user_roles', value: roles.join(','))
    ]);

    // Update cached values
    _cachedToken = token;
    _userRoles = List.from(roles);
    _isAuthenticated = true;
  }

  Future<void> logout() async {
    // Delete all values in parallel
    await Future.wait([
      _storage.delete(key: 'auth_token'),
      _storage.delete(key: 'user_roles'),
      _storage.delete(key: 'profile_completed'),
      _storage.delete(key: 'user_email'),
      _storage.delete(key: 'profile_image_path')
    ]);

    // Clear all cached values
    _cachedToken = null;
    _cachedEmail = null;
    _cachedProfileImagePath = null;
    _cachedUserProfile = null;
    
    // Reset state
    _userRoles = [];
    _isAuthenticated = false;
    _isProfileCompleted = false;
  }

  Future<String?> getToken() async {
    // Use cached token if available
    if (_cachedToken != null) return _cachedToken;
    
    // Otherwise read from storage and cache
    _cachedToken = await _storage.read(key: 'auth_token');
    return _cachedToken;
  }

  bool hasRole(String role) {
    return _userRoles.contains(role);
  }

  bool hasAnyRole(List<String> roles) {
    return _userRoles.any((role) => roles.contains(role));
  }

  // Update roles dynamically
  Future<void> updateRoles(List<String> newRoles) async {
    await _storage.write(key: 'user_roles', value: newRoles.join(','));
    _userRoles = List.from(newRoles);
  }

  // Get current user roles - no need for async since we keep this in memory
  List<String> getCurrentUserRoles() {
    return List.from(_userRoles);
  }

  // Save user profile data - optimized with parallel writes
  Future<void> saveUserProfile({
    required String email,
    required String profileImagePath,
  }) async {
    // Write in parallel
    await Future.wait([
      _storage.write(key: 'user_email', value: email),
      _storage.write(key: 'profile_image_path', value: profileImagePath)
    ]);
    
    // Update cache
    _cachedEmail = email;
    _cachedProfileImagePath = profileImagePath;
    _cachedUserProfile = {
      'email': email,
      'profileImagePath': profileImagePath,
    };
  }

  // Mark profile as completed
  Future<void> markProfileCompleted() async {
    await _storage.write(key: 'profile_completed', value: 'true');
    _isProfileCompleted = true;
  }

  // Check if profile is completed - optimized to use in-memory value when possible
  Future<bool> checkProfileCompleted() async {
    if (_isProfileCompleted) return true;
    
    final profileCompleted = await _storage.read(key: 'profile_completed');
    _isProfileCompleted = profileCompleted == 'true';
    return _isProfileCompleted;
  }

  // Get user profile data - optimized with caching
  Future<Map<String, String?>> getUserProfile() async {
    // Return cached profile if available
    if (_cachedUserProfile != null) return _cachedUserProfile!;
    
    // Otherwise read from storage
    final futures = await Future.wait([
      _storage.read(key: 'user_email'),
      _storage.read(key: 'profile_image_path')
    ]);
    
    final email = futures[0];
    final profileImagePath = futures[1];
    
    // Cache the result
    _cachedEmail = email;
    _cachedProfileImagePath = profileImagePath;
    _cachedUserProfile = {
      'email': email,
      'profileImagePath': profileImagePath,
    };
    
    return _cachedUserProfile!;
  }
}