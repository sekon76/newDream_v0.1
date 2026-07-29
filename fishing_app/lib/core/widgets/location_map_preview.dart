import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

// 위도/경도 하나를 지도 위에 마커로만 보여주는 읽기 전용 위젯.
// 일지/커뮤니티/포인트 상세 화면처럼 이미 정해진 위치를 확인만 할 때 사용한다.
class LocationMapPreview extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double height;

  const LocationMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final position = NLatLng(latitude, longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        child: NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(target: position, zoom: 14),
            scrollGesturesEnable: false,
            zoomGesturesEnable: false,
            tiltGesturesEnable: false,
            rotationGesturesEnable: false,
            stopGesturesEnable: false,
            logoClickEnable: false,
          ),
          onMapReady: (controller) {
            controller.addOverlay(NMarker(id: 'preview', position: position));
          },
        ),
      ),
    );
  }
}
