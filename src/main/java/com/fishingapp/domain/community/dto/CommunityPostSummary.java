package com.fishingapp.domain.community.dto;

import com.fishingapp.domain.point.entity.PointVisit;
import lombok.Getter;

import java.time.LocalDate;
import java.util.List;

@Getter
public class CommunityPostSummary {
    private final Long visitId;
    private final String authorNickname;
    private final String pointName;
    private final String pointAddress;
    private final LocalDate visitDate;
    private final String title;
    private final String weatherCondition;
    private final List<CatchSummary> catches;
    private final long likeCount;
    private final long commentCount;
    private final boolean liked;

    public CommunityPostSummary(PointVisit visit, long likeCount, long commentCount, boolean liked) {
        this.visitId = visit.getId();
        this.authorNickname = visit.getFishingPoint().getUser().getNickname();
        this.pointName = visit.getFishingPoint().getName();
        this.pointAddress = visit.getFishingPoint().getAddress();
        this.visitDate = visit.getVisitDate();
        this.title = visit.getTitle();
        this.weatherCondition = visit.getWeather() != null ? visit.getWeather().getCondition() : null;
        this.catches = visit.getCatches().stream()
                .map(c -> new CatchSummary(c.getFishName(), c.getCount()))
                .toList();
        this.likeCount = likeCount;
        this.commentCount = commentCount;
        this.liked = liked;
    }

    public record CatchSummary(String fishName, Integer count) {}
}
