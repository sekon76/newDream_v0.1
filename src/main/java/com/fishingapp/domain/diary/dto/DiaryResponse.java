package com.fishingapp.domain.diary.dto;

import com.fishingapp.domain.diary.entity.Diary;
import com.fishingapp.domain.point.entity.TideInfo;
import com.fishingapp.domain.point.entity.WeatherInfo;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
public class DiaryResponse {
    private final Long id;
    private final Long pointId;
    private final String pointName;
    private final LocalDate visitDate;
    private final String title;
    private final String content;
    private final String memo;
    private final Double latitude;
    private final Double longitude;
    private final String address;
    private final WeatherInfo weather;
    private final TideInfo tide;
    private final List<DiaryTackleEntryResponse> tackles;
    private final List<DiaryCatchResponse> catches;
    private final LocalDateTime createdAt;
    private final LocalDateTime updatedAt;

    public DiaryResponse(Diary diary) {
        this.id = diary.getId();
        this.pointId = diary.getFishingPoint() != null ? diary.getFishingPoint().getId() : null;
        this.pointName = diary.getFishingPoint() != null ? diary.getFishingPoint().getName() : null;
        this.visitDate = diary.getVisitDate();
        this.title = diary.getTitle();
        this.content = diary.getContent();
        this.memo = diary.getMemo();
        this.latitude = diary.getLatitude();
        this.longitude = diary.getLongitude();
        this.address = diary.getAddress();
        this.weather = diary.getWeather();
        this.tide = diary.getTide();
        this.tackles = diary.getTackles().stream()
                .map(DiaryTackleEntryResponse::new)
                .toList();
        this.catches = diary.getCatches().stream()
                .map(DiaryCatchResponse::new)
                .toList();
        this.createdAt = diary.getCreatedAt();
        this.updatedAt = diary.getUpdatedAt();
    }
}
