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
    private final Double latitude;
    private final Double longitude;
    private final String memo;
    private final String title;
    private final String content;
    private final Boolean isPublic;
    private final WeatherInfo weather;
    private final TideInfo tide;
    private final List<TackleEntryResponse> tackles;
    private final List<CatchRecordResponse> catches;
    private final LocalDateTime createdAt;
    private final LocalDateTime updatedAt;

    public PointVisitResponse(PointVisit visit) {
        this.id = visit.getId();
        this.visitDate = visit.getVisitDate();
        this.latitude = visit.getLatitude();
        this.longitude = visit.getLongitude();
        this.memo = visit.getMemo();
        this.title = visit.getTitle();
        this.content = visit.getContent();
        this.isPublic = visit.isPublic();
        this.weather = visit.getWeather();
        this.tide = visit.getTide();
        this.tackles = visit.getTackles().stream()
                .map(TackleEntryResponse::new)
                .toList();
        this.catches = visit.getCatches().stream()
                .map(CatchRecordResponse::new)
                .toList();
        this.createdAt = visit.getCreatedAt();
        this.updatedAt = visit.getUpdatedAt();
    }
}
