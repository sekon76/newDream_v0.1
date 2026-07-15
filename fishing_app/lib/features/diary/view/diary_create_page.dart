import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/diary/data/diary_model.dart';
import 'package:fishing_app/features/diary/provider/diary_provider.dart';
import 'package:fishing_app/features/point/data/point_model.dart';
import 'package:fishing_app/features/point/provider/point_provider.dart';
import 'package:fishing_app/features/point/view/map_picker_page.dart';
import 'package:fishing_app/features/prediction/provider/prediction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class DiaryCreatePage extends ConsumerStatefulWidget {
  final Diary? existing;
  const DiaryCreatePage({super.key, this.existing});

  @override
  ConsumerState<DiaryCreatePage> createState() => _DiaryCreatePageState();
}

class _CatchRow {
  final fishNameCtrl = TextEditingController();
  final countCtrl = TextEditingController(text: '1');
  final sizeCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  TimeOfDay? caughtTime;

  _CatchRow();

  factory _CatchRow.from(CatchRecordData data) {
    final row = _CatchRow()
      ..fishNameCtrl.text = data.fishName
      ..countCtrl.text = data.count.toString()
      ..sizeCtrl.text = data.sizeCm?.toString() ?? ''
      ..weightCtrl.text = data.weightG?.toString() ?? '';
    if (data.caughtTime != null) {
      final parts = data.caughtTime!.split(':');
      row.caughtTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return row;
  }
}

class _TackleRow {
  final tackleTypeCtrl = TextEditingController();
  final baitCtrl = TextEditingController();
  final memoCtrl = TextEditingController();

  _TackleRow();

  factory _TackleRow.from(TackleEntryData data) {
    return _TackleRow()
      ..tackleTypeCtrl.text = data.tackleType ?? ''
      ..baitCtrl.text = data.bait ?? ''
      ..memoCtrl.text = data.memo ?? '';
  }
}

class _DiaryCreatePageState extends ConsumerState<DiaryCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  DateTime _visitDate = DateTime.now();
  final List<_CatchRow> _catchRows = [];
  final List<_TackleRow> _tackleRows = [];
  DateTime? _lastCatchAddTap;
  DateTime? _lastTackleAddTap;

