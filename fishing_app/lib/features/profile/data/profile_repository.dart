import 'package:dio/dio.dart';
import 'package:fishing_app/core/api/api_client.dart';
import 'package:fishing_app/features/profile/data/profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(ref.watch(dioProvider));
}

class ProfileRepository {
  final Dio _dio;
  ProfileRepository(this._dio);

  Future<UserProfile> getMe() async {
    final res = await _dio.get('/users/me');
    return UserProfile.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) {
    return _dio.put('/users/me/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<List<PreferredRegion>> listPreferredRegions() async {
    final res = await _dio.get('/preferred-regions');
    return (res.data as List).map((e) => PreferredRegion.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PreferredRegion> createPreferredRegion({
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    bool isDefault = false,
    List<PreferredFishSpeciesData> species = const [],
  }) async {
    final res = await _dio.post('/preferred-regions', data: _payload(
      name: name,
      latitude: latitude,
      longitude: longitude,
      address: address,
      isDefault: isDefault,
      species: species,
    ));
    return PreferredRegion.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PreferredRegion> updatePreferredRegion(
    int regionId, {
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    bool isDefault = false,
    List<PreferredFishSpeciesData> species = const [],
  }) async {
    final res = await _dio.put('/preferred-regions/$regionId', data: _payload(
      name: name,
      latitude: latitude,
      longitude: longitude,
      address: address,
      isDefault: isDefault,
      species: species,
    ));
    return PreferredRegion.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deletePreferredRegion(int regionId) => _dio.delete('/preferred-regions/$regionId');

  Map<String, dynamic> _payload({
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    required bool isDefault,
    required List<PreferredFishSpeciesData> species,
  }) {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'isDefault': isDefault,
      'species': species.map((e) => e.toJson()).toList(),
    };
  }
}
