import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../constants/api_constants.dart';
import '../auth/auth_service.dart';

class TokenHttp {
  final String baseUrl = ApiConstants.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken() ?? "token";
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _getFileHeaders() async {
    final token = await AuthService().getToken() ?? "token";
    return {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'GET request failed: ${response.statusCode}, ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'POST request failed: ${response.statusCode}, ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'PUT request failed: ${response.statusCode}, ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> putWithFileUpload({
    required String endpoint,
    required File file,
    required String fieldName,
    String? fileName,
    Map<String, dynamic>? additionalFields,
  }) async {
    final token = await AuthService().getToken() ?? "token";
    final uri = Uri.parse('$baseUrl$endpoint');

    final request = http.MultipartRequest('PUT', uri);

    request.headers['Authorization'] = 'Bearer $token';

    final fileStream = http.ByteStream(file.openRead());
    final fileLength = await file.length();

    final multipartFile = http.MultipartFile(
      fieldName,
      fileStream,
      fileLength,
      filename: fileName ?? file.path.split('/').last,
    );

    request.files.add(multipartFile);

    // Add additional fields if provided
    if (additionalFields != null) {
      additionalFields.forEach((key, value) {
        request.fields[key] = value.toString();
      });
    }

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'PUT with file upload failed: ${response.statusCode}, ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return response.body.isEmpty ? {} : jsonDecode(response.body);
    } else {
      throw Exception(
        'DELETE request failed: ${response.statusCode}, ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> uploadFile({
    required String endpoint,
    required File file,
    required String fieldName,
    required String fileName,
    String contentType = 'multipart/form-data',
    Map<String, String>? additionalFields,
  }) async {
    final token = await AuthService().getToken() ?? "token";
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );
    request.headers['Authorization'] = 'Bearer $token';

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
    if (additionalFields != null) request.fields.addAll(additionalFields);

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'File upload failed: ${response.statusCode}, ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> uploadMultipleFiles({
    required String endpoint,
    required List<Map<String, dynamic>> files,
    Map<String, String>? additionalFields,
  }) async {
    final token = await AuthService().getToken() ?? "token";
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    for (var fileData in files) {
      final file = fileData['file'] as File;
      final fieldName = fileData['fieldName'] as String;
      final fileName = fileData['fileName'] as String;
      final contentType = fileData['contentType'] ?? 'application/octet-stream';

      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();

      request.files.add(
        http.MultipartFile(
          fieldName,
          fileStream,
          fileLength,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      );
    }

    if (additionalFields != null) request.fields.addAll(additionalFields);

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Multiple file upload failed: ${response.statusCode}, ${response.body}',
      );
    }
  }
}
