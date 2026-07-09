import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/point/data/point_model.dart';
import 'package:fishing_app/features/point/provider/point_provider.dart';
import 'package:fishing_app/features/point/view/visit_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PointDetailPage extends ConsumerWidget {
  final int pointId;
  const PointDetailPage({super.key, required this.pointId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPoint = ref.watch(pointDetailProvider(pointId));
    final asyncVisits = ref.watch(pointVisitsProvider(pointId));

    return Scaffold(
      appBar: AppBar(
        title: asyncPoint.maybeWhen(data: (p) => Text(p.name), orElse: () => const Text('포인트 상세')),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pointDetailProvider(pointId));
          ref.invalidate(pointVisitsProvider(pointId));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            asyncPoint.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
              error: (e, _) => Padding(padding: const EdgeInsets.all(24), child: Text(apiErrorMessage(e))),
              data: (point) => _PointInfoCard(point: point),
            ),
            const SizedBox(height: 20),
            Text('방문 기록', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            asyncVisits.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
              error: (e, _) => Padding(padding: const EdgeInsets.all(24), child: Text(apiErrorMessage(e))),
              data: (visits) {
                if (visits.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('아직 방문 기록이 없습니다.')),
                  );
                }
                return Column(
                  children: visits.map((v) => _VisitCard(visit: v)).toList(),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/points/$pointId/visits/create'),
        icon: const Icon(Icons.add),
        label: const Text('방문 기록 추가'),
      ),
    );
  }
}

class _PointInfoCard extends StatelessWidget {
  final FishingPoint point;
  const _PointInfoCard({required this.point});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(point.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                if (point.isPublic) const Icon(Icons.public, color: Colors.blue),
              ],
            ),
            if (point.address != null && point.address!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(point.address!, style: const TextStyle(color: Colors.grey))),
              ]),
            ],
            if (point.fishType != null && point.fishType!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Chip(label: Text(point.fishType!), visualDensity: VisualDensity.compact),
            ],
            if (point.description != null && point.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(point.description!),
            ],
          ],
        ),
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final PointVisit visit;
  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${visit.visitDate.year}-${visit.visitDate.month.toString().padLeft(2, '0')}-${visit.visitDate.day.toString().padLeft(2, '0')}';
    final totalCatch = visit.catches.fold<int>(0, (sum, c) => sum + c.count);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => VisitDetailPage(visit: visit)),
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
                  if (visit.isPublic) const Icon(Icons.public, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
              if (visit.title != null && visit.title!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(visit.title!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
              if (visit.weather?.condition != null) ...[
                const SizedBox(height: 4),
                Text('날씨: ${visit.weather!.condition}'
                    '${visit.weather!.temperature != null ? ' ${visit.weather!.temperature!.toStringAsFixed(0)}°C' : ''}'),
              ],
              if (totalCatch > 0) ...[
                const SizedBox(height: 4),
                Text('어획: $totalCatch마리 (${visit.catches.map((c) => c.fishName).toSet().join(', ')})'),
              ],
              if (visit.memo != null && visit.memo!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  visit.memo!,
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
