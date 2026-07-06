class WeatherData {
  final String? condition;
  final double? temperature;
  final int? humidity;
  final double? windSpeed;
  final String? windDirection;
  final double? waveHeight;

  WeatherData({
    this.condition,
    this.temperature,
    this.humidity,
    this.windSpeed,
    this.windDirection,
    this.waveHeight,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
        condition: json['condition'] as String?,
        temperature: (json['temperature'] as num?)?.toDouble(),
        humidity: json['humidity'] as int?,
        windSpeed: (json['windSpeed'] as num?)?.toDouble(),
        windDirection: json['windDirection'] as String?,
        waveHeight: (json['waveHeight'] as num?)?.toDouble(),
      );
}

class TideData {
  final String? highTideTime1;
  final int? highTideHeight1;
  final String? lowTideTime1;
  final int? lowTideHeight1;
  final String? highTideTime2;
  final int? highTideHeight2;
  final String? lowTideTime2;
  final int? lowTideHeight2;

  TideData({
    this.highTideTime1,
    this.highTideHeight1,
    this.lowTideTime1,
    this.lowTideHeight1,
    this.highTideTime2,
    this.highTideHeight2,
    this.lowTideTime2,
    this.lowTideHeight2,
  });

  factory TideData.fromJson(Map<String, dynamic> json) => TideData(
        highTideTime1: json['highTideTime1'] as String?,
        highTideHeight1: json['highTideHeight1'] as int?,
        lowTideTime1: json['lowTideTime1'] as String?,
        lowTideHeight1: json['lowTideHeight1'] as int?,
        highTideTime2: json['highTideTime2'] as String?,
        highTideHeight2: json['highTideHeight2'] as int?,
        lowTideTime2: json['lowTideTime2'] as String?,
        lowTideHeight2: json['lowTideHeight2'] as int?,
      );
}

class HourlyWeatherItem {
  final String time; // "0600", "0900", "1200" ...
  final WeatherData weather;

  HourlyWeatherItem({required this.time, required this.weather});

  factory HourlyWeatherItem.fromJson(Map<String, dynamic> json) => HourlyWeatherItem(
        time: json['time'] as String,
        weather: WeatherData.fromJson(json['weather'] as Map<String, dynamic>),
      );

  String get displayTime {
    final h = int.tryParse(time.substring(0, 2)) ?? 0;
    final suffix = h < 12 ? '오전' : '오후';
    final display = h == 0 ? 12 : h > 12 ? h - 12 : h;
    return '$suffix $display시';
  }
}

class HourlyPredictionResult {
  final String date;
  final double latitude;
  final double longitude;
  final List<HourlyWeatherItem> hourlyWeather;
  final TideData? tide;

  HourlyPredictionResult({
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.hourlyWeather,
    this.tide,
  });

  factory HourlyPredictionResult.fromJson(Map<String, dynamic> json) => HourlyPredictionResult(
        date: json['date'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        hourlyWeather: (json['hourlyWeather'] as List<dynamic>)
            .map((e) => HourlyWeatherItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        tide: json['tide'] != null
            ? TideData.fromJson(json['tide'] as Map<String, dynamic>)
            : null,
      );
}

class PredictionResult {
  final String date;
  final double latitude;
  final double longitude;
  final WeatherData? weather;
  final TideData? tide;
  final int? fishingScore;
  final String? fishingGrade;
  final List<HourlyWeatherItem> hourlyWeather;

  PredictionResult({
    required this.date,
    required this.latitude,
    required this.longitude,
    this.weather,
    this.tide,
    this.fishingScore,
    this.fishingGrade,
    this.hourlyWeather = const [],
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) => PredictionResult(
        date: json['date'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        weather: json['weather'] != null
            ? WeatherData.fromJson(json['weather'] as Map<String, dynamic>)
            : null,
        tide: json['tide'] != null
            ? TideData.fromJson(json['tide'] as Map<String, dynamic>)
            : null,
        fishingScore: json['fishingScore'] as int?,
        fishingGrade: json['fishingGrade'] as String?,
        hourlyWeather: (json['hourlyWeather'] as List<dynamic>? ?? [])
            .map((e) => HourlyWeatherItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
