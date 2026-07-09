import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/point/data/point_model.dart';
import 'package:fishing_app/features/point/provider/point_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PointListPage extends ConsumerWidget {
  const PointListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPoints = ref.watch(pointsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 포인트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(pointsProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(pointsProvider.future),
        child: asyncPoints.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 120),
              Center(child: Text(apiErrorMessage(e))),
            ],
          ),
          data: (points) {
            if (points.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('등록된 낚시 포인트가 없습니다.\n오른쪽 아래 + 버튼으로 추가해보세요.', textAlign: TextAlign.center)),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: points.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _PointCard(point: points[i]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/points/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  final FishingPoint point;
  const _PointCard({required this.point});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => context.push('/points/${point.id}'),
        title: Text(point.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (point.address != null && point.address!.isNotEmpty)
              Text(point.address!, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (point.fishType != null && point.fishType!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Chip(
                  label: Text(point.fishType!, style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
        trailing: point.isPublic ? const Icon(Icons.public, color: Colors.blue) : null,
      ),
    );
  }
}
