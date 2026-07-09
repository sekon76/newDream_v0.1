import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/point/provider/point_provider.dart';
import 'package:fishing_app/features/point/view/map_picker_page.dart';
import 'package:fishing_app/features/prediction/provider/prediction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class PointCreatePage extends ConsumerStatefulWidget {
  const PointCreatePage({super.key});

  @override
  ConsumerState<PointCreatePage> createState() => _PointCreatePageState();
}

class _PointCreatePageState extends ConsumerState<PointCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _fishTypeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  bool _isPublic = false;
  double? _lat;
  double? _lon;
  bool _isLocating = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _fishTypeCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    final query = _addressCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() => _isLocating = true);
    final results = await ref.read(locationSearchProvider(query).future);
    setState(() => _isLocating = false);
    if (!mounted) return;

    if (results.isEmpty) {
      if (!mounted) return;
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

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<MapPickerResult>(
      MaterialPageRoute(builder: (_) => MapPickerPage(initialLat: _lat, initialLon: _lon)),
    );
    if (result == null) return;
    setState(() {
      _lat = result.latitude;
      _lon = result.longitude;
      if (_addressCtrl.text.trim().isEmpty) {
        _addressCtrl.text = '지도 선택 위치 (${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)})';
      }
    });
  }

  void _applyLocation(String name, double lat, double lon) {
    setState(() {
      _addressCtrl.text = name;
      _lat = lat;
      _lon = lon;
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
        if (_addressCtrl.text.trim().isEmpty) {
          _addressCtrl.text = '현재 위치 (${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)})';
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
        const SnackBar(content: Text('위치를 검색하거나 현재 위치를 사용해주세요.')),
      );
      return;
    }
    final ok = await ref.read(pointActionsProvider.notifier).create(
          name: _nameCtrl.text.trim(),
          description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
          latitude: _lat!,
          longitude: _lon!,
          address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
          fishType: _fishTypeCtrl.text.trim().isEmpty ? null : _fishTypeCtrl.text.trim(),
          isPublic: _isPublic,
        );
    if (!mounted) return;
    if (ok) {
      context.pop();
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
      appBar: AppBar(title: const Text('낚시 포인트 등록')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: '포인트 이름', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? '포인트 이름을 입력하세요.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: InputDecoration(
                    labelText: '위치 검색',
                    border: const OutlineInputBorder(),
                    suffixIcon: _isLocating
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : IconButton(icon: const Icon(Icons.search), onPressed: _searchAddress),
                  ),
                  onFieldSubmitted: (_) => _searchAddress(),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fishTypeCtrl,
                  decoration: const InputDecoration(labelText: '주요 어종', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionCtrl,
                  decoration: const InputDecoration(labelText: '설명', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('다른 사용자에게 공개'),
                  value: _isPublic,
                  onChanged: (v) => setState(() => _isPublic = v),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('등록하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
