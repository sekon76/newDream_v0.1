package com.fishingapp.domain.preference.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.ArrayList;
import java.util.List;

@Getter
public class PreferredRegionRequest {

    @NotBlank(message = "지역 이름을 입력해주세요.")
    private String name;

    @NotNull(message = "위도를 입력해주세요.")
    @DecimalMin(value = "-90.0", message = "위도는 -90 ~ 90 사이여야 합니다.")
    @DecimalMax(value = "90.0", message = "위도는 -90 ~ 90 사이여야 합니다.")
    private Double latitude;

    @NotNull(message = "경도를 입력해주세요.")
    @DecimalMin(value = "-180.0", message = "경도는 -180 ~ 180 사이여야 합니다.")
    @DecimalMax(value = "180.0", message = "경도는 -180 ~ 180 사이여야 합니다.")
    private Double longitude;

    private String address;

    @JsonProperty("isDefault")
    private boolean isDefault = false;

    @Valid
    private List<PreferredFishSpeciesRequest> species = new ArrayList<>();
}
