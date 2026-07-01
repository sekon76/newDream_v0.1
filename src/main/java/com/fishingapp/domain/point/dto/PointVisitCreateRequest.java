package com.fishingapp.domain.point.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Getter
public class PointVisitCreateRequest {

    @NotNull(message = "방문 날짜를 입력해주세요.")
    private LocalDate visitDate;

    private String memo;

    private String title;

    private String content;

    @JsonProperty("isPublic")
    private boolean isPublic = false;

    private List<TackleEntryRequest> tackles = new ArrayList<>();

    @Valid
    private List<CatchRecordRequest> catches = new ArrayList<>();
}
