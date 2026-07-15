package com.fishingapp.domain.diary.dto;

import com.fishingapp.domain.diary.entity.DiaryTackleEntry;
import lombok.Getter;

@Getter
public class DiaryTackleEntryResponse {
    private final Long id;
    private final String tackleType;
    private final String bait;
    private final String fishCaught;
    private final Integer catchCount;
    private final String memo;

    public DiaryTackleEntryResponse(DiaryTackleEntry entry) {
        this.id = entry.getId();
        this.tackleType = entry.getTackleType();
        this.bait = entry.getBait();
        this.fishCaught = entry.getFishCaught();
        this.catchCount = entry.getCatchCount();
        this.memo = entry.getMemo();
    }
}
