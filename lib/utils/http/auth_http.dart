import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/api_constants.dart';

class AuthHttp {
  final String baseUrl = ApiConstants.baseUrl;

  Future<Map<String, dynamic>> register({
    required String name,
    required String role,
    required String phoneNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
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

  
  Future<Map<String, dynamic>> checkUser({
    required String uid,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/checkUser?uid=$uid'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check user: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> verifyFirebaseToken({
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verifyFirebaseToken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify token: ${response.body}');
    }
  }
}