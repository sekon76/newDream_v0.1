package com.fishingapp.domain.community.dto;

import com.fishingapp.domain.point.dto.CatchRecordResponse;
import com.fishingapp.domain.point.dto.TackleEntryResponse;
import com.fishingapp.domain.point.entity.PointVisit;
import com.fishingapp.domain.point.entity.TideInfo;
import com.fishingapp.domain.point.entity.WeatherInfo;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
public class CommunityPostDetail {
    private final Long visitId;
    private final String authorNickname;
    private final String pointName;
    private final String pointAddress;
    private final LocalDate visitDate;
    private final String title;
    private final String content;
    private final String memo;
    private final WeatherInfo weather;
    private final TideInfo tide;
    private final List<TackleEntryResponse> tackles;
    private final List<CatchRecordResponse> catches;
    private final LocalDateTime createdAt;

    public CommunityPostDetail(PointVisit visit) {
        this.visitId = visit.getId();
        this.authorNickname = visit.getFishingPoint().getUser().getNickname();
        this.pointName = visit.getFishingPoint().getName();
        this.pointAddress = visit.getFishingPoint().getAddress();
        this.visitDate = visit.getVisitDate();
        this.title = visit.getTitle();
        this.content = visit.getContent();
        this.memo = visit.getMemo();
        this.weather = visit.getWeather();
        this.tide = visit.getTide();
        this.tackles = visit.getTackles().stream()
                .map(TackleEntryResponse::new)
                .toList();
        this.catches = visit.getCatches().stream()
                .map(CatchRecordResponse::new)
                .toList();
        this.createdAt = visit.getCreatedAt();
    }
}
