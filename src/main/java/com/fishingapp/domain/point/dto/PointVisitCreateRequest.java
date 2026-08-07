package com.fishingapp.domain.point.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Getter
public class PointVisitCreateRequest {

    @NotNull(message = "방문 날짜를 입력해주세요.")
    private LocalDate visitDate;

    // 지정하지 않으면(null) 포인트의 대표 위치를 그대로 사용한다.
    @DecimalMin(value = "-90.0", message = "위도는 -90 ~ 90 사이여야 합니다.")
    @DecimalMax(value = "90.0",  message = "위도는 -90 ~ 90 사이여야 합니다.")
    private Double latitude;

    @DecimalMin(value = "-180.0", message = "경도는 -180 ~ 180 사이여야 합니다.")
    @DecimalMax(value = "180.0",  message = "경도는 -180 ~ 180 사이여야 합니다.")
    private Double longitude;

    private String memo;

    private String title;

    private String content;

    @JsonProperty("isPublic")
    private boolean isPublic = false;

    private List<TackleEntryRequest> tackles = new ArrayList<>();

    @Valid
    private List<CatchRecordRequest> catches = new ArrayList<>();
}