  double? _lat;
  double? _lon;
  int? _pointId;
  String? _pointName;
  bool _isLocating = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleCtrl.text = existing.title ?? '';
      _contentCtrl.text = existing.content ?? '';
      _memoCtrl.text = existing.memo ?? '';
      _addressCtrl.text = existing.address ?? '';
      _visitDate = existing.visitDate;
      _lat = existing.latitude;
      _lon = existing.longitude;
      _pointId = existing.pointId;
      _pointName = existing.pointName;
      _catchRows.addAll(existing.catches.map(_CatchRow.from));
      _tackleRows.addAll(existing.tackles.map(_TackleRow.from));
    }
  }

  bool _debounce(DateTime? last, void Function(DateTime) update) {
    final now = DateTime.now();
    if (last != null && now.difference(last) < const Duration(milliseconds: 400)) {
      return false;
    }
    update(now);
    return true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _memoCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _visitDate = picked);
  }

  Future<void> _pickFromMyPoints() async {
    final points = await ref.read(pointsProvider.future);
    if (!mounted) return;
    if (points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('등록된 포인트가 없습니다. 먼저 포인트를 등록해보세요.')),
      );
      return;
    }
    final selected = await showModalBottomSheet<FishingPoint>(
      context: context,
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: points.length,
        itemBuilder: (ctx, i) => ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text(points[i].name),
          subtitle: points[i].address != null ? Text(points[i].address!) : null,
          onTap: () => Navigator.pop(ctx, points[i]),
        ),
      ),
    );
    if (selected == null) return;
    setState(() {
      _pointId = selected.id;
      _pointName = selected.name;
      _lat = selected.latitude;
      _lon = selected.longitude;
      _addressCtrl.text = selected.address ?? selected.name;
    });
  }

  void _clearPointLink() {
    setState(() {
      _pointId = null;
      _pointName = null;
    });
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
      _pointId = null;
      _pointName = null;
      _lat = result.latitude;
      _lon = result.longitude;
      if (_addressCtrl.text.trim().isEmpty) {
        _addressCtrl.text = '지도 선택 위치 (${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)})';
      }
    });
  }

  void _applyLocation(String name, double lat, double lon) {
    setState(() {
      _pointId = null;
      _pointName = null;
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
        _pointId = null;
        _pointName = null;
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
    if (!_isEditing && (_lat == null || _lon == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('포인트를 선택하거나 위치를 지정해주세요.')),
      );
      return;
    }

    final catches = <CatchRecordData>[];
    for (final row in _catchRows) {
      final fishName = row.fishNameCtrl.text.trim();
      if (fishName.isEmpty) continue;
      catches.add(CatchRecordData(
        fishName: fishName,
        count: int.tryParse(row.countCtrl.text.trim()) ?? 1,
        sizeCm: int.tryParse(row.sizeCtrl.text.trim()),
        weightG: int.tryParse(row.weightCtrl.text.trim()),
        caughtTime: row.caughtTime == null
            ? null
            : '${row.caughtTime!.hour.toString().padLeft(2, '0')}:${row.caughtTime!.minute.toString().padLeft(2, '0')}',
      ));
    }

    final tackles = <TackleEntryData>[];
    for (final row in _tackleRows) {
      final tackleType = row.tackleTypeCtrl.text.trim();
      final bait = row.baitCtrl.text.trim();
      if (tackleType.isEmpty && bait.isEmpty) continue;
      tackles.add(TackleEntryData(
        tackleType: tackleType.isEmpty ? null : tackleType,
        bait: bait.isEmpty ? null : bait,
        memo: row.memoCtrl.text.trim().isEmpty ? null : row.memoCtrl.text.trim(),
      ));
    }

    final notifier = ref.read(diaryActionsProvider.notifier);
    final existing = widget.existing;
    final ok = existing != null
        ? await notifier.update(
            existing.id,
            visitDate: _visitDate,
            title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
            content: _contentCtrl.text.trim().isEmpty ? null : _contentCtrl.text.trim(),
            memo: _memoCtrl.text.trim().isEmpty ? null : _memoCtrl.text.trim(),
            tackles: tackles,
            catches: catches,
          )
        : await notifier.create(
            visitDate: _visitDate,
            title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
            content: _contentCtrl.text.trim().isEmpty ? null : _contentCtrl.text.trim(),
            memo: _memoCtrl.text.trim().isEmpty ? null : _memoCtrl.text.trim(),
            pointId: _pointId,
            latitude: _lat!,
            longitude: _lon!,
            address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
            tackles: tackles,
            catches: catches,
          );
    if (!mounted) return;
    if (ok) {
      if (existing != null) {
        Navigator.of(context).pop(true);
      } else {
        context.pop();
      }
    } else {
      final error = ref.read(diaryActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_isEditing ? '수정' : '등록'} 실패: ${apiErrorMessage(error)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(diaryActionsProvider).isLoading;
    final dateStr =
        '${_visitDate.year}-${_visitDate.month.toString().padLeft(2, '0')}-${_visitDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '일지 수정' : '낚시 일지 작성')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: '날짜', border: OutlineInputBorder()),
                    child: Text(dateStr),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: '제목', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentCtrl,
                  decoration: const InputDecoration(labelText: '내용', border: OutlineInputBorder()),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _memoCtrl,
                  decoration: const InputDecoration(labelText: '메모', border: OutlineInputBorder()),
                ),
                if (!_isEditing) ...[
                  const SizedBox(height: 24),
                  Text('위치', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_pointId != null)
                    Chip(
                      avatar: const Icon(Icons.location_on, size: 16),
                      label: Text('연결된 포인트: $_pointName'),
                      onDeleted: _clearPointLink,
                    )
                  else
                    TextButton.icon(
                      onPressed: _pickFromMyPoints,
                      icon: const Icon(Icons.location_on_outlined, size: 18),
                      label: const Text('내 포인트에서 불러오기'),
                    ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressCtrl,
                    enabled: _pointId == null,
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
                  if (_pointId == null) ...[
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
                  ],
                  if (_lat != null && _lon != null)
                    Text(
                      '선택된 좌표: ${_lat!.toStringAsFixed(5)}, ${_lon!.toStringAsFixed(5)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
                const SizedBox(height: 24),
                _SectionHeader(
                  title: '어획 기록',
                  onAdd: () {
                    if (_debounce(_lastCatchAddTap, (t) => _lastCatchAddTap = t)) {
                      setState(() => _catchRows.add(_CatchRow()));
                    }
                  },
                ),
                ..._catchRows.asMap().entries.map((entry) => _CatchRowWidget(
                      row: entry.value,
                      onRemove: () => setState(() => _catchRows.removeAt(entry.key)),
                    )),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: '채비/미끼 기록',
                  onAdd: () {
                    if (_debounce(_lastTackleAddTap, (t) => _lastTackleAddTap = t)) {
                      setState(() => _tackleRows.add(_TackleRow()));
                    }
                  },
                ),
                ..._tackleRows.asMap().entries.map((entry) => _TackleRowWidget(
                      row: entry.value,
                      onRemove: () => setState(() => _tackleRows.removeAt(entry.key)),
                    )),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEditing ? '수정 완료' : '저장하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;
  const _SectionHeader({required this.title, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Spacer(),
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onAdd),
      ],
    );
  }
}

class _CatchRowWidget extends StatefulWidget {
  final _CatchRow row;
  final VoidCallback onRemove;
  const _CatchRowWidget({required this.row, required this.onRemove});

  @override
  State<_CatchRowWidget> createState() => _CatchRowWidgetState();
}

class _CatchRowWidgetState extends State<_CatchRowWidget> {
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.row.caughtTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => widget.row.caughtTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: row.fishNameCtrl,
                    decoration: const InputDecoration(labelText: '어종', isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: row.countCtrl,
                    decoration: const InputDecoration(labelText: '마릿수', isDense: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: row.sizeCtrl,
                    decoration: const InputDecoration(labelText: '크기(cm)', isDense: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(icon: const Icon(Icons.close, size: 18), onPressed: widget.onRemove),
              ],
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: _pickTime,
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    row.caughtTime != null
                        ? '${row.caughtTime!.hour.toString().padLeft(2, '0')}:${row.caughtTime!.minute.toString().padLeft(2, '0')} 잡음'
                        : '잡은 시간 입력 (선택)',
                    style: TextStyle(fontSize: 13, color: row.caughtTime != null ? null : Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TackleRowWidget extends StatelessWidget {
  final _TackleRow row;
  final VoidCallback onRemove;
  const _TackleRowWidget({required this.row, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: row.tackleTypeCtrl,
                decoration: const InputDecoration(labelText: '채비 종류', isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: row.baitCtrl,
                decoration: const InputDecoration(labelText: '미끼', isDense: true),
              ),
            ),
            IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onRemove),
          ],
        ),
      ),
    );
  }
}
