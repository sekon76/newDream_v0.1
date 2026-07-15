package com.fishingapp.domain.diary.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Getter
public class DiaryUpdateRequest {

    @NotNull(message = "날짜를 입력해주세요.")
    private LocalDate visitDate;

    private String title;

    private String content;

    private String memo;

    private List<DiaryTackleEntryRequest> tackles = new ArrayList<>();

    @Valid
    private List<DiaryCatchRequest> catches = new ArrayList<>();
}
