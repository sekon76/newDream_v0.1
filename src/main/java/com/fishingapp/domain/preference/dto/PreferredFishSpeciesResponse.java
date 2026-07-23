package com.fishingapp.domain.preference.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fishingapp.domain.preference.entity.PreferredFishSpecies;
import lombok.AccessLevel;
import lombok.Getter;

@Getter
public class PreferredFishSpeciesResponse {
    private final Long id;
    private final String speciesName;

    // Lombok이 생성하는 isDefault() getter를 Jackson이 "default"로 stripping해서
    // isDefault 필드에 @JsonProperty를 붙이면 "default"/"isDefault"가 중복 노출된다.
    // Lombok 자동 getter를 끄고 이름을 고정한 getter를 직접 선언해 하나로만 나가게 한다.
    @Getter(AccessLevel.NONE)
    private final boolean isDefault;

    public PreferredFishSpeciesResponse(PreferredFishSpecies entity) {
        this.id = entity.getId();
        this.speciesName = entity.getSpeciesName();
        this.isDefault = entity.isDefault();
    }

    @JsonProperty("isDefault")
    public boolean isDefault() {
        return isDefault;
    }
}
