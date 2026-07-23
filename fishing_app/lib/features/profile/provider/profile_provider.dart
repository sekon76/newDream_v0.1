import 'package:fishing_app/features/profile/data/profile_model.dart';
import 'package:fishing_app/features/profile/data/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

@riverpod
Future<UserProfile> myProfile(Ref ref) {
  return ref.watch(profileRepositoryProvider).getMe();
}

@riverpod
Future<List<PreferredRegion>> preferredRegions(Ref ref) {
  return ref.watch(profileRepositoryProvider).listPreferredRegions();
}

/// 조과예측 화면이 처음 로드될 때 자동 적용할 기본 선호 지역(있으면).
@riverpod
Future<PreferredRegion?> defaultPreferredRegion(Ref ref) async {
  final regions = await ref.watch(preferredRegionsProvider.future);
  for (final region in regions) {
    if (region.isDefault) return region;
  }
  return null;
}

@riverpod
class ProfileActions extends _$ProfileActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> changePassword({required String currentPassword, required String newPassword}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(profileRepositoryProvider).changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ));
    return state is AsyncData;
  }

  Future<bool> createRegion({
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    bool isDefault = false,
    List<PreferredFishSpeciesData> species = const [],
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(profileRepositoryProvider).createPreferredRegion(
          name: name,
          latitude: latitude,
          longitude: longitude,
          address: address,
          isDefault: isDefault,
          species: species,
        ));
    if (state is AsyncData) {
      ref.invalidate(preferredRegionsProvider);
      ref.invalidate(defaultPreferredRegionProvider);
    }
    return state is AsyncData;
  }

  Future<bool> updateRegion(
    int regionId, {
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    bool isDefault = false,
    List<PreferredFishSpeciesData> species = const [],
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(profileRepositoryProvider).updatePreferredRegion(
          regionId,
          name: name,
          latitude: latitude,
          longitude: longitude,
          address: address,
          isDefault: isDefault,
          species: species,
        ));
    if (state is AsyncData) {
      ref.invalidate(preferredRegionsProvider);
      ref.invalidate(defaultPreferredRegionProvider);
    }
    return state is AsyncData;
  }

  Future<bool> deleteRegion(int regionId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(profileRepositoryProvider).deletePreferredRegion(regionId));
    if (state is AsyncData) {
      ref.invalidate(preferredRegionsProvider);
      ref.invalidate(defaultPreferredRegionProvider);
    }
    return state is AsyncData;
  }
}
