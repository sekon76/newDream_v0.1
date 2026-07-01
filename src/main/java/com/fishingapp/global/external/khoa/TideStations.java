package com.fishingapp.global.external.khoa;

import java.util.List;

class TideStations {

    record Station(String code, String name, double lat, double lon) {}

    // apis.data.go.kr/1192136 API의 실제 obsCode 매핑 (직접 확인)
    static final List<Station> ALL = List.of(
        new Station("DT_0001", "인천",   37.4521, 126.5899),
        new Station("DT_0004", "제주",   33.5271, 126.5428),
        new Station("DT_0005", "부산",   35.0959, 129.0356),
        new Station("DT_0006", "묵호",   37.5490, 129.1200),
        new Station("DT_0007", "목포",   34.7779, 126.3761),
        new Station("DT_0010", "서귀포", 33.2398, 126.5612),
        new Station("DT_0012", "속초",   38.2070, 128.5918),
        new Station("DT_0013", "울릉도", 37.4875, 130.9026),
        new Station("DT_0014", "통영",   34.8437, 128.4334),
        new Station("DT_0016", "여수",   34.7445, 127.7561),
        new Station("DT_0018", "군산",   35.9887, 126.7160),
        new Station("DT_0020", "울산",   35.5390, 129.3860),
        new Station("DT_0023", "모슬포", 33.2190, 126.2520),
        new Station("DT_0027", "완도",   34.3190, 126.7574),
        new Station("DT_0029", "거제도", 34.8700, 128.6980),
        new Station("DT_0054", "진해",   35.1434, 128.6441),
        new Station("DT_0062", "마산",   35.1969, 128.5739),
        new Station("DT_0091", "포항",   36.0531, 129.3802)
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

    private static double haversine(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }
}
