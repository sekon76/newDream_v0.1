package com.fishingapp.domain.diary.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Getter
public class DiaryCreateRequest {

    @NotNull(message = "날짜를 입력해주세요.")
    private LocalDate visitDate;

    private String title;

    private String content;

    private String memo;

    // 저장된 포인트와 연결하고 싶을 때만 입력 (선택)
    private Long pointId;

    @NotNull(message = "위도를 입력해주세요.")
    @DecimalMin(value = "-90.0", message = "위도는 -90 ~ 90 사이여야 합니다.")
    @DecimalMax(value = "90.0", message = "위도는 -90 ~ 90 사이여야 합니다.")
    private Double latitude;

    @NotNull(message = "경도를 입력해주세요.")
    @DecimalMin(value = "-180.0", message = "경도는 -180 ~ 180 사이여야 합니다.")
    @DecimalMax(value = "180.0", message = "경도는 -180 ~ 180 사이여야 합니다.")
    private Double longitude;

    private String address;

    private List<DiaryTackleEntryRequest> tackles = new ArrayList<>();

    @Valid
    private List<DiaryCatchRequest> catches = new ArrayList<>();
}
