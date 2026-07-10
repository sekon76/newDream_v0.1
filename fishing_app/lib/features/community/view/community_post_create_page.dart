import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/point/provider/point_provider.dart';
import 'package:fishing_app/features/point/view/map_picker_page.dart';
import 'package:fishing_app/features/prediction/provider/prediction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class CommunityPostCreatePage extends ConsumerStatefulWidget {
  const CommunityPostCreatePage({super.key});

  @override
  ConsumerState<CommunityPostCreatePage> createState() => _CommunityPostCreatePageState();
}

class _CommunityPostCreatePageState extends ConsumerState<CommunityPostCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  double? _lat;
  double? _lon;
  bool _isLocating = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchLocation() async {
    final query = _locationCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() => _isLocating = true);
    final results = await ref.read(locationSearchProvider(query).future);
    setState(() => _isLocating = false);
    if (!mounted) return;

    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('검색 결과가 없습니다. 지도에서 직접 선택해보세요.'),
        action: SnackBarAction(label: '지도 열기', onPressed: _openMapPicker),
      ));
      return;
    }
    if (results.length == 1) {
      _applyLocation(results.first.name, results.first.lat, results.first.lon);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (ctx, i) => ListTile(
          leading: const Icon(Icons.place),
          title: Text(results[i].name),
          onTap: () {
            Navigator.pop(ctx);
            _applyLocation(results[i].name, results[i].lat, results[i].lon);
          },
        ),
      ),
    );
  }

  void _applyLocation(String name, double lat, double lon) {
    setState(() {
      _locationCtrl.text = name;
      _lat = lat;
      _lon = lon;
    });
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<MapPickerResult>(
      MaterialPageRoute(builder: (_) => MapPickerPage(initialLat: _lat, initialLon: _lon)),
    );
    if (result == null) return;
    setState(() {
      _lat = result.latitude;
      _lon = result.longitude;
      if (_locationCtrl.text.trim().isEmpty) {
        _locationCtrl.text = '지도 선택 위치 (${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)})';
      }
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('위치 권한이 필요합니다.')));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 5)),
      );
      setState(() {
        _lat = pos.latitude;
        _lon = pos.longitude;
        if (_locationCtrl.text.trim().isEmpty) {
          _locationCtrl.text = '현재 위치 (${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)})';
        }
      });
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null || _lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치를 검색하거나 지도에서 선택해주세요.')),
      );
      return;
    }

    final ok = await ref.read(pointActionsProvider.notifier).createCommunityPost(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          locationName: _locationCtrl.text.trim(),
          latitude: _lat!,
          longitude: _lon!,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      final error = ref.read(pointActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패: ${apiErrorMessage(error)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(pointActionsProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('글쓰기'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('게시'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: '제목', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? '제목을 입력하세요.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentCtrl,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    hintText: '예: 이번 주말에 같이 출조하실 분 계신가요?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 6,
                  validator: (v) => (v == null || v.trim().isEmpty) ? '내용을 입력하세요.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationCtrl,
                  decoration: InputDecoration(
                    labelText: '지역(포인트) 검색',
                    hintText: '예: 여수, 통영, 거제',
                    border: const OutlineInputBorder(),
                    suffixIcon: _isLocating
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : IconButton(icon: const Icon(Icons.search), onPressed: _searchLocation),
                  ),
                  onFieldSubmitted: (_) => _searchLocation(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _isLocating ? null : _useCurrentLocation,
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text('현재 위치 사용'),
                    ),
                    TextButton.icon(
                      onPressed: _openMapPicker,
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('지도에서 선택'),
                    ),
                  ],
                ),
                if (_lat != null && _lon != null)
                  Text(
                    '선택된 좌표: ${_lat!.toStringAsFixed(5)}, ${_lon!.toStringAsFixed(5)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
