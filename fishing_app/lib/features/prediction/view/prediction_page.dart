import 'package:fishing_app/features/prediction/data/fish_species.dart';
import 'package:fishing_app/features/prediction/data/prediction_model.dart';
import 'package:fishing_app/features/prediction/provider/prediction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PredictionPage extends ConsumerStatefulWidget {
  const PredictionPage({super.key});

  @override
  ConsumerState<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends ConsumerState<PredictionPage> {
  final _locationController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);
    final results = await ref.read(locationSearchProvider(query).future);
    setState(() => _isSearching = false);
    if (!mounted) return;

    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('검색 결과가 없습니다.')),
      );
      return;
    }
    if (results.length == 1) {
      _selectLocation(results.first);
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
          onTap: () { Navigator.pop(ctx); _selectLocation(results[i]); },
        ),
      ),
    );
  }

  void _selectLocation(LocationState loc) {
    ref.read(selectedLocationProvider.notifier).select(loc);
    _locationController.text = loc.name;
    FocusScope.of(context).unfocus();
  }

  void _resetLocation() {
    ref.read(selectedLocationProvider.notifier).reset();
    _locationController.clear();
    _invalidateAll();
  }

  void _invalidateAll() {
    ref.invalidate(predictionProvider);
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedLocationProvider);
    final selectedFish = ref.watch(selectedFishProvider);
    final asyncPrediction = ref.watch(predictionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('조과 예측'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _invalidateAll),
        ],
      ),
      body: Column(
        children: [
          // 지역 검색
          _LocationSearchBar(
            controller: _locationController,
            isSearching: _isSearching,
            hasSelected: selected != null,
            onSearch: _searchLocation,
            onReset: _resetLocation,
          ),
          // 날짜 탭
          _DateTabBar(onDateChanged: _invalidateAll),
          // 어종 검색
          _FishSearchBar(),
          const Divider(height: 1),
          // 본문
          Expanded(
            child: asyncPrediction.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(error: e, onRetry: _invalidateAll),
              data: (result) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ScoreCard(
                      result: result,
                      locationName: selected?.name,
                      selectedFish: selectedFish,
                    ),
                    const SizedBox(height: 16),
                    if (result.hourlyWeather.isNotEmpty)
                      _HourlyWeatherCard(items: result.hourlyWeather)
                    else
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('시간대별 날씨 데이터가 없습니다.',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (result.weather != null) _WeatherDetailCard(weather: result.weather!),
                    const SizedBox(height: 16),
                    if (result.tide != null) _TideCard(tide: result.tide!),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 지역 검색 ───────────────────────────────────────────────────────────────

const _presetLocations = [
  ('여수', '여수시'), ('통영', '통영시'), ('거제', '거제시'), ('포항', '포항시'),
  ('부산', '부산광역시'), ('목포', '목포시'), ('강릉', '강릉시'), ('제주', '제주시'),
];

class _LocationSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final bool hasSelected;
  final ValueChanged<String> onSearch;
  final VoidCallback onReset;

  const _LocationSearchBar({
    required this.controller,
    required this.isSearching,
    required this.hasSelected,
    required this.onSearch,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '낚시 지역 검색 (예: 여수, 통영, 거제)',
              prefixIcon: isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : const Icon(Icons.search),
              suffixIcon: hasSelected
                  ? IconButton(icon: const Icon(Icons.my_location), onPressed: onReset)
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
            onSubmitted: onSearch,
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _presetLocations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final (label, query) = _presetLocations[i];
              return ActionChip(
                label: Text(label, style: const TextStyle(fontSize: 12)),
                padding: EdgeInsets.zero,
                onPressed: () => onSearch(query),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ─── 날짜 탭 ────────────────────────────────────────────────────────────────

class _DateTabBar extends ConsumerWidget {
  final VoidCallback onDateChanged;
  const _DateTabBar({required this.onDateChanged});

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final date = DateTime(now.year, now.month, now.day + i);
          final isSelected = _isSameDay(selectedDate, date);
          final weekday = _weekdays[date.weekday - 1];
          final label = i == 0 ? '오늘' : '${date.month}/${date.day}($weekday)';
          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) {
              ref.read(selectedDateProvider.notifier).select(date);
              onDateChanged();
            },
          );
        },
      ),
    );
  }
}

// ─── 어종 검색 ───────────────────────────────────────────────────────────────

class _FishSearchBar extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FishSearchBar> createState() => _FishSearchBarState();
}

