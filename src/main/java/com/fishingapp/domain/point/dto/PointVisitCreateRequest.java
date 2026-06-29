package com.fishingapp.domain.point.dto;

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

    private List<TackleEntryRequest> tackles = new ArrayList<>();
}
