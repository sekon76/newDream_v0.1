package com.fishingapp.domain.prediction.service;

import com.fishingapp.domain.point.entity.TideInfo;
import com.fishingapp.domain.point.entity.WeatherInfo;
import com.fishingapp.domain.prediction.dto.PredictionResponse;
import com.fishingapp.global.external.TideClient;
import com.fishingapp.global.external.WeatherClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class PredictionService {

    private final WeatherClient weatherClient;
    private final TideClient tideClient;

    public PredictionResponse predict(double latitude, double longitude, LocalDate date) {
        WeatherInfo weather = weatherClient.fetch(latitude, longitude, date);
        TideInfo tide = tideClient.fetch(latitude, longitude, date);
        var hourlyWeather = weatherClient.fetchHourly(latitude, longitude, date);

        boolean nearCoast = tideClient.isNearCoast(latitude, longitude);
        Integer score = (!nearCoast || (weather == null && tide == null)) ? null : calcScore(weather, tide);
        String grade = nearCoast ? toGrade(score) : "예측 불가 (바다와 너무 멉니다)";

        return new PredictionResponse(date, latitude, longitude, weather, tide, score, grade, hourlyWeather);
    }

    private int calcScore(WeatherInfo weather, TideInfo tide) {
        int score = 50;

        if (weather != null) {
            // 날씨 상태
            if (weather.getCondition() != null) {
                score += switch (weather.getCondition()) {
                    case "맑음"    -> 20;
                    case "구름많음" -> 10;
                    case "흐림"    -> 0;
                    case "소나기"  -> -15;
                    case "비", "비/눈" -> -20;
                    case "눈"      -> -25;
                    default        -> 0;
                };
            }
            // 기온
            if (weather.getTemperature() != null) {
                double t = weather.getTemperature();
                if (t >= 15 && t <= 25)       score += 15;
                else if (t >= 10 && t < 30)   score += 10;
                else if (t >= 5 && t < 10)    score += 5;
                else if (t < 0)               score -= 10;
                else                          score -= 5;
            }
            // 풍속
            if (weather.getWindSpeed() != null) {
                double w = weather.getWindSpeed();
                if (w < 3)       score += 15;
                else if (w < 6)  score += 5;
                else if (w < 10) score -= 10;
                else             score -= 20;
            }
            // 파고
            if (weather.getWaveHeight() != null) {
                double h = weather.getWaveHeight();
                if (h < 0.5)     score += 5;
                else if (h < 1)  score += 0;
                else if (h < 1.5) score -= 10;
                else             score -= 20;
            }
        }

        // 조석 범위 (만조-간조 높이차)
        if (tide != null && tide.getHighTideHeight1() != null && tide.getLowTideHeight1() != null) {
            int range = tide.getHighTideHeight1() - tide.getLowTideHeight1();
            if (range > 400)      score += 15;
            else if (range > 200) score += 10;
            else if (range > 100) score += 5;
        }

        return Math.max(0, Math.min(100, score));
    }

    private String toGrade(Integer score) {
        if (score == null) return "예측 불가";
        if (score >= 80)   return "매우 좋음";
        if (score >= 60)   return "좋음";
        if (score >= 40)   return "보통";
        if (score >= 20)   return "나쁨";
        return "매우 나쁨";
    }
}
