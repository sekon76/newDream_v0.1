package com.fishingapp.domain.point.dto;

import com.fishingapp.domain.point.entity.CatchRecord;
import lombok.Getter;

import java.time.LocalTime;

@Getter
public class CatchRecordResponse {
    private final Long id;
    private final String fishName;
    private final Integer count;
    private final Integer sizeCm;
    private final Integer weightG;
    private final LocalTime caughtTime;

    public CatchRecordResponse(CatchRecord record) {
        this.id = record.getId();
        this.fishName = record.getFishName();
        this.count = record.getCount();
        this.sizeCm = record.getSizeCm();
        this.weightG = record.getWeightG();
        this.caughtTime = record.getCaughtTime();
    }
}
