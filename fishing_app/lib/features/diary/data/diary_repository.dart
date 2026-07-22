import 'package:dio/dio.dart';
import 'package:fishing_app/core/api/api_client.dart';
import 'package:fishing_app/features/diary/data/diary_model.dart';
import 'package:fishing_app/features/point/data/point_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'diary_repository.g.dart';

@riverpod
DiaryRepository diaryRepository(Ref ref) {
  return DiaryRepository(ref.watch(dioProvider));
}

class DiaryRepository {
  final Dio _dio;
  DiaryRepository(this._dio);

  Future<List<Diary>> listDiaries() async {
    final res = await _dio.get('/diaries');
    return (res.data as List).map((e) => Diary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Diary> createDiary({
    required DateTime visitDate,
    String? title,
    String? content,
    String? memo,
    int? pointId,
    double? latitude,
    double? longitude,
    String? address,
    List<TackleEntryData> tackles = const [],
    List<CatchRecordData> catches = const [],
  }) async {
    final res = await _dio.post('/diaries', data: {
      'visitDate': _dateStr(visitDate),
      'title': title,
      'content': content,
      'memo': memo,
      'pointId': pointId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'tackles': tackles.map((e) => e.toJson()).toList(),
      'catches': catches.map((e) => e.toJson()).toList(),
    });
    return Diary.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Diary> updateDiary(
    int diaryId, {
    required DateTime visitDate,
    String? title,
    String? content,
    String? memo,
    List<TackleEntryData> tackles = const [],
    List<CatchRecordData> catches = const [],
  }) async {
    final res = await _dio.put('/diaries/$diaryId', data: {
      'visitDate': _dateStr(visitDate),
      'title': title,
      'content': content,
      'memo': memo,
      'tackles': tackles.map((e) => e.toJson()).toList(),
      'catches': catches.map((e) => e.toJson()).toList(),
    });
    return Diary.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteDiary(int diaryId) => _dio.delete('/diaries/$diaryId');

  String _dateStr(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
