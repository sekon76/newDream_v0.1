import 'package:dio/dio.dart';
import 'package:fishing_app/core/api/api_client.dart';
import 'package:fishing_app/features/prediction/data/prediction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'prediction_repository.g.dart';

@riverpod
PredictionRepository predictionRepository(Ref ref) {
  return PredictionRepository(ref.watch(dioProvider));
}

class PredictionRepository {
  final Dio _dio;
  PredictionRepository(this._dio);

  Future<PredictionResult> predict(double lat, double lon, {String? date}) async {
    final res = await _dio.get('/predictions', queryParameters: {
      'lat': lat,
      'lon': lon,
      if (date != null) 'date': date,
    });
    return PredictionResult.fromJson(res.data as Map<String, dynamic>);
  }

  Future<HourlyPredictionResult> predictHourly(double lat, double lon, {String? date}) async {
    final res = await _dio.get('/predictions/hourly', queryParameters: {
      'lat': lat,
      'lon': lon,
      if (date != null) 'date': date,
    });
    return HourlyPredictionResult.fromJson(res.data as Map<String, dynamic>);
  }
}