class _FishSearchBarState extends ConsumerState<_FishSearchBar> {
  final _controller = TextEditingController();
  List<FishSpecies> _results = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _results = fishSpeciesList.where((f) => f.name.contains(query)).toList());
  }

  void _select(FishSpecies fish) {
    ref.read(selectedFishProvider.notifier).select(fish);
    _controller.text = '${fish.emoji} ${fish.name}';
    setState(() => _results = []);
    FocusScope.of(context).unfocus();
  }

  void _clear() {
    ref.read(selectedFishProvider.notifier).clear();
    _controller.clear();
    setState(() => _results = []);
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedFishProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: '대상 어종 검색 (예: 농어, 감성돔, 방어)',
              prefixIcon: const Icon(Icons.set_meal),
              suffixIcon: selected != null
                  ? IconButton(icon: const Icon(Icons.close), onPressed: _clear)
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
            onChanged: _onChanged,
          ),
        ),
        if (_results.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _results.map((fish) => ListTile(
                dense: true,
                leading: Text(fish.emoji, style: const TextStyle(fontSize: 20)),
                title: Text(fish.name),
                subtitle: Text(fish.description, style: const TextStyle(fontSize: 11)),
                trailing: fish.isInSeason
                    ? const Text('🎯 시즌', style: TextStyle(color: Colors.green, fontSize: 11))
                    : null,
                onTap: () => _select(fish),
              )).toList(),
            ),
          ),
      ],
    );
  }
}

