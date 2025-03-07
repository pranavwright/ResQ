import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../constants/api_constants.dart';

/// HTTP client for API requests that don't require authentication
class TokenLessHttp {
  final String baseUrl = ApiConstants.baseUrl;

  // Default headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  /// Perform GET request without authentication
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

  /// Perform POST request without authentication
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

  /// Perform PUT request without authentication
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

  /// Perform DELETE request without authentication
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

  /// Upload a file without authentication
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

  /// Upload multiple files without authentication
  Future<Map<String, dynamic>> uploadMultipleFiles({
    required String endpoint,
    required List<Map<String, dynamic>> files,
    Map<String, String>? additionalFields,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );

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

final tokenLessHttp = TokenLessHttp();