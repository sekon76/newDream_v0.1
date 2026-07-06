package com.fishingapp.global.external;

import com.fishingapp.domain.point.entity.WeatherInfo;
import com.fishingapp.domain.prediction.dto.HourlyWeatherItem;

import java.time.LocalDate;
import java.util.List;

public interface WeatherClient {
    WeatherInfo fetch(double latitude, double longitude, LocalDate date);

    default List<HourlyWeatherItem> fetchHourly(double latitude, double longitude, LocalDate date) {
        WeatherInfo single = fetch(latitude, longitude, date);
        return single == null ? List.of() : List.of(new HourlyWeatherItem("1200", single));
    }
}
