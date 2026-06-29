package com.fishingapp.domain.point.dto;

import jakarta.validation.constraints.*;
import lombok.Getter;

@Getter
public class PointUpdateRequest {

    @NotBlank(message = "포인트 이름을 입력해주세요.")
    private String name;

    private String description;

    @NotNull(message = "위도를 입력해주세요.")
    @DecimalMin(value = "-90.0", message = "위도는 -90 ~ 90 사이여야 합니다.")
    @DecimalMax(value = "90.0",  message = "위도는 -90 ~ 90 사이여야 합니다.")
    private Double latitude;

    @NotNull(message = "경도를 입력해주세요.")
    @DecimalMin(value = "-180.0", message = "경도는 -180 ~ 180 사이여야 합니다.")
    @DecimalMax(value = "180.0",  message = "경도는 -180 ~ 180 사이여야 합니다.")
    private Double longitude;

    private String address;

    private String fishType;

    @NotNull(message = "공개 여부를 선택해주세요.")
    private Boolean isPublic;
}
