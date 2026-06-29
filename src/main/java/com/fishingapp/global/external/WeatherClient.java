package com.fishingapp.global.external;

import com.fishingapp.domain.point.entity.WeatherInfo;

import java.time.LocalDate;

public interface WeatherClient {
    WeatherInfo fetch(double latitude, double longitude, LocalDate date);
}
