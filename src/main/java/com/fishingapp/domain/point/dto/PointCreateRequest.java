package com.fishingapp.domain.point.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.*;
import lombok.Getter;

@Getter
public class PointCreateRequest {

    @NotBlank(message = "포인트 이름을 입력해주세요.")
    private String name;

    private String description;

    // 커뮤니티 글쓰기는 위치 없이도 등록 가능해야 하므로 필수 아님 (null 허용)
    @DecimalMin(value = "-90.0", message = "위도는 -90 ~ 90 사이여야 합니다.")
    @DecimalMax(value = "90.0",  message = "위도는 -90 ~ 90 사이여야 합니다.")
    private Double latitude;

    @DecimalMin(value = "-180.0", message = "경도는 -180 ~ 180 사이여야 합니다.")
    @DecimalMax(value = "180.0",  message = "경도는 -180 ~ 180 사이여야 합니다.")
    private Double longitude;

    private String address;

    private String fishType;

    @JsonProperty("isPublic")
    private boolean isPublic = false;

    // 커뮤니티 글쓰기 화면에서 글을 담기 위한 용도로만 만들어진 포인트인지 여부.
    // true면 "내 포인트" 목록에 노출되지 않는다.
    @JsonProperty("communityOnly")
    private boolean communityOnly = false;
}
