import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/point/data/point_model.dart';
import 'package:fishing_app/features/point/provider/point_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VisitCreatePage extends ConsumerStatefulWidget {
  final int pointId;
  final PointVisit? existing;
  final bool defaultPublic;
  const VisitCreatePage({super.key, required this.pointId, this.existing, this.defaultPublic = false});

  @override
  ConsumerState<VisitCreatePage> createState() => _VisitCreatePageState();
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

class _VisitCreatePageState extends ConsumerState<VisitCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();
  DateTime _visitDate = DateTime.now();
  bool _isPublic = false;
  final List<_CatchRow> _catchRows = [];
  final List<_TackleRow> _tackleRows = [];
  DateTime? _lastCatchAddTap;
  DateTime? _lastTackleAddTap;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleCtrl.text = existing.title ?? '';
      _contentCtrl.text = existing.content ?? '';
      _memoCtrl.text = existing.memo ?? '';
      _visitDate = existing.visitDate;
      _isPublic = existing.isPublic;
      _catchRows.addAll(existing.catches.map(_CatchRow.from));
      _tackleRows.addAll(existing.tackles.map(_TackleRow.from));
    } else {
      _isPublic = widget.defaultPublic;
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

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

    final notifier = ref.read(pointActionsProvider.notifier);
    final existing = widget.existing;
    final ok = existing != null
        ? await notifier.updateVisit(
            widget.pointId,
            existing.id,
            visitDate: _visitDate,
            title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
            content: _contentCtrl.text.trim().isEmpty ? null : _contentCtrl.text.trim(),
            memo: _memoCtrl.text.trim().isEmpty ? null : _memoCtrl.text.trim(),
            isPublic: _isPublic,
            tackles: tackles,
            catches: catches,
          )
        : await notifier.createVisit(
            widget.pointId,
            visitDate: _visitDate,
            title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
            content: _contentCtrl.text.trim().isEmpty ? null : _contentCtrl.text.trim(),
            memo: _memoCtrl.text.trim().isEmpty ? null : _memoCtrl.text.trim(),
            isPublic: _isPublic,
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
      final error = ref.read(pointActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_isEditing ? '수정' : '등록'} 실패: ${apiErrorMessage(error)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(pointActionsProvider).isLoading;
    final dateStr =
        '${_visitDate.year}-${_visitDate.month.toString().padLeft(2, '0')}-${_visitDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '방문 기록 수정' : '방문 기록 추가')),
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
                    decoration: const InputDecoration(labelText: '방문 날짜', border: OutlineInputBorder()),
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
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('커뮤니티에 공개'),
                  value: _isPublic,
                  onChanged: (v) => setState(() => _isPublic = v),
                ),
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
