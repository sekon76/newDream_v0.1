import 'package:fishing_app/features/diary/data/diary_model.dart';
import 'package:fishing_app/features/diary/data/diary_repository.dart';
import 'package:fishing_app/features/point/data/point_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'diary_provider.g.dart';

@riverpod
Future<List<Diary>> diaries(Ref ref) {
  return ref.watch(diaryRepositoryProvider).listDiaries();
}

@riverpod
class DiaryActions extends _$DiaryActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create({
    required DateTime visitDate,
    String? title,
    String? content,
    String? memo,
    int? pointId,
    required double latitude,
    required double longitude,
    String? address,
    List<TackleEntryData> tackles = const [],
    List<CatchRecordData> catches = const [],
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(diaryRepositoryProvider).createDiary(
          visitDate: visitDate,
          title: title,
          content: content,
          memo: memo,
          pointId: pointId,
          latitude: latitude,
          longitude: longitude,
          address: address,
          tackles: tackles,
          catches: catches,
        ));
    if (state is AsyncData) {
      ref.invalidate(diariesProvider);
    }
    return state is AsyncData;
  }

  Future<bool> update(
    int diaryId, {
    required DateTime visitDate,
    String? title,
    String? content,
    String? memo,
    List<TackleEntryData> tackles = const [],
    List<CatchRecordData> catches = const [],
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(diaryRepositoryProvider).updateDiary(
          diaryId,
          visitDate: visitDate,
          title: title,
          content: content,
          memo: memo,
          tackles: tackles,
          catches: catches,
        ));
    if (state is AsyncData) {
      ref.invalidate(diariesProvider);
    }
    return state is AsyncData;
  }

  Future<bool> delete(int diaryId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(diaryRepositoryProvider).deleteDiary(diaryId));
    if (state is AsyncData) {
      ref.invalidate(diariesProvider);
    }
    return state is AsyncData;
  }
}
