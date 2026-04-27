import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // Use localhost for Web. For Android emulator, we would use 10.0.2.2 but we're testing on web now.
  static String get baseUrl {
    // Backend running on port 9090 with Swagger
    return 'http://localhost:9090/api';
  }
  static const String _tokenKey = 'jwt_token';

  // ── Token management ────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── Headers ─────────────────────────────────────────────────────────────────

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> _publicHeaders() => {
        'Content-Type': 'application/json',
      };

  // ── HTTP verbs ───────────────────────────────────────────────────────────────

  static Future<http.Response> get(String path) async {
    final headers = await _authHeaders();
    return http.get(Uri.parse('$baseUrl$path'), headers: headers);
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body,
      {bool authenticated = true}) async {
    final headers =
        authenticated ? await _authHeaders() : _publicHeaders();
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(
      String path, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String path) async {
    final headers = await _authHeaders();
    return http.delete(Uri.parse('$baseUrl$path'), headers: headers);
  }

  // ── Response helper ──────────────────────────────────────────────────────────

  static dynamic parseResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return null;
      return jsonDecode(body);
    }
    // Extract error message from API response body
    String message = 'Request failed (${response.statusCode})';
    try {
      final errorBody = jsonDecode(body) as Map<String, dynamic>;
      message = errorBody['error'] as String? ??
          errorBody['message'] as String? ??
          message;
    } catch (_) {}
    throw Exception(message);
  }
}
