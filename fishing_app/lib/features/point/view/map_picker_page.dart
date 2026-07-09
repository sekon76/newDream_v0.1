import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MapPickerResult {
  final double latitude;
  final double longitude;
  const MapPickerResult({required this.latitude, required this.longitude});
}

class MapPickerPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;
  const MapPickerPage({super.key, this.initialLat, this.initialLon});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  NaverMapController? _controller;
  late NLatLng _center;

  @override
  void initState() {
    super.initState();
    _center = NLatLng(widget.initialLat ?? 37.5665, widget.initialLon ?? 126.9780);
  }

  void _confirm() {
    Navigator.pop(context, MapPickerResult(latitude: _center.latitude, longitude: _center.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('지도에서 위치 선택')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(target: _center, zoom: 14),
            ),
            onMapReady: (controller) => _controller = controller,
            onCameraIdle: () {
              final controller = _controller;
              if (controller == null) return;
              setState(() => _center = controller.nowCameraPosition.target);
            },
          ),
          const IgnorePointer(
            child: Padding(
              padding: EdgeInsets.only(bottom: 36),
              child: Icon(Icons.location_pin, size: 48, color: Colors.red),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(
                  '지도를 움직여서 중앙 핀을 원하는 위치에 맞춰주세요\n(${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: FilledButton(
              onPressed: _confirm,
              child: const Text('이 위치로 선택'),
            ),
          ),
        ],
      ),
    );
  }
}
