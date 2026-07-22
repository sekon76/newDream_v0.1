import 'package:fishing_app/features/community/provider/community_provider.dart';
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
    if (state is AsyncData) {
      ref.invalidate(pointsProvider);
      // 포인트를 공개로 등록하면 백엔드가 커뮤니티 안내 게시글을 자동으로 만든다.
      if (isPublic) ref.invalidate(communityFeedProvider);
    }
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
    if (state is AsyncData) {
      ref.invalidate(pointVisitsProvider(pointId));
      if (isPublic) ref.invalidate(communityFeedProvider);
    }
    return state is AsyncData;
  }

  /// 커뮤니티 글쓰기: 위치 정보로 포인트를 새로 만들고, 그 아래에 공개 방문기록(글)을 등록한다.
  /// 위치는 선택 사항 — 지정하지 않으면 위치 없는 포인트로 등록된다.
  Future<bool> createCommunityPost({
    required String title,
    required String content,
    String? locationName,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final point = await ref.read(pointRepositoryProvider).createPoint(
            name: locationName ?? '위치 미지정',
            latitude: latitude,
            longitude: longitude,
            address: address ?? locationName,
            communityOnly: true,
          );
      await ref.read(pointRepositoryProvider).createVisit(
            point.id,
            visitDate: DateTime.now(),
            title: title,
            content: content,
            isPublic: true,
          );
    });
    if (state is AsyncData) {
      ref.invalidate(pointsProvider);
      ref.invalidate(communityFeedProvider);
    }
    return state is AsyncData;
  }

  Future<bool> updateVisit(
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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(pointRepositoryProvider).updateVisit(
          pointId,
          visitId,
          visitDate: visitDate,
          title: title,
          content: content,
          memo: memo,
          isPublic: isPublic,
          tackles: tackles,
          catches: catches,
        ));
    if (state is AsyncData) {
      ref.invalidate(pointVisitsProvider(pointId));
      ref.invalidate(communityFeedProvider);
      ref.invalidate(communityPostDetailProvider(visitId));
    }
    return state is AsyncData;
  }
}
