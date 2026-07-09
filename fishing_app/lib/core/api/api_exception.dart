import 'package:dio/dio.dart';

String apiErrorMessage(Object? error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요.';
      case DioExceptionType.connectionError:
        return '서버에 연결할 수 없습니다. 네트워크 상태를 확인해주세요.';
      default:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }
  return '알 수 없는 오류가 발생했습니다.';
}
