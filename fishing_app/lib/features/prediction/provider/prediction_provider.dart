import 'package:fishing_app/features/prediction/data/fish_species.dart';
import 'package:fishing_app/features/prediction/data/prediction_model.dart';
import 'package:fishing_app/features/prediction/data/prediction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'prediction_provider.g.dart';

const _defaultLat = 37.5665;
const _defaultLon = 126.9780;

class LocationState {
  final String name;
  final double lat;
  final double lon;

  const LocationState({required this.name, required this.lat, required this.lon});
}

@riverpod
class SelectedLocation extends _$SelectedLocation {
  @override
  LocationState? build() => null;

  void select(LocationState loc) => state = loc;
  void reset() => state = null;
}

@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime date) => state = date;
}

@riverpod
class SelectedFish extends _$SelectedFish {
  @override
  FishSpecies? build() => null;

  void select(FishSpecies fish) => state = state?.name == fish.name ? null : fish;
  void clear() => state = null;
}

@riverpod
Future<PredictionResult> prediction(Ref ref) async {
  final selected = ref.watch(selectedLocationProvider);
  final date = ref.watch(selectedDateProvider);
  final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  double lat, lon;

  if (selected != null) {
    lat = selected.lat;
    lon = selected.lon;
  } else {
    (lat, lon) = await _getCurrentLatLon();
  }

  return ref.watch(predictionRepositoryProvider).predict(lat, lon, date: dateStr);
}


@riverpod
Future<List<LocationState>> locationSearch(Ref ref, String query) async {
  if (query.trim().isEmpty) return [];
  try {
    final locations = await locationFromAddress(query);
    final results = <LocationState>[];
    for (final loc in locations.take(5)) {
      final placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
      final pm = placemarks.isNotEmpty ? placemarks.first : null;
      final name = _buildPlaceName(pm, query);
      results.add(LocationState(name: name, lat: loc.latitude, lon: loc.longitude));
    }
    return results;
  } catch (_) {
    return [];
  }
}

String _buildPlaceName(Placemark? pm, String fallback) {
  if (pm == null) return fallback;
  // 시/도 → 시/군/구 → 동/읍/면 → 도로명 → 건물번호 순으로 상세 주소 구성
  final parts = [
    pm.administrativeArea,
    pm.locality,
    pm.subLocality,
    pm.thoroughfare,
    pm.subThoroughfare,
  ].where((s) => s != null && s.isNotEmpty).toSet().toList();
  return parts.isNotEmpty ? parts.join(' ') : fallback;
}

/// 위경도를 주소 문자열로 역지오코딩한다. 지도에서 직접 위치를 고른 뒤
/// 표시용 이름을 만들 때 사용.
Future<String> reverseGeocodeName(double lat, double lon, {String fallback = '선택한 위치'}) async {
  try {
    final placemarks = await placemarkFromCoordinates(lat, lon);
    final pm = placemarks.isNotEmpty ? placemarks.first : null;
    return _buildPlaceName(pm, fallback);
  } catch (_) {
    return fallback;
  }
}

Future<(double, double)> _getCurrentLatLon() async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return (_defaultLat, _defaultLon);
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 5),
      ),
    );
    return (pos.latitude, pos.longitude);
  } catch (_) {
    return (_defaultLat, _defaultLon);
  }
}
