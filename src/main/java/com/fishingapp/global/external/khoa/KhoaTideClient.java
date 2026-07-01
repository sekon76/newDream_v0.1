package com.fishingapp.global.external.khoa;

import com.fishingapp.domain.point.entity.TideInfo;
import com.fishingapp.global.external.TideClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import javax.xml.parsers.DocumentBuilderFactory;
import java.io.StringReader;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Component
public class KhoaTideClient implements TideClient {

    // extrSe: 1=만조1, 2=저조1, 3=만조2, 4=저조2
    private static final String BASE_URL =
            "https://apis.data.go.kr/1192136/tideFcstHghLw/GetTideFcstHghLwApiService";
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");

    @Value("${external.khoa.api-key:}")
    private String apiKey;

    private final RestClient restClient;

    public KhoaTideClient() {
        this.restClient = RestClient.create();
    }

    @Override
    public TideInfo fetch(double latitude, double longitude, LocalDate date) {
        if (apiKey == null || apiKey.isBlank()) return null;

        TideStations.Station station = TideStations.nearest(latitude, longitude);
        if (station == null) return null;

        try {
            String url = String.format(
                    "%s?serviceKey=%s&pageNo=1&numOfRows=10&obsCode=%s&date=%s",
                    BASE_URL, apiKey, station.code(), date.format(DATE_FMT));

            String body = restClient.get().uri(url).retrieve().body(String.class);
            return parseXml(body);
        } catch (Exception e) {
            log.warn("해양수산부 조석 API 호출 실패: {}", e.getMessage());
            return null;
        }
    }

    private TideInfo parseXml(String xml) throws Exception {
        Document doc = DocumentBuilderFactory.newInstance()
                .newDocumentBuilder()
                .parse(new InputSource(new StringReader(xml)));

        String resultCode = doc.getElementsByTagName("resultCode").item(0).getTextContent();
        if (!"00".equals(resultCode)) {
            log.warn("조석 API 에러: {}", doc.getElementsByTagName("resultMsg").item(0).getTextContent());
            return null;
        }

        NodeList itemList = doc.getElementsByTagName("item");
        if (itemList.getLength() == 0) return null;

        record TideItem(int extrSe, String time, int level) {}
        List<TideItem> items = new ArrayList<>();

        for (int i = 0; i < itemList.getLength(); i++) {
            var item = itemList.item(i);
            var children = item.getChildNodes();
            int extrSe = -1;
            String predcDt = null;
            int level = 0;

            for (int j = 0; j < children.getLength(); j++) {
                var node = children.item(j);
                switch (node.getNodeName()) {
                    case "extrSe"    -> extrSe = Integer.parseInt(node.getTextContent().trim());
                    case "predcDt"   -> predcDt = node.getTextContent().trim();
                    case "predcTdlvVl" -> level = (int) Double.parseDouble(node.getTextContent().trim());
                }
            }

            if (extrSe > 0 && predcDt != null) {
                // "2026-07-01 08:34" → "08:34"
                String time = predcDt.length() >= 16 ? predcDt.substring(11, 16) : predcDt;
                items.add(new TideItem(extrSe, time, level));
            }
        }

        // extrSe: 1=만조1, 2=저조1, 3=만조2, 4=저조2
        TideItem h1 = items.stream().filter(t -> t.extrSe() == 1).findFirst().orElse(null);
        TideItem l1 = items.stream().filter(t -> t.extrSe() == 2).findFirst().orElse(null);
        TideItem h2 = items.stream().filter(t -> t.extrSe() == 3).findFirst().orElse(null);
        TideItem l2 = items.stream().filter(t -> t.extrSe() == 4).findFirst().orElse(null);

        return TideInfo.builder()
                .highTideTime1(h1 != null ? h1.time() : null)
                .highTideHeight1(h1 != null ? h1.level() : null)
                .lowTideTime1(l1 != null ? l1.time() : null)
                .lowTideHeight1(l1 != null ? l1.level() : null)
                .highTideTime2(h2 != null ? h2.time() : null)
                .highTideHeight2(h2 != null ? h2.level() : null)
                .lowTideTime2(l2 != null ? l2.time() : null)
                .lowTideHeight2(l2 != null ? l2.level() : null)
                .build();
    }
}
