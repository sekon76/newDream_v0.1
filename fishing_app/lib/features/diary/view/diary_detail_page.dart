import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/diary/data/diary_model.dart';
import 'package:fishing_app/features/diary/provider/diary_provider.dart';
import 'package:fishing_app/features/diary/view/diary_create_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryDetailPage extends ConsumerWidget {
  final Diary diary;
  const DiaryDetailPage({super.key, required this.diary});

  Future<void> _edit(BuildContext context) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DiaryCreatePage(existing: diary)),
    );
    if (updated == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('일지 삭제'),
        content: const Text('이 일지를 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await ref.read(diaryActionsProvider.notifier).delete(diary.id);
    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      final error = ref.read(diaryActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${apiErrorMessage(error)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr =
        '${diary.visitDate.year}-${diary.visitDate.month.toString().padLeft(2, '0')}-${diary.visitDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(diary.title?.isNotEmpty == true ? diary.title! : '낚시 일지'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(context)),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text(dateStr, style: const TextStyle(color: Colors.grey)),
              if (diary.pointName != null) ...[
                const SizedBox(width: 8),
                Chip(
                  avatar: const Icon(Icons.location_on, size: 14),
                  label: Text(diary.pointName!),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
          if (diary.address != null && diary.address!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.place_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(diary.address!, style: const TextStyle(color: Colors.grey))),
            ]),
          ],
          if (diary.content != null && diary.content!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(title: '내용', child: Text(diary.content!)),
          ],
          if (diary.memo != null && diary.memo!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(title: '메모', child: Text(diary.memo!)),
          ],
          if (diary.weather != null) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: '날씨',
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (diary.weather!.condition != null) _InfoChip('날씨', diary.weather!.condition!),
                  if (diary.weather!.temperature != null)
                    _InfoChip('기온', '${diary.weather!.temperature!.toStringAsFixed(1)}°C'),
                  if (diary.weather!.humidity != null) _InfoChip('습도', '${diary.weather!.humidity}%'),
                  if (diary.weather!.windSpeed != null)
                    _InfoChip('풍속', '${diary.weather!.windSpeed} m/s ${diary.weather!.windDirection ?? ''}'),
                  if (diary.weather!.waveHeight != null) _InfoChip('파고', '${diary.weather!.waveHeight} m'),
                ],
              ),
            ),
          ],
          if (diary.tackles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: '채비/미끼 기록',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: diary.tackles.map((t) {
                  final parts = <String>[
                    if (t.tackleType != null && t.tackleType!.isNotEmpty) '채비: ${t.tackleType}',
                    if (t.bait != null && t.bait!.isNotEmpty) '미끼: ${t.bait}',
                    if (t.fishCaught != null && t.fishCaught!.isNotEmpty) '어종: ${t.fishCaught}',
                    if (t.catchCount != null) '${t.catchCount}마리',
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${parts.isEmpty ? '기록' : parts.join(' · ')}'
                      '${t.memo != null && t.memo!.isNotEmpty ? '\n${t.memo}' : ''}',
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (diary.catches.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: '어획 기록',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: diary.catches.map((c) {
                  final detail = <String>[
                    '${c.count}마리',
                    if (c.sizeCm != null) '${c.sizeCm}cm',
                    if (c.weightG != null) '${c.weightG}g',
                    if (c.caughtTime != null) '${c.caughtTime} 잡음',
                  ].join(' · ');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('${c.fishName} — $detail'),
                  );
                }).toList(),
              ),
            ),
          ],
          if (diary.tide != null) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: '물때',
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (diary.tide!.highTideTime1 != null)
                    _InfoChip('만조1', '${diary.tide!.highTideTime1} (${diary.tide!.highTideHeight1}cm)'),
                  if (diary.tide!.lowTideTime1 != null)
                    _InfoChip('간조1', '${diary.tide!.lowTideTime1} (${diary.tide!.lowTideHeight1}cm)'),
                  if (diary.tide!.highTideTime2 != null)
                    _InfoChip('만조2', '${diary.tide!.highTideTime2} (${diary.tide!.highTideHeight2}cm)'),
                  if (diary.tide!.lowTideTime2 != null)
                    _InfoChip('간조2', '${diary.tide!.lowTideTime2} (${diary.tide!.lowTideHeight2}cm)'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
