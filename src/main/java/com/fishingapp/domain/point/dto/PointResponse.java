package com.fishingapp.domain.point.dto;

import com.fishingapp.domain.point.entity.FishingPoint;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class PointResponse {

    private final Long id;
    private final String name;
    private final String description;
    private final Double latitude;
    private final Double longitude;
    private final String address;
    private final String fishType;
    private final boolean isPublic;
    private final LocalDateTime createdAt;
    private final LocalDateTime updatedAt;

    public PointResponse(FishingPoint point) {
        this.id = point.getId();
        this.name = point.getName();
        this.description = point.getDescription();
        this.latitude = point.getLatitude();
        this.longitude = point.getLongitude();
        this.address = point.getAddress();
        this.fishType = point.getFishType();
        this.isPublic = point.isPublic();
        this.createdAt = point.getCreatedAt();
        this.updatedAt = point.getUpdatedAt();
    }
}
