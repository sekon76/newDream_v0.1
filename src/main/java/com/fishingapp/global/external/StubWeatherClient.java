package com.fishingapp.global.external;

import com.fishingapp.domain.point.entity.WeatherInfo;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class StubWeatherClient implements WeatherClient {

    @Override
    public WeatherInfo fetch(double latitude, double longitude, LocalDate date) {
        // TODO: 기상청 단기예보 API 연동 — 예측 도메인에서 구현
        return null;
    }
}
