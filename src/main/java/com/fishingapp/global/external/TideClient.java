package com.fishingapp.global.external;

import com.fishingapp.domain.point.entity.TideInfo;

import java.time.LocalDate;

public interface TideClient {
    TideInfo fetch(double latitude, double longitude, LocalDate date);

    /** 조위관측소로부터 바다 근처(낚시 가능 거리)에 있는 좌표인지 여부 */
    default boolean isNearCoast(double latitude, double longitude) {
        return true;
    }
}
