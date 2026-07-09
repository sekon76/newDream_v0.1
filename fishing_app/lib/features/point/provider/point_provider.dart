import 'package:fishing_app/features/point/data/point_model.dart';
import 'package:fishing_app/features/point/data/point_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'point_provider.g.dart';

@riverpod
Future<List<FishingPoint>> points(Ref ref) {
  return ref.watch(pointRepositoryProvider).listPoints();
}

@riverpod
Future<FishingPoint> pointDetail(Ref ref, int pointId) {
  return ref.watch(pointRepositoryProvider).getPoint(pointId);
}

@riverpod
Future<List<PointVisit>> pointVisits(Ref ref, int pointId) {
  return ref.watch(pointRepositoryProvider).listVisits(pointId);
}

@riverpod
class PointActions extends _$PointActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create({
    required String name,
    String? description,
    required double latitude,
    required double longitude,
    String? address,
    String? fishType,
    bool isPublic = false,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(pointRepositoryProvider).createPoint(
          name: name,
          description: description,
          latitude: latitude,
          longitude: longitude,
          address: address,
          fishType: fishType,
          isPublic: isPublic,
        ));
    if (state is AsyncData) ref.invalidate(pointsProvider);
    return state is AsyncData;
  }

  Future<bool> createVisit(
    int pointId, {
    required DateTime visitDate,
    String? title,
    String? content,
    String? memo,
    bool isPublic = false,
    List<TackleEntryData> tackles = const [],
    List<CatchRecordData> catches = const [],
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(pointRepositoryProvider).createVisit(
          pointId,
          visitDate: visitDate,
          title: title,
          content: content,
          memo: memo,
          isPublic: isPublic,
          tackles: tackles,
          catches: catches,
        ));
    if (state is AsyncData) ref.invalidate(pointVisitsProvider(pointId));
    return state is AsyncData;
  }
}
