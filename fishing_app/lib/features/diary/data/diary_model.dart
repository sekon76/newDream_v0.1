import 'package:fishing_app/features/point/data/point_model.dart';
import 'package:fishing_app/features/prediction/data/prediction_model.dart';

class Diary {
  final int id;
  final int? pointId;
  final String? pointName;
  final DateTime visitDate;
  final String? title;
  final String? content;
  final String? memo;
  final double? latitude;
  final double? longitude;
  final String? address;
  final WeatherData? weather;
  final TideData? tide;
  final List<TackleEntryData> tackles;
  final List<CatchRecordData> catches;
  final DateTime? createdAt;

  Diary({
    required this.id,
    this.pointId,
    this.pointName,
    required this.visitDate,
    this.title,
    this.content,
    this.memo,
    this.latitude,
    this.longitude,
    this.address,
    this.weather,
    this.tide,
    this.tackles = const [],
    this.catches = const [],
    this.createdAt,
  });

  factory Diary.fromJson(Map<String, dynamic> json) => Diary(
        id: json['id'] as int,
        pointId: json['pointId'] as int?,
        pointName: json['pointName'] as String?,
        visitDate: DateTime.parse(json['visitDate'] as String),
        title: json['title'] as String?,
        content: json['content'] as String?,
        memo: json['memo'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        address: json['address'] as String?,
        weather: json['weather'] != null ? WeatherData.fromJson(json['weather'] as Map<String, dynamic>) : null,
        tide: json['tide'] != null ? TideData.fromJson(json['tide'] as Map<String, dynamic>) : null,
        tackles: (json['tackles'] as List<dynamic>? ?? [])
            .map((e) => TackleEntryData.fromJson(e as Map<String, dynamic>))
            .toList(),
        catches: (json['catches'] as List<dynamic>? ?? [])
            .map((e) => CatchRecordData.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      );
}
