import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/diary/data/diary_model.dart';
import 'package:fishing_app/features/diary/provider/diary_provider.dart';
import 'package:fishing_app/features/diary/view/diary_create_page.dart';
import 'package:fishing_app/features/diary/view/diary_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryListPage extends ConsumerWidget {
  const DiaryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDiaries = ref.watch(diariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('낚시 일지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(diariesProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(diariesProvider.future),
        child: asyncDiaries.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 120),
              Center(child: Text(apiErrorMessage(e))),
            ],
          ),
          data: (diaries) {
            if (diaries.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('작성된 낚시 일지가 없습니다.\n오른쪽 아래 + 버튼으로 작성해보세요.', textAlign: TextAlign.center)),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: diaries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _DiaryCard(diary: diaries[i]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DiaryCreatePage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DiaryCard extends StatelessWidget {
  final Diary diary;
  const _DiaryCard({required this.diary});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${diary.visitDate.year}-${diary.visitDate.month.toString().padLeft(2, '0')}-${diary.visitDate.day.toString().padLeft(2, '0')}';
    final totalCatch = diary.catches.fold<int>(0, (sum, c) => sum + c.count);

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DiaryDetailPage(diary: diary)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const Spacer(),
                  if (diary.pointName != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Chip(
                        avatar: const Icon(Icons.location_on, size: 12),
                        label: Text(diary.pointName!, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
              if (diary.title != null && diary.title!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(diary.title!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
              if (diary.weather?.condition != null) ...[
                const SizedBox(height: 4),
                Text('날씨: ${diary.weather!.condition}'
                    '${diary.weather!.temperature != null ? ' ${diary.weather!.temperature!.toStringAsFixed(0)}°C' : ''}'),
              ],
              if (totalCatch > 0) ...[
                const SizedBox(height: 4),
                Text('어획: $totalCatch마리 (${diary.catches.map((c) => c.fishName).toSet().join(', ')})'),
              ],
              if (diary.memo != null && diary.memo!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  diary.memo!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
