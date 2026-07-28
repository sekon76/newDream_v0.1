import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage.g.dart';

// 앱 프로세스가 완전히 종료됐다가 다시 시작되면 반드시 재로그인하도록,
// 토큰을 디스크에 저장하지 않고 앱이 실행되어 있는 동안만 메모리에 유지한다.
// keepAlive: true로 지정해 앱이 켜져 있는 동안에는 provider가 자동 해제되어
// 토큰이 유실되는 일이 없도록 한다.
@Riverpod(keepAlive: true)
SecureStorageService secureStorage(Ref ref) => SecureStorageService();

class SecureStorageService {
  String? _token;

  Future<void> saveToken(String token) async => _token = token;
  Future<String?> readToken() async => _token;
  Future<void> deleteToken() async => _token = null;
}
