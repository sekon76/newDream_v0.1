package com.fishingapp.domain.point.entity;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Embeddable
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeatherInfo {
    private String condition;       // 날씨 상태 (맑음, 구름많음, 흐림, 비, 눈)
    private Double temperature;     // 기온 (°C)
    private Integer humidity;       // 습도 (%)
    private Double windSpeed;       // 풍속 (m/s)
    private String windDirection;   // 풍향 (북, 북동, 동, ...)
    private Double waveHeight;      // 파고 (m)
}