// ─── 점수 카드 ───────────────────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  final PredictionResult result;
  final String? locationName;
  final FishSpecies? selectedFish;

  const _ScoreCard({required this.result, this.locationName, this.selectedFish});

  int get _score {
    final base = result.fishingScore ?? 50;
    if (selectedFish == null) return base;
    return selectedFish!.adjustScore(base, result.weather?.temperature, result.weather?.windSpeed);
  }

  String get _grade {
    final s = _score;
    if (s >= 80) return '매우 좋음';
    if (s >= 60) return '좋음';
    if (s >= 40) return '보통';
    if (s >= 20) return '나쁨';
    return '매우 나쁨';
  }

  Color _color(int s) {
    if (s >= 80) return Colors.blue;
    if (s >= 60) return Colors.green;
    if (s >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final score = _score;
    final color = _color(score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Text(result.date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            if (selectedFish != null) ...[
              const SizedBox(height: 4),
              Text('${selectedFish!.emoji} ${selectedFish!.name} 낚시 예측',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            ],
            const SizedBox(height: 12),
            Text('$score점',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_grade,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(locationName ?? '현재 위치 기준',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
            if (selectedFish != null && selectedFish!.isInSeason)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('🎯 지금이 시즌입니다!',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── 시간대별 날씨 ───────────────────────────────────────────────────────────

class _HourlyWeatherCard extends StatefulWidget {
  final List<HourlyWeatherItem> items;
  const _HourlyWeatherCard({required this.items});

  @override
  State<_HourlyWeatherCard> createState() => _HourlyWeatherCardState();
}

class _HourlyWeatherCardState extends State<_HourlyWeatherCard> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // 현재 시각에 가장 가까운 인덱스 선택
    final nowH = DateTime.now().hour;
    int closest = 0;
    int minDiff = 99;
    for (int i = 0; i < widget.items.length; i++) {
      final h = int.tryParse(widget.items[i].time.substring(0, 2)) ?? 0;
      final diff = (h - nowH).abs();
      if (diff < minDiff) { minDiff = diff; closest = i; }
    }
    _selectedIndex = closest;
  }

  String _icon(String? c) => switch (c) {
        '맑음' => '☀️', '구름많음' => '⛅', '흐림' => '☁️',
        '비' || '비/눈' => '🌧️', '눈' => '❄️', '소나기' => '🌦️', _ => '🌡️',
      };

  @override
  Widget build(BuildContext context) {
    final selected = widget.items[_selectedIndex];
    final w = selected.weather;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('시간대별 날씨',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // 시각 선택 가로 스크롤
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final item = widget.items[i];
                  final isSelected = i == _selectedIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.displayTime.replaceAll(' ', '\n'),
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected ? colorScheme.onPrimary : Colors.grey,
                              ),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          Text(_icon(item.weather.condition), style: const TextStyle(fontSize: 20)),
                          if (item.weather.temperature != null)
                            Text('${item.weather.temperature!.toStringAsFixed(0)}°',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? colorScheme.onPrimary : null,
                                )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // 선택된 시각 상세 정보
            Text(selected.displayTime,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _DetailChip(label: '날씨', value: '${_icon(w.condition)} ${w.condition ?? '-'}'),
                if (w.temperature != null)
                  _DetailChip(label: '기온', value: '${w.temperature!.toStringAsFixed(1)}°C'),
                if (w.humidity != null)
                  _DetailChip(label: '습도', value: '${w.humidity}%'),
                if (w.windSpeed != null)
                  _DetailChip(
                      label: '풍속',
                      value: '${w.windSpeed!.toStringAsFixed(1)} m/s'
                          '${w.windDirection != null ? ' ${w.windDirection}' : ''}'),
                if (w.waveHeight != null)
                  _DetailChip(label: '파고', value: '${w.waveHeight!.toStringAsFixed(1)} m'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final String value;
  const _DetailChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}

// ─── 날씨 상세 ───────────────────────────────────────────────────────────────

class _WeatherDetailCard extends StatelessWidget {
  final WeatherData weather;
  const _WeatherDetailCard({required this.weather});

  String _icon(String? c) => switch (c) {
        '맑음' => '☀️', '구름많음' => '⛅', '흐림' => '☁️',
        '비' || '비/눈' => '🌧️', '눈' => '❄️', '소나기' => '🌦️', _ => '🌡️',
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('날씨 상세',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            _Row(icon: _icon(weather.condition), label: '날씨', value: weather.condition ?? '-'),
            if (weather.temperature != null)
              _Row(icon: '🌡️', label: '기온', value: '${weather.temperature!.toStringAsFixed(1)}°C'),
            if (weather.humidity != null)
              _Row(icon: '💧', label: '습도', value: '${weather.humidity}%'),
            if (weather.windSpeed != null)
              _Row(icon: '💨', label: '풍속',
                  value: '${weather.windSpeed!.toStringAsFixed(1)} m/s'
                      '${weather.windDirection != null ? '  ${weather.windDirection}' : ''}'),
            if (weather.waveHeight != null)
              _Row(icon: '🌊', label: '파고', value: '${weather.waveHeight!.toStringAsFixed(1)} m'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String icon, label, value;
  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        SizedBox(width: 40, child: Text(label, style: const TextStyle(color: Colors.grey))),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ─── 조석 카드 ───────────────────────────────────────────────────────────────

class _TideCard extends StatelessWidget {
  final TideData tide;
  const _TideCard({required this.tide});

  @override
  Widget build(BuildContext context) {
    final entries = <({bool isHigh, String time, int? height})>[];
    if (tide.highTideTime1 != null)
      entries.add((isHigh: true, time: tide.highTideTime1!, height: tide.highTideHeight1));
    if (tide.lowTideTime1 != null)
      entries.add((isHigh: false, time: tide.lowTideTime1!, height: tide.lowTideHeight1));
    if (tide.highTideTime2 != null)
      entries.add((isHigh: true, time: tide.highTideTime2!, height: tide.highTideHeight2));
    if (tide.lowTideTime2 != null)
      entries.add((isHigh: false, time: tide.lowTideTime2!, height: tide.lowTideHeight2));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('조석', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            ...entries.map((e) {
              final color = e.isHigh ? Colors.blue : Colors.teal;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Text(e.isHigh ? '▲' : '▼', style: TextStyle(color: color, fontSize: 18)),
                  const SizedBox(width: 8),
                  SizedBox(width: 36,
                      child: Text(e.isHigh ? '만조' : '간조',
                          style: TextStyle(color: color, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 12),
                  Text(e.time, style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                  Text(e.height != null ? '${e.height} cm' : '-',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ]),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── 에러 뷰 ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 12),
        const Text('예측 데이터를 불러오지 못했습니다'),
        const SizedBox(height: 8),
        Text(error.toString(),
            style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
      ]),
    );
  }
}
