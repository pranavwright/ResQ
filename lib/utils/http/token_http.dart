import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../constants/api_constants.dart';
import '../auth/auth_service.dart';
import 'package:mime/mime.dart';

class TokenHttp {
  final String baseUrl = ApiConstants.baseUrl;
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheExpiry = {};
  final Duration _defaultCacheDuration = Duration(minutes: 5);

  Future<Map<String, String>> _getHeaders({String? contentType}) async {
    final token = await AuthService().getToken() ?? "token";
    return {
      'Content-Type': contentType ?? 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(
    String endpoint, {
    bool useCache = true,
    Duration? cacheDuration,
  }) async {
    final cacheKey = endpoint;
    final now = DateTime.now();

    if (useCache &&
        _cache.containsKey(cacheKey) &&
        _cacheExpiry.containsKey(cacheKey) &&
        now.isBefore(_cacheExpiry[cacheKey]!)) {
      return _cache[cacheKey];
    }

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseJson = jsonDecode(response.body);
        if (useCache) {
          _cache[cacheKey] = responseJson;
          _cacheExpiry[cacheKey] = now.add(
            cacheDuration ?? _defaultCacheDuration,
          );
        }
        return responseJson; // Now can return either Map or List
      } else {
        throw Exception(
          'GET request failed: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
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
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'PUT request failed: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
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
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  Future<Map<String, dynamic>> uploadFile({
    required String endpoint,
    required File file,
    required String fieldName,
    required String fileName,
    Map<String, String>? additionalFields,
  }) async {
    try {
      final token = await AuthService().getToken() ?? "token";
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

      request.files.add(
        http.MultipartFile(
          fieldName,
          fileStream,
          fileLength,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      if (additionalFields != null) request.fields.addAll(additionalFields);

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'File upload failed: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  Future<Map<String, dynamic>> uploadMultipleFiles({
    required String endpoint,
    required List<Map<String, dynamic>> files,
    Map<String, String>? additionalFields,
  }) async {
    try {
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
        final contentType =
            lookupMimeType(fileName) ?? 'application/octet-stream';

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
    } catch (e) {
      throw Exception('Multiple file upload failed: $e');
    }
  }

  Future<Map<String, dynamic>> putWithFileUpload({
    required String endpoint,
    required File file,
    required String fieldName,
    String? fileName,
    Map<String, dynamic>? additionalFields,
  }) async {
    try {
      final token = await AuthService().getToken() ?? "token";
      final uri = Uri.parse('$baseUrl$endpoint');

      final request = http.MultipartRequest('PUT', uri);

      request.headers['Authorization'] = 'Bearer $token';

      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final mimeType =
          lookupMimeType(fileName ?? file.path.split('/').last) ??
          'application/octet-stream';

      final multipartFile = http.MultipartFile(
        fieldName,
        fileStream,
        fileLength,
        filename: fileName ?? file.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);

      if (additionalFields != null) {
        additionalFields.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'PUT with file upload failed: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('PUT with file upload failed: $e');
    }
  }

  void clearCache() {
    _cache.clear();
    _cacheExpiry.clear();
  }
}
