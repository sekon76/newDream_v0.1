import 'package:dio/dio.dart';
import 'package:fishing_app/core/api/api_client.dart';
import 'package:fishing_app/core/storage/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(dioProvider), ref.watch(secureStorageProvider));
}

class AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthRepository(this._dio, this._storage);

  Future<void> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final token = res.data['accessToken'] as String;
    await _storage.saveToken(token);
  }

  Future<void> signup(String email, String password, String nickname) async {
    await _dio.post('/auth/signup', data: {
      'email': email,
      'password': password,
      'nickname': nickname,
      'mapProvider': 'NAVER',
    });
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      await _storage.deleteToken();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.readToken();
    return token != null;
  }
}
