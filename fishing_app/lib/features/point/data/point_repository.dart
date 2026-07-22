import 'package:dio/dio.dart';
import 'package:fishing_app/core/api/api_client.dart';
import 'package:fishing_app/features/point/data/point_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'point_repository.g.dart';

@riverpod
PointRepository pointRepository(Ref ref) {
  return PointRepository(ref.watch(dioProvider));
}

class PointRepository {
  final Dio _dio;
  PointRepository(this._dio);

  Future<List<FishingPoint>> listPoints() async {
    final res = await _dio.get('/points');
    return (res.data as List).map((e) => FishingPoint.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FishingPoint> getPoint(int id) async {
    final res = await _dio.get('/points/$id');
    return FishingPoint.fromJson(res.data as Map<String, dynamic>);
  }

  Future<FishingPoint> createPoint({
    required String name,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? fishType,
    bool isPublic = false,
    bool communityOnly = false,
  }) async {
    final res = await _dio.post('/points', data: {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'fishType': fishType,
      'isPublic': isPublic,
      'communityOnly': communityOnly,
    });
    return FishingPoint.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deletePoint(int id) => _dio.delete('/points/$id');

  Future<List<PointVisit>> listVisits(int pointId) async {
    final res = await _dio.get('/points/$pointId/visits');
    return (res.data as List).map((e) => PointVisit.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PointVisit> createVisit(
    int pointId, {
    required DateTime visitDate,
    String? title,
    String? content,
    String? memo,
    bool isPublic = false,
    List<TackleEntryData> tackles = const [],
    List<CatchRecordData> catches = const [],
  }) async {
    final res = await _dio.post(
      '/points/$pointId/visits',
      data: _visitPayload(
        visitDate: visitDate,
        title: title,
        content: content,
        memo: memo,
        isPublic: isPublic,
        tackles: tackles,
        catches: catches,
      ),
    );
    return PointVisit.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PointVisit> updateVisit(
    int pointId,
    int visitId, {
    required DateTime visitDate,
    String? title,
    String? content,
    String? memo,
    bool isPublic = false,
    List<TackleEntryData> tackles = const [],
    List<CatchRecordData> catches = const [],
  }) async {
    final res = await _dio.put(
      '/points/$pointId/visits/$visitId',
      data: _visitPayload(
        visitDate: visitDate,
        title: title,
        content: content,
        memo: memo,
        isPublic: isPublic,
        tackles: tackles,
        catches: catches,
      ),
    );
    return PointVisit.fromJson(res.data as Map<String, dynamic>);
  }

  Map<String, dynamic> _visitPayload({
    required DateTime visitDate,
    String? title,
    String? content,
    String? memo,
    required bool isPublic,
    required List<TackleEntryData> tackles,
    required List<CatchRecordData> catches,
  }) {
    return {
      'visitDate':
          '${visitDate.year.toString().padLeft(4, '0')}-${visitDate.month.toString().padLeft(2, '0')}-${visitDate.day.toString().padLeft(2, '0')}',
      'title': title,
      'content': content,
      'memo': memo,
      'isPublic': isPublic,
      'tackles': tackles.map((e) => e.toJson()).toList(),
      'catches': catches.map((e) => e.toJson()).toList(),
    };
  }
}
