import 'package:fishing_app/features/point/data/point_model.dart';
import 'package:flutter/material.dart';

class VisitDetailPage extends StatelessWidget {
  final PointVisit visit;
  const VisitDetailPage({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${visit.visitDate.year}-${visit.visitDate.month.toString().padLeft(2, '0')}-${visit.visitDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: Text(visit.title?.isNotEmpty == true ? visit.title! : '방문 기록')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text(dateStr, style: const TextStyle(color: Colors.grey)),
              const Spacer(),
              if (visit.isPublic)
                const Chip(
                  avatar: Icon(Icons.public, size: 16, color: Colors.blue),
                  label: Text('공개'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          if (visit.content != null && visit.content!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(title: '내용', child: Text(visit.content!)),
          ],
          if (visit.memo != null && visit.memo!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(title: '메모', child: Text(visit.memo!)),
          ],
          if (visit.weather != null) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: '날씨',
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (visit.weather!.condition != null) _InfoChip('날씨', visit.weather!.condition!),
                  if (visit.weather!.temperature != null)
                    _InfoChip('기온', '${visit.weather!.temperature!.toStringAsFixed(1)}°C'),
                  if (visit.weather!.humidity != null) _InfoChip('습도', '${visit.weather!.humidity}%'),
                  if (visit.weather!.windSpeed != null)
                    _InfoChip('풍속', '${visit.weather!.windSpeed} m/s ${visit.weather!.windDirection ?? ''}'),
                  if (visit.weather!.waveHeight != null) _InfoChip('파고', '${visit.weather!.waveHeight} m'),
                ],
              ),
            ),
          ],
          if (visit.tackles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: '채비/미끼 기록',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: visit.tackles.map((t) {
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
          if (visit.catches.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: '어획 기록',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: visit.catches.map((c) {
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
          if (visit.tide != null) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: '물때',
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (visit.tide!.highTideTime1 != null)
                    _InfoChip('만조1', '${visit.tide!.highTideTime1} (${visit.tide!.highTideHeight1}cm)'),
                  if (visit.tide!.lowTideTime1 != null)
                    _InfoChip('간조1', '${visit.tide!.lowTideTime1} (${visit.tide!.lowTideHeight1}cm)'),
                  if (visit.tide!.highTideTime2 != null)
                    _InfoChip('만조2', '${visit.tide!.highTideTime2} (${visit.tide!.highTideHeight2}cm)'),
                  if (visit.tide!.lowTideTime2 != null)
                    _InfoChip('간조2', '${visit.tide!.lowTideTime2} (${visit.tide!.lowTideHeight2}cm)'),
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
