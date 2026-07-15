package com.fishingapp.domain.diary.dto;

import com.fishingapp.domain.diary.entity.DiaryCatchRecord;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.time.LocalTime;

@Getter
public class DiaryCatchRequest {

    @NotBlank(message = "어종명을 입력해주세요.")
    private String fishName;

    @NotNull(message = "마릿수를 입력해주세요.")
    @Min(value = 1, message = "마릿수는 1 이상이어야 합니다.")
    private Integer count;

    private Integer sizeCm;

    private Integer weightG;

    private LocalTime caughtTime;

    public DiaryCatchRecord toEntity() {
        return DiaryCatchRecord.builder()
                .fishName(fishName)
                .count(count)
                .sizeCm(sizeCm)
                .weightG(weightG)
                .caughtTime(caughtTime)
                .build();
    }
}
