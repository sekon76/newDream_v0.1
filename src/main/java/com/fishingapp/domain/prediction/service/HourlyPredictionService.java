package com.fishingapp.domain.prediction.service;

import com.fishingapp.domain.point.entity.TideInfo;
import com.fishingapp.domain.prediction.dto.HourlyPredictionResponse;
import com.fishingapp.global.external.TideClient;
import com.fishingapp.global.external.WeatherClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class HourlyPredictionService {

    private final WeatherClient weatherClient;
    private final TideClient tideClient;

    public HourlyPredictionResponse predict(double latitude, double longitude, LocalDate date) {
        var hourlyWeather = weatherClient.fetchHourly(latitude, longitude, date);
        TideInfo tide = tideClient.fetch(latitude, longitude, date);

        return new HourlyPredictionResponse(date, latitude, longitude, hourlyWeather, tide);
    }
}
