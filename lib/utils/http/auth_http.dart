import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:resq/utils/auth/auth_service.dart';
import '../../constants/api_constants.dart';

class AuthHttp {
  final String baseUrl = ApiConstants.baseUrl;
  final Future<String?> token = AuthService().getToken();

  // Default headers with authorization
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  Future<Map<String, dynamic>> register({
    required String name,
    required String role,
    required String phoneNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'phone_number': phoneNumber,
        'role': role,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register user: ${response.body}');
    }
  }

Future<Map<String, dynamic>> checkPhoneNumber({
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/checkPhoneNumber'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}), // Serialize to JSON
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Decode and provide the error message from the server
        final errorResponse = jsonDecode(response.body);
        throw Exception('Failed to check user: ${errorResponse['message'] ?? response.body}');
      }
    } catch (e) {
      // Catch network or other exceptions
      throw Exception('Failed to check user: $e');
    }
  }

  Future<Map<String, dynamic>> verifyFirebaseToken({
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verifyFirebaseToken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'firebaseToken': token}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify token: ${response.body}');
    }
  }
}