import 'dart:convert';

import 'package:feed_app/core/utils/app_constants.dart';
import 'package:feed_app/domain/repo/auth_repository.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Database db;

  AuthRepositoryImpl({required this.db});

  @override
  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrlAuth}/login'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': 'reqres-free-v1'
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
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
    await db.insert(
      'auth',
      {'token': token},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<String?> getToken() async {
    final result = await db.query('auth', limit: 1);
    if (result.isNotEmpty) {
      return result.first['token'] as String;
    }
    return null;
  }

  @override
  Future<void> clearToken() async {
    await db.delete('auth');
  }
}
