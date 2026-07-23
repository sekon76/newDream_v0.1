import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/point/view/map_picker_page.dart';
import 'package:fishing_app/features/prediction/provider/prediction_provider.dart';
import 'package:fishing_app/features/profile/data/profile_model.dart';
import 'package:fishing_app/features/profile/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class PreferredRegionCreatePage extends ConsumerStatefulWidget {
  final PreferredRegion? existing;
  const PreferredRegionCreatePage({super.key, this.existing});

  @override
  ConsumerState<PreferredRegionCreatePage> createState() => _PreferredRegionCreatePageState();
}

class _SpeciesRow {
  final TextEditingController controller;
  _SpeciesRow(String speciesName) : controller = TextEditingController(text: speciesName);

  String get speciesName => controller.text.trim();

  void dispose() => controller.dispose();
}

class _PreferredRegionCreatePageState extends ConsumerState<PreferredRegionCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isDefault = false;
  double? _lat;
  double? _lon;
  bool _isLocating = false;

  final List<_SpeciesRow> _speciesRows = [];
  int? _defaultSpeciesIndex;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _nameCtrl.text = existing.name;
      _addressCtrl.text = existing.address ?? '';
      _lat = existing.latitude;
      _lon = existing.longitude;
      _isDefault = existing.isDefault;
      for (final s in existing.species) {
        _speciesRows.add(_SpeciesRow(s.speciesName));
        if (s.isDefault) _defaultSpeciesIndex = _speciesRows.length - 1;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    for (final row in _speciesRows) {
      row.dispose();
    }
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

  void _addSpeciesRow() {
    setState(() {
      _speciesRows.add(_SpeciesRow(''));
      // 처음 추가하는 어종은 자동으로 기본값이 되게 한다.
      _defaultSpeciesIndex ??= 0;
    });
  }

  void _removeSpeciesRow(int index) {
    setState(() {
      _speciesRows.removeAt(index).dispose();
      if (_defaultSpeciesIndex == null) return;
      if (_defaultSpeciesIndex == index) {
        _defaultSpeciesIndex = _speciesRows.isEmpty ? null : 0;
      } else if (_defaultSpeciesIndex! > index) {
        _defaultSpeciesIndex = _defaultSpeciesIndex! - 1;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null || _lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치를 검색하거나 현재 위치를 사용해주세요.')),
      );
      return;
    }

    final species = _speciesRows.asMap().entries.map((entry) {
      return PreferredFishSpeciesData(
        speciesName: entry.value.speciesName,
        isDefault: entry.key == _defaultSpeciesIndex,
      );
    }).toList();

    final notifier = ref.read(profileActionsProvider.notifier);
    final existing = widget.existing;
    final ok = existing != null
        ? await notifier.updateRegion(
            existing.id,
            name: _nameCtrl.text.trim(),
            latitude: _lat!,
            longitude: _lon!,
            address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
            isDefault: _isDefault,
            species: species,
          )
        : await notifier.createRegion(
            name: _nameCtrl.text.trim(),
            latitude: _lat!,
            longitude: _lon!,
            address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
            isDefault: _isDefault,
            species: species,
          );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      final error = ref.read(profileActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_isEditing ? '수정' : '등록'} 실패: ${apiErrorMessage(error)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileActionsProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '선호 지역 수정' : '선호 지역 추가')),
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
                  decoration: const InputDecoration(labelText: '지역 이름', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? '지역 이름을 입력하세요.' : null,
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
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('기본 지역으로 설정'),
                  subtitle: const Text('조과예측 화면 첫 진입 시 자동으로 이 지역이 검색됩니다.'),
                  value: _isDefault,
                  onChanged: (v) => setState(() => _isDefault = v),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('선호 어종', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _addSpeciesRow),
                  ],
                ),
                if (_speciesRows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('등록된 어종이 없습니다. + 버튼으로 추가해보세요.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                ..._speciesRows.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: index,
                            groupValue: _defaultSpeciesIndex,
                            onChanged: (v) => setState(() => _defaultSpeciesIndex = v),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: row.controller,
                              decoration: const InputDecoration(border: InputBorder.none, hintText: '어종 이름'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? '어종 이름을 입력하세요.' : null,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => _removeSpeciesRow(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (_speciesRows.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('라디오 버튼으로 표시된 하나가 조과예측 자동검색에 사용됩니다.', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                      : Text(_isEditing ? '수정 완료' : '등록하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
