package com.fishingapp.global.external;

import com.fishingapp.domain.point.entity.TideInfo;

import java.time.LocalDate;

public interface TideClient {
    TideInfo fetch(double latitude, double longitude, LocalDate date);
}
