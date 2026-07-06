package com.fishingapp.domain.prediction.dto;

import com.fishingapp.domain.point.entity.TideInfo;

import java.time.LocalDate;
import java.util.List;

public record HourlyPredictionResponse(
        LocalDate date,
        double latitude,
        double longitude,
        List<HourlyWeatherItem> hourlyWeather,
        TideInfo tide
) {}
