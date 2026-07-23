package com.fishingapp.domain.preference.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fishingapp.domain.preference.entity.PreferredFishSpecies;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class PreferredFishSpeciesRequest {

    @NotBlank(message = "어종명을 입력해주세요.")
    private String speciesName;

    // Lombok의 isDefault() getter가 Jackson 프로퍼티명 추론에서 "default"로 잡혀
    // JSON의 "isDefault" 키와 안 맞아 값이 안 들어오는 문제가 있어 명시적으로 고정
    @JsonProperty("isDefault")
    private boolean isDefault = false;

    public PreferredFishSpecies toEntity() {
        return PreferredFishSpecies.builder()
                .speciesName(speciesName)
                .isDefault(isDefault)
                .build();
    }
}
