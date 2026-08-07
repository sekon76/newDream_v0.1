package com.fishingapp.global.external.khoa;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fishingapp.domain.prediction.dto.HourlyWaterTempItem;
import com.fishingapp.global.external.WaterTempClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Component
public class KhoaWaterTempClient implements WaterTempClient {

    // 해양수산부 국립해양조사원 해양관측부이 최신 관측데이터(수온 등) API
    private static final String BASE_URL =
            "https://apis.data.go.kr/1192136/twRecent/GetTWRecentApiService";
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final double MAX_STATION_DISTANCE_KM = 25.0;

    @Value("${external.khoa.api-key:}")
    private String apiKey;

    private final RestClient restClient;
    private final ObjectMapper objectMapper;

    public KhoaWaterTempClient(ObjectMapper objectMapper) {
        this.restClient = RestClient.create();
        this.objectMapper = objectMapper;
    }

    @Override
    public List<HourlyWaterTempItem> fetchHourly(double latitude, double longitude, LocalDate date) {
        if (apiKey == null || apiKey.isBlank()) return List.of();
        // 실시간 관측 자료라 미래 날짜는 존재하지 않는다(예보가 아님).
        if (!date.isEqual(LocalDate.now())) return List.of();

        WaterTempStations.Station station = WaterTempStations.nearest(latitude, longitude);
        if (station == null || WaterTempStations.distanceToNearestKm(latitude, longitude) > MAX_STATION_DISTANCE_KM) {
            return List.of();
        }

        try {
            String url = String.format(
                    "%s?obsCode=%s&reqDate=%s&min=60&numOfRows=24&serviceKey=%s",
                    BASE_URL, station.code(), date.format(DATE_FMT), apiKey);

            String body = restClient.get().uri(url).retrieve().body(String.class);
            return parse(body);
        } catch (Exception e) {
            log.warn("해양수산부 수온 관측 API 호출 실패: {}", e.getMessage());
            return List.of();
        }
    }

    private List<HourlyWaterTempItem> parse(String json) throws Exception {
        JsonNode root = objectMapper.readTree(json);
        String resultCode = root.path("header").path("resultCode").asText();
        if (!"00".equals(resultCode)) {
            log.warn("수온 관측 API 응답: {} ({})", resultCode, root.path("header").path("resultMsg").asText());
            return List.of();
        }

        // numOfRows에 따라 item이 단일 객체 또는 배열로 내려오므로 둘 다 처리한다.
        JsonNode itemNode = root.path("body").path("items").path("item");
        List<JsonNode> items = new ArrayList<>();
        if (itemNode.isArray()) {
            itemNode.forEach(items::add);
        } else if (!itemNode.isMissingNode() && !itemNode.isNull()) {
            items.add(itemNode);
        }

        List<HourlyWaterTempItem> result = new ArrayList<>();
        for (JsonNode item : items) {
            String tempText = item.path("wtem").asText(null);
            if (tempText == null || tempText.isBlank()) continue;

            Double temperature;
            try {
                temperature = Double.parseDouble(tempText);
            } catch (NumberFormatException e) {
                continue;
            }

            // obsrvnDt: "2026-08-06 17:00" → "1700" (HourlyWeatherItem과 동일한 HHmm 포맷)
            String obsrvnDt = item.path("obsrvnDt").asText(null);
            if (obsrvnDt == null || obsrvnDt.length() < 16) continue;
            String time = obsrvnDt.substring(11, 13) + obsrvnDt.substring(14, 16);

            result.add(new HourlyWaterTempItem(time, temperature));
        }
        return result;
    }
}
