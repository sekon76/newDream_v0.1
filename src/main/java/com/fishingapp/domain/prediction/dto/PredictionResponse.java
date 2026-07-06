package com.fishingapp.domain.prediction.dto;

import com.fishingapp.domain.point.entity.TideInfo;
import com.fishingapp.domain.point.entity.WeatherInfo;
import lombok.Getter;

import java.time.LocalDate;
import java.util.List;

@Getter
public class PredictionResponse {
    private final LocalDate date;
    private final double latitude;
    private final double longitude;
    private final WeatherInfo weather;
    private final TideInfo tide;
    private final Integer fishingScore;
    private final String fishingGrade;
    private final List<HourlyWeatherItem> hourlyWeather;

    public PredictionResponse(LocalDate date, double latitude, double longitude,
                              WeatherInfo weather, TideInfo tide,
                              Integer fishingScore, String fishingGrade,
                              List<HourlyWeatherItem> hourlyWeather) {
        this.date = date;
        this.latitude = latitude;
        this.longitude = longitude;
        this.weather = weather;
        this.tide = tide;
        this.fishingScore = fishingScore;
        this.fishingGrade = fishingGrade;
        this.hourlyWeather = hourlyWeather;
    }
}
