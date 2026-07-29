import 'dart:convert';

import 'package:fishing_app/features/prediction/provider/prediction_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'recent_locations';
const maxRecentLocations = 5;

// 최근 검색해서 선택한 위치를 기기 로컬에만 최대 5개 저장한다(서버 연동 없음).
class RecentLocationRepository {
  Future<List<LocationState>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    return raw.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return LocationState(
        name: map['name'] as String,
        lat: (map['lat'] as num).toDouble(),
        lon: (map['lon'] as num).toDouble(),
      );
    }).toList();
  }

  Future<void> add(LocationState location) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await load();
    current.removeWhere((loc) => loc.name == location.name);
    current.insert(0, location);
    final trimmed = current.take(maxRecentLocations).toList();
    await prefs.setStringList(
      _prefsKey,
      trimmed.map((loc) => jsonEncode({'name': loc.name, 'lat': loc.lat, 'lon': loc.lon})).toList(),
    );
  }
}
