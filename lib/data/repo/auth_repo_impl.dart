import 'dart:convert';

import 'package:feed_app/core/utils/app_constants.dart';
import 'package:feed_app/domain/repo/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthRepositoryImpl implements AuthRepository {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrlAuth}/login'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': 'reqres-free-v1',
      },
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Invalid credentials');
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  @override
  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }
}
