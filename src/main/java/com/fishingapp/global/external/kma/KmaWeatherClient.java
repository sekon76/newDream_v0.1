package com.fishingapp.global.external.kma;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fishingapp.domain.point.entity.WeatherInfo;
import com.fishingapp.global.external.WeatherClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;

@Slf4j
@Component
public class KmaWeatherClient implements WeatherClient {

    private static final String BASE_URL = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0";
    private static final int[] BASE_TIMES = {2, 5, 8, 11, 14, 17, 20, 23};
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");

    @Value("${external.kma.api-key:}")
    private String apiKey;

    private final RestClient restClient;
    private final ObjectMapper objectMapper;

    public KmaWeatherClient(ObjectMapper objectMapper) {
        this.restClient = RestClient.create();
        this.objectMapper = objectMapper;
    }

    @Override
    public WeatherInfo fetch(double latitude, double longitude, LocalDate date) {
        if (apiKey == null || apiKey.isBlank()) return null;

        BaseDateTime base = resolveBaseDateTime(date);
        if (base == null) return null;

        int[] grid = LatLonToGrid.convert(latitude, longitude);

        try {
            String url = String.format(
                    "%s/getVilageFcst?ServiceKey=%s&pageNo=1&numOfRows=1000&dataType=JSON" +
                    "&base_date=%s&base_time=%s&nx=%d&ny=%d",
                    BASE_URL, apiKey, base.date(), base.time(), grid[0], grid[1]);

            String body = restClient.get().uri(url).retrieve().body(String.class);
            return parse(body, date);
        } catch (Exception e) {
            log.warn("기상청 날씨 API 호출 실패: {}", e.getMessage());
            return null;
        }
    }

    private WeatherInfo parse(String json, LocalDate targetDate) throws Exception {
        JsonNode root = objectMapper.readTree(json);
        String resultCode = root.path("response").path("header").path("resultCode").asText();
        if (!"00".equals(resultCode)) {
            log.warn("기상청 API 에러: {}", root.path("response").path("header").path("resultMsg").asText());
            return null;
        }

        String targetDateStr = targetDate.format(DATE_FMT);
        JsonNode items = root.path("response").path("body").path("items").path("item");

        // 목표 날짜의 fcstTime별 카테고리 수집
        TreeMap<String, Map<String, String>> byTime = new TreeMap<>();
        for (JsonNode item : items) {
            if (!targetDateStr.equals(item.path("fcstDate").asText())) continue;
            String fcstTime = item.path("fcstTime").asText();
            byTime.computeIfAbsent(fcstTime, k -> new HashMap<>())
                  .put(item.path("category").asText(), item.path("fcstValue").asText());
        }
        if (byTime.isEmpty()) return null;

        // 정오(1200) 우선, 없으면 1200 이후 가장 가까운 시각, 없으면 마지막 시각
        Map<String, String> data = byTime.containsKey("1200") ? byTime.get("1200")
                : byTime.ceilingKey("1200") != null ? byTime.get(byTime.ceilingKey("1200"))
                : byTime.lastEntry().getValue();

        return WeatherInfo.builder()
                .condition(resolveCondition(data.getOrDefault("SKY", "1"), data.getOrDefault("PTY", "0")))
                .temperature(toDouble(data.get("TMP")))
                .humidity(toInt(data.get("REH")))
                .windSpeed(toDouble(data.get("WSD")))
                .windDirection(toWindDirection(toInt(data.get("VEC"))))
                .waveHeight(toDouble(data.get("WAV")))
                .build();
    }

    private String resolveCondition(String sky, String pty) {
        return switch (pty) {
            case "1" -> "비";
            case "2" -> "비/눈";
            case "3" -> "눈";
            case "4" -> "소나기";
            default -> switch (sky) {
                case "3" -> "구름많음";
                case "4" -> "흐림";
                default -> "맑음";
            };
        };
    }

    private String toWindDirection(Integer degree) {
        if (degree == null) return null;
        String[] dirs = {"북", "북동", "동", "남동", "남", "남서", "서", "북서"};
        return dirs[(int) Math.round(degree / 45.0) % 8];
    }

    // base_date/time 결정: 현재 기준으로 가장 최근 발표 시각
    // 단기예보 발표 시각: 02, 05, 08, 11, 14, 17, 20, 23시 (각 10분 후 제공)
    private BaseDateTime resolveBaseDateTime(LocalDate targetDate) {
        LocalDateTime now = LocalDateTime.now();
        LocalDate baseDate;
        String baseTime;

        if (now.getHour() < 3) {
            // 새벽 3시 이전이면 전날 23시 예보 사용
            baseDate = now.toLocalDate().minusDays(1);
            baseTime = "2300";
        } else {
            baseDate = now.toLocalDate();
            int baseHour = 2;
            for (int t : BASE_TIMES) {
                if (now.getHour() > t) baseHour = t;
            }
            baseTime = String.format("%02d00", baseHour);
        }

        // 단기예보는 baseDate 기준 D+3까지만 유효
        long diff = java.time.temporal.ChronoUnit.DAYS.between(baseDate, targetDate);
        if (diff < 0 || diff > 3) return null;

        return new BaseDateTime(baseDate.format(DATE_FMT), baseTime);
    }

    private record BaseDateTime(String date, String time) {}

    private Double toDouble(String val) {
        if (val == null) return null;
        try { return Double.parseDouble(val); } catch (NumberFormatException e) { return null; }
    }

    private Integer toInt(String val) {
        if (val == null) return null;
        try { return Integer.parseInt(val); } catch (NumberFormatException e) { return null; }
    }
}
