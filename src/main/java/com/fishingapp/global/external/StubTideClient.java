package com.fishingapp.global.external;

import com.fishingapp.domain.point.entity.TideInfo;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class StubTideClient implements TideClient {

    @Override
    public TideInfo fetch(double latitude, double longitude, LocalDate date) {
        // TODO: 해양수산부 조석 예보 API 연동 — 예측 도메인에서 구현
        return null;
    }
}
