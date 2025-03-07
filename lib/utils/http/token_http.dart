import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../constants/api_constants.dart';
import '../auth/auth_service.dart';

class TokenHttp {
  final String baseUrl = ApiConstants.baseUrl;
  final String token;

  TokenHttp({required this.token});

  // Default headers with authorization
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// Perform authenticated GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('GET request failed: ${response.statusCode}, ${response.body}');
    }
  }

  /// Perform authenticated POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('POST request failed: ${response.statusCode}, ${response.body}');
    }
  }

  /// Perform authenticated PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('PUT request failed: ${response.statusCode}, ${response.body}');
    }
  }

  /// Perform authenticated DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return response.body.isEmpty ? {} : jsonDecode(response.body);
    } else {
      throw Exception('DELETE request failed: ${response.statusCode}, ${response.body}');
    }
  }

  /// Upload a file with additional form data
  Future<Map<String, dynamic>> uploadFile({
    required String endpoint,
    required File file,
    required String fieldName,
    required String fileName,
    String contentType = 'application/octet-stream',
    Map<String, String>? additionalFields,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );

    // Add authorization header
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    // Add the file
    final fileStream = http.ByteStream(file.openRead());
    final fileLength = await file.length();

    final multipartFile = http.MultipartFile(
      fieldName,
      fileStream,
      fileLength,
      filename: fileName,
      contentType: MediaType.parse(contentType),
    );

    request.files.add(multipartFile);

    // Add additional fields if provided
    if (additionalFields != null) {
      request.fields.addAll(additionalFields);
    }

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('File upload failed: ${response.statusCode}, ${response.body}');
    }
  }

  /// Upload multiple files with additional form data
  Future<Map<String, dynamic>> uploadMultipleFiles({
    required String endpoint,
    required List<Map<String, dynamic>> files,
    Map<String, String>? additionalFields,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );

    // Add authorization header
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    // Add all files
    for (final fileData in files) {
      final file = fileData['file'] as File;
      final fieldName = fileData['fieldName'] as String;
      final fileName = fileData['fileName'] as String;
      final contentType = fileData['contentType'] as String? ?? 'application/octet-stream';

      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();

      final multipartFile = http.MultipartFile(
        fieldName,
        fileStream,
        fileLength,
        filename: fileName,
        contentType: MediaType.parse(contentType),
      );

      request.files.add(multipartFile);
    }

    // Add additional fields if provided
    if (additionalFields != null) {
      request.fields.addAll(additionalFields);
    }

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Multiple file upload failed: ${response.statusCode}, ${response.body}');
    }
  }
}


Future<TokenHttp> getTokenHttp() async {
  final token = await AuthService().getToken();
  return TokenHttp(token: token ?? '');
}

// For static access to common methods
class TokenHttpProvider {
  static TokenHttp? _instance;
  
  // Get or create the TokenHttp instance
  static Future<TokenHttp> getInstance() async {
    if (_instance == null) {
      final token = await AuthService().getToken();
      _instance = TokenHttp(token: token ?? '');
    }
    return _instance!;
  }
  
  // Refresh the token if needed
  static Future<void> refreshToken() async {
    final token = await AuthService().getToken();
    _instance = TokenHttp(token: token ?? '');
  }
}