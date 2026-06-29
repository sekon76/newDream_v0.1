package com.fishingapp.domain.point.entity;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Embeddable
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TideInfo {
    private String highTideTime1;     // 만조 1 시각 (HH:mm)
    private Integer highTideHeight1;  // 만조 1 조고 (cm)
    private String lowTideTime1;      // 간조 1 시각
    private Integer lowTideHeight1;   // 간조 1 조고 (cm)
    private String highTideTime2;     // 만조 2 시각 (nullable)
    private Integer highTideHeight2;
    private String lowTideTime2;      // 간조 2 시각 (nullable)
    private Integer lowTideHeight2;
}
