package com.fishingapp.domain.point.dto;

import com.fishingapp.domain.point.entity.TackleEntry;
import lombok.Getter;

@Getter
public class TackleEntryResponse {
    private final Long id;
    private final String tackleType;
    private final String bait;
    private final String fishCaught;
    private final Integer catchCount;
    private final String memo;

    public TackleEntryResponse(TackleEntry entry) {
        this.id = entry.getId();
        this.tackleType = entry.getTackleType();
        this.bait = entry.getBait();
        this.fishCaught = entry.getFishCaught();
        this.catchCount = entry.getCatchCount();
        this.memo = entry.getMemo();
    }
}
