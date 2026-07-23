package com.fishingapp.domain.preference.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fishingapp.domain.preference.entity.PreferredRegion;
import lombok.AccessLevel;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
public class PreferredRegionResponse {
    private final Long id;
    private final String name;
    private final Double latitude;
    private final Double longitude;
    private final String address;

    // Lombok 자동 getter(isDefault() -> Jackson이 "default"로 축약)로 인한 중복 노출을
    // 막기 위해 자동 생성을 끄고 이름을 고정한 getter를 직접 선언한다.
    @Getter(AccessLevel.NONE)
    private final boolean isDefault;

    private final List<PreferredFishSpeciesResponse> species;
    private final LocalDateTime createdAt;
    private final LocalDateTime updatedAt;

    public PreferredRegionResponse(PreferredRegion region) {
        this.id = region.getId();
        this.name = region.getName();
        this.latitude = region.getLatitude();
        this.longitude = region.getLongitude();
        this.address = region.getAddress();
        this.isDefault = region.isDefault();
        this.species = region.getSpecies().stream().map(PreferredFishSpeciesResponse::new).toList();
        this.createdAt = region.getCreatedAt();
        this.updatedAt = region.getUpdatedAt();
    }

    @JsonProperty("isDefault")
    public boolean isDefault() {
        return isDefault;
    }
}
