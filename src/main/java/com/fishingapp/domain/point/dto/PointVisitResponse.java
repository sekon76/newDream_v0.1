package com.fishingapp.domain.point.dto;

import com.fishingapp.domain.point.entity.PointVisit;
import com.fishingapp.domain.point.entity.TideInfo;
import com.fishingapp.domain.point.entity.WeatherInfo;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
public class PointVisitResponse {
    private final Long id;
    private final LocalDate visitDate;
    private final String memo;
    private final WeatherInfo weather;
    private final TideInfo tide;
    private final List<TackleEntryResponse> tackles;
    private final LocalDateTime createdAt;
    private final LocalDateTime updatedAt;

    public PointVisitResponse(PointVisit visit) {
        this.id = visit.getId();
        this.visitDate = visit.getVisitDate();
        this.memo = visit.getMemo();
        this.weather = visit.getWeather();
        this.tide = visit.getTide();
        this.tackles = visit.getTackles().stream()
                .map(TackleEntryResponse::new)
                .toList();
        this.createdAt = visit.getCreatedAt();
        this.updatedAt = visit.getUpdatedAt();
    }
}
