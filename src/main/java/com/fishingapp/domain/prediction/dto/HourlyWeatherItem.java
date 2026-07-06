package com.fishingapp.domain.prediction.dto;

import com.fishingapp.domain.point.entity.WeatherInfo;

public record HourlyWeatherItem(String time, WeatherInfo weather) {}
