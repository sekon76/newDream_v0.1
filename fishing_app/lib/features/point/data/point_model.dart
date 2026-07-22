import 'package:fishing_app/features/prediction/data/prediction_model.dart';

class FishingPoint {
  final int id;
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? fishType;
  final bool isPublic;
  final DateTime? createdAt;

  FishingPoint({
    required this.id,
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.address,
    this.fishType,
    this.isPublic = false,
    this.createdAt,
  });

  factory FishingPoint.fromJson(Map<String, dynamic> json) => FishingPoint(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        address: json['address'] as String?,
        fishType: json['fishType'] as String?,
        isPublic: json['isPublic'] as bool? ?? false,
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      );
}

class TackleEntryData {
  final String? tackleType;
  final String? bait;
  final String? fishCaught;
  final int? catchCount;
  final String? memo;

  TackleEntryData({this.tackleType, this.bait, this.fishCaught, this.catchCount, this.memo});

  factory TackleEntryData.fromJson(Map<String, dynamic> json) => TackleEntryData(
        tackleType: json['tackleType'] as String?,
        bait: json['bait'] as String?,
        fishCaught: json['fishCaught'] as String?,
        catchCount: json['catchCount'] as int?,
        memo: json['memo'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'tackleType': tackleType,
        'bait': bait,
        'fishCaught': fishCaught,
        'catchCount': catchCount,
        'memo': memo,
      };
}

class CatchRecordData {
  final String fishName;
  final int count;
  final int? sizeCm;
  final int? weightG;
  final String? caughtTime; // "HH:mm" 형식

  CatchRecordData({
    required this.fishName,
    required this.count,
    this.sizeCm,
    this.weightG,
    this.caughtTime,
  });

  factory CatchRecordData.fromJson(Map<String, dynamic> json) => CatchRecordData(
        fishName: json['fishName'] as String,
        count: json['count'] as int,
        sizeCm: json['sizeCm'] as int?,
        weightG: json['weightG'] as int?,
        caughtTime: (json['caughtTime'] as String?)?.substring(0, 5),
      );

  Map<String, dynamic> toJson() => {
        'fishName': fishName,
        'count': count,
        'sizeCm': sizeCm,
        'weightG': weightG,
        'caughtTime': caughtTime,
      };
}

class PointVisit {
  final int id;
  final DateTime visitDate;
  final String? memo;
  final String? title;
  final String? content;
  final bool isPublic;
  final WeatherData? weather;
  final TideData? tide;
  final List<TackleEntryData> tackles;
  final List<CatchRecordData> catches;
  final DateTime? createdAt;

  PointVisit({
    required this.id,
    required this.visitDate,
    this.memo,
    this.title,
    this.content,
    this.isPublic = false,
    this.weather,
    this.tide,
    this.tackles = const [],
    this.catches = const [],
    this.createdAt,
  });

  factory PointVisit.fromJson(Map<String, dynamic> json) => PointVisit(
        id: json['id'] as int,
        visitDate: DateTime.parse(json['visitDate'] as String),
        memo: json['memo'] as String?,
        title: json['title'] as String?,
        content: json['content'] as String?,
        isPublic: json['isPublic'] as bool? ?? false,
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
