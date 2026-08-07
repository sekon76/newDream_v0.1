package com.fishingapp.global.external;

import com.fishingapp.domain.prediction.dto.HourlyWaterTempItem;

import java.time.LocalDate;
import java.util.List;

public interface WaterTempClient {
    /** 관측소 원본 자료는 시간대별로 내려오므로 항상 리스트로 반환한다. 실측 자료라 오늘 날짜가 아니면 빈 리스트. */
    List<HourlyWaterTempItem> fetchHourly(double latitude, double longitude, LocalDate date);
}
