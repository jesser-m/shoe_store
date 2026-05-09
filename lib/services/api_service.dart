import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _tokenKey = 'jwt_token';

  // Get token
  static Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    debugPrint('ApiService: Retrieved token: ${token != null ? "FOUND (len: ${token.length})" : "NOT FOUND"}');
    return token?.trim();
  }

  // Save token
  static Future<void> saveToken(String token) async {
    debugPrint('ApiService: Saving token (len: ${token.length})');
    await _storage.write(key: _tokenKey, value: token.trim());
  }

  // Delete token
  static Future<void> deleteToken() async {
    debugPrint('ApiService: Deleting token');
    await _storage.delete(key: _tokenKey);
  }

  // Get headers with auth
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        // For backward compatibility with some backend versions
        headers['x-auth-token'] = token;
      } else {
        debugPrint('ApiService: No token available for auth request');
      }
    }
    return headers;
  }

  // GET request
  static Future<http.Response> get(String endpoint, {bool auth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _headers(auth: auth);
    return await http.get(url, headers: headers);
  }

  // POST request
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _headers(auth: auth);
    return await http.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // PUT request
  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _headers(auth: auth);
    return await http.put(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // DELETE request
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _headers(auth: auth);
    return await http.delete(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // Multipart file upload
  static Future<http.StreamedResponse> uploadFile(
    String endpoint,
    File file, {
    String field = 'image',
    bool auth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', url);

    if (auth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    final bytes = await file.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(field, bytes, filename: file.path.split('/').last));

    return await request.send();
  }

  // Upload bytes (web compatible)
  static Future<http.StreamedResponse> uploadBytes(
    String endpoint,
    List<int> bytes, {
    String field = 'image',
    String filename = 'upload.jpg',
    bool auth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', url);

    if (auth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['x-auth-token'] = token;
        debugPrint('ApiService: Attached token to upload request');
      } else {
        debugPrint('ApiService: No token available for upload request');
      }
    }

    request.files.add(
      http.MultipartFile.fromBytes(field, bytes, filename: filename),
    );

    return await request.send();
  }

  // Handle response and parse JSON
  static dynamic handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Request failed with ${response.statusCode}',
      );
    }
  }
}
