package com.fishingapp.domain.point.dto;

import com.fishingapp.domain.point.entity.TackleEntry;
import lombok.Getter;

@Getter
public class TackleEntryRequest {
    private String tackleType;   // 채비 종류 (루어, 찌낚시, 바닥채비 등)
    private String bait;         // 미끼 (지렁이, 크릴 등)
    private String fishCaught;   // 잡은 어종
    private Integer catchCount;  // 마릿수
    private String memo;

    public TackleEntry toEntity() {
        return TackleEntry.builder()
                .tackleType(tackleType)
                .bait(bait)
                .fishCaught(fishCaught)
                .catchCount(catchCount)
                .memo(memo)
                .build();
    }
}
