package com.fishingapp.global.external.khoa;

import java.util.List;

class WaterTempStations {

    record Station(String code, String name, double lat, double lon) {}

    // apis.data.go.kr/1192136/twRecent (GetTWRecentApiService) API의 실제 obsCode 매핑
    // (data.go.kr 활용가이드 코드표 + 각 obsCode 실호출로 좌표 직접 확인, 2026-08 기준)
    static final List<Station> ALL = List.of(
        new Station("HB_0001", "한수원_기장", 35.18244, 129.23525),
        new Station("HB_0002", "한수원_고리", 35.31850, 129.31472),
        new Station("HB_0003", "한수원_진하", 35.38472, 129.36805),
        new Station("HB_0007", "한수원_온양", 37.01944, 129.42500),
        new Station("HB_0008", "한수원_덕천", 37.10000, 129.40416),
        new Station("HB_0009", "한수원_나곡", 37.11916, 129.39583),
        new Station("KG_0021", "제주남부",   32.09041, 126.96586),
        new Station("KG_0024", "대한해협",   34.91900, 129.12125),
        new Station("KG_0025", "남해동부",   34.22247, 128.41902),
        new Station("KG_0101", "울릉도북동", 38.00736, 131.55258),
        new Station("KG_0102", "울릉도북서", 37.74272, 130.60119),
        new Station("TW_0062", "해운대해수욕장", 35.14897, 129.17016),
        new Station("TW_0069", "대천해수욕장", 36.27411, 126.45780),
        new Station("TW_0070", "평택당진항",   37.13666, 126.54083),
        new Station("TW_0072", "군산항",       35.98416, 126.50875),
        new Station("TW_0074", "광양항",       34.85972, 127.79277),
        new Station("TW_0075", "중문해수욕장", 33.23450, 126.40955),
        new Station("TW_0076", "인천항",       37.38944, 126.53305),
        new Station("TW_0077", "경인항",       37.52338, 126.59208),
        new Station("TW_0078", "완도항",       34.32508, 126.76319),
        new Station("TW_0079", "상왕등도",     35.65247, 126.19425),
        new Station("TW_0080", "우이도",       34.54305, 125.80277),
        new Station("TW_0081", "생일도",       34.25872, 126.96027),
        new Station("TW_0082", "태안항",       37.00672, 126.27022),
        new Station("TW_0083", "여수항",       34.79472, 127.80805),
        new Station("TW_0084", "통영항",       34.77333, 128.46000),
        new Station("TW_0085", "마산항",       35.10319, 128.63183),
        new Station("TW_0086", "부산항신항",   35.04377, 128.76175),
        new Station("TW_0087", "부산항",       35.09175, 129.08525),
        new Station("TW_0088", "감천항",       35.05280, 129.00308),
        new Station("TW_0089", "경포대해수욕장", 37.80897, 128.93188),
        new Station("TW_0090", "송정해수욕장", 35.16472, 129.21944),
        new Station("TW_0091", "낙산해수욕장", 38.12250, 128.65055),
        new Station("TW_0092", "임랑해수욕장", 35.30250, 129.29250),
        new Station("TW_0093", "속초해수욕장", 38.19861, 128.63138),
        new Station("TW_0094", "망상해수욕장", 37.61611, 129.10305),
        new Station("TW_0095", "고래불해수욕장", 36.58000, 129.45408)
    );

    static Station nearest(double lat, double lon) {
        Station nearest = null;
        double minDist = Double.MAX_VALUE;
        for (Station s : ALL) {
            double dist = haversine(lat, lon, s.lat(), s.lon());
            if (dist < minDist) {
                minDist = dist;
                nearest = s;
            }
        }
        return nearest;
    }

    static double distanceToNearestKm(double lat, double lon) {
        double minDist = Double.MAX_VALUE;
        for (Station s : ALL) {
            double dist = haversine(lat, lon, s.lat(), s.lon());
            if (dist < minDist) minDist = dist;
        }
        return minDist;
    }

    private static double haversine(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }
}
