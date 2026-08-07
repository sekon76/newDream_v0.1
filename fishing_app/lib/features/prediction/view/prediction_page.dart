import 'package:fishing_app/features/point/view/map_picker_page.dart';
import 'package:fishing_app/features/prediction/data/fish_species.dart';
import 'package:fishing_app/features/prediction/data/prediction_model.dart';
import 'package:fishing_app/features/prediction/provider/prediction_provider.dart';
import 'package:fishing_app/features/profile/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

// 문의 접수 채널이 따로 없어서, 우선 개발자 이메일로 문의 메일을 보내는 방식으로 연결한다.
const _adminEmail = 'ringyee@naver.com';

class PredictionPage extends ConsumerStatefulWidget {
  const PredictionPage({super.key});

  @override
  ConsumerState<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends ConsumerState<PredictionPage> {
  final _locationController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _applyDefaultPreference();
  }

  // 로그인 후 조과예측 화면 첫 진입 시, 등록된 기본 선호 지역/어종이 있으면 자동 적용한다.
  // 이미 사용자가 위치를 선택한 상태라면 덮어쓰지 않는다.
  Future<void> _applyDefaultPreference() async {
    if (ref.read(selectedLocationProvider) != null) return;
    try {
      final defaultRegion = await ref.read(defaultPreferredRegionProvider.future);
      if (defaultRegion == null || !mounted) return;
      if (ref.read(selectedLocationProvider) != null) return;

      _selectLocation(LocationState(name: defaultRegion.name, lat: defaultRegion.latitude, lon: defaultRegion.longitude));

      String? defaultSpeciesName;
      for (final species in defaultRegion.species) {
        if (species.isDefault) {
          defaultSpeciesName = species.speciesName;
          break;
        }
      }
      if (defaultSpeciesName != null) {
        for (final fish in fishSpeciesList) {
          if (fish.name == defaultSpeciesName) {
            ref.read(selectedFishProvider.notifier).select(fish);
            break;
          }
        }
      }
    } catch (_) {
      // 기본값 자동 적용은 부가 기능이라 실패해도 예측 화면 자체는 정상 동작해야 한다.
    }
  }

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
      _openMapForLocation(results.first);
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
          onTap: () { Navigator.pop(ctx); _openMapForLocation(results[i]); },
        ),
      ),
    );
  }

  Future<void> _openMapForLocation(LocationState loc) async {
    final result = await Navigator.of(context).push<MapPickerResult>(
      MaterialPageRoute(builder: (_) => MapPickerPage(initialLat: loc.lat, initialLon: loc.lon)),
    );
    if (result == null || !mounted) return;
    final name = await reverseGeocodeName(result.latitude, result.longitude, fallback: loc.name);
    if (!mounted) return;
    final confirmed = LocationState(name: name, lat: result.latitude, lon: result.longitude);
    _selectLocation(confirmed);
    ref.read(recentLocationsProvider.notifier).add(confirmed);
  }

  void _selectRecentLocation(LocationState loc) {
    _selectLocation(loc);
    ref.read(recentLocationsProvider.notifier).add(loc);
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
    final recentLocations = ref.watch(recentLocationsProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('조과 예측'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 지역 검색
          _LocationSearchBar(
            controller: _locationController,
            isSearching: _isSearching,
            hasSelected: selected != null,
            recentLocations: recentLocations,
            onSearch: _searchLocation,
            onReset: _resetLocation,
            onSelectRecent: _selectRecentLocation,
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
              error: (_, __) => _ErrorView(onRetry: _invalidateAll),
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
                      _HourlyWeatherCard(
                        items: result.hourlyWeather,
                        hourlyWaterTemp: result.hourlyWaterTemp,
                      )
                    else
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('시간대별 날씨 데이터가 없습니다.',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (result.weather != null)
                      _WeatherDetailCard(weather: result.weather!, waterTemp: result.waterTemp),
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
  final List<LocationState> recentLocations;
  final ValueChanged<String> onSearch;
  final VoidCallback onReset;
  final ValueChanged<LocationState> onSelectRecent;

  const _LocationSearchBar({
    required this.controller,
    required this.isSearching,
    required this.hasSelected,
    required this.recentLocations,
    required this.onSearch,
    required this.onReset,
    required this.onSelectRecent,
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
          child: recentLocations.isNotEmpty
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: recentLocations.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, i) {
                    final loc = recentLocations[i];
                    return ActionChip(
                      avatar: const Icon(Icons.history, size: 14),
                      label: Text(loc.name, style: const TextStyle(fontSize: 12)),
                      padding: EdgeInsets.zero,
                      onPressed: () => onSelectRecent(loc),
                    );
                  },
                )
              : ListView.separated(
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
  bool _noMatch = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _noMatch = false;
      });
      return;
    }
    final matches = fishSpeciesList.where((f) => f.name.contains(query)).toList();
    setState(() {
      _results = matches;
      _noMatch = matches.isEmpty;
    });
  }

  void _select(FishSpecies fish) {
    ref.read(selectedFishProvider.notifier).select(fish);
    _controller.text = '${fish.emoji} ${fish.name}';
    setState(() {
      _results = [];
      _noMatch = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _clear() {
    ref.read(selectedFishProvider.notifier).clear();
    _controller.clear();
    setState(() {
      _results = [];
      _noMatch = false;
    });
  }

  Future<void> _contactAdmin() async {
    final query = _controller.text.trim();
    final uri = Uri(
      scheme: 'mailto',
      path: _adminEmail,
      query: {
        'subject': '[조황일지] 어종 추가 요청',
        'body': '"$query" 어종을 조과예측 대상 어종 목록에 추가해주세요.',
      }.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&'),
    );
    if (!await launchUrl(uri) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메일 앱을 열 수 없습니다.')),
      );
    }
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
        if (_noMatch)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '해당 어종에 대한 정보가 부족해서 예측이 어렵습니다.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                InkWell(
                  onTap: _contactAdmin,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '관리자에게 문의하기 →',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
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

  int? get _score {
    final base = result.fishingScore;
    if (base == null) return null;
    if (selectedFish == null) return base;
    return selectedFish!.adjustScore(base, result.weather?.temperature, result.weather?.windSpeed);
  }

  String get _grade {
    final s = _score;
    if (s == null) return result.fishingGrade ?? '예측 불가';
    if (s >= 80) return '매우 좋음';
    if (s >= 60) return '좋음';
    if (s >= 40) return '보통';
    if (s >= 20) return '나쁨';
    return '매우 나쁨';
  }

  Color _color(int? s) {
    if (s == null) return Colors.grey;
    if (s >= 80) return Colors.blue;
    if (s >= 60) return Colors.green;
    if (s >= 40) return Colors.orange;
    return Colors.red;
  }

  // 점수 산정에 영향을 준 핵심 요인을 간단히 설명한다.
  // 백엔드 PredictionService.calcScore / FishSpecies.adjustScore 판단 기준과 맞춰서 작성.
  List<String> get _reasons {
    final reasons = <String>[];
    final w = result.weather;

    if (w?.condition != null) {
      final text = switch (w!.condition) {
        '맑음' => '맑은 날씨',
        '구름많음' => '구름 많음',
        '흐림' => '흐린 날씨',
        '소나기' => '소나기',
        '비' || '비/눈' => '비',
        '눈' => '눈',
        _ => null,
      };
      if (text != null) reasons.add(text);
    }
    if (w?.temperature != null) {
      final t = w!.temperature!;
      if (t >= 15 && t <= 25) {
        reasons.add('기온 ${t.toStringAsFixed(0)}°C로 적당함');
      } else if (t < 0 || t > 30) {
        reasons.add('기온 ${t.toStringAsFixed(0)}°C로 부적합');
      }
    }
    if (w?.windSpeed != null) {
      final ws = w!.windSpeed!;
      if (ws < 3) {
        reasons.add('바람 ${ws.toStringAsFixed(1)}m/s로 잔잔함');
      } else if (ws >= 10) {
        reasons.add('바람 ${ws.toStringAsFixed(1)}m/s로 강함');
      }
    }
    if (w?.waveHeight != null && w!.waveHeight! >= 1.5) {
      reasons.add('파고 ${w.waveHeight!.toStringAsFixed(1)}m로 높음');
    }
    final t = result.tide;
    if (t?.highTideHeight1 != null && t?.lowTideHeight1 != null) {
      final range = t!.highTideHeight1! - t.lowTideHeight1!;
      if (range > 400) reasons.add('조석차가 커서 물때 좋음');
    }
    if (selectedFish != null) {
      if (selectedFish!.isInSeason) reasons.add('${selectedFish!.name} 제철 시즌');
      final temp = w?.temperature;
      if (temp != null && (temp < selectedFish!.minTemp - 5 || temp > selectedFish!.maxTemp + 5)) {
        reasons.add('${selectedFish!.name} 적정 수온 범위 벗어남');
      }
    }
    return reasons;
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
            if (score != null) ...[
              Text('$score점',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_grade,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            if (score != null && _reasons.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _reasons.take(3).join(' · '),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(locationName ?? '현재 위치 기준',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
            if (score != null && selectedFish != null && selectedFish!.isInSeason)
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
  final List<HourlyWaterTempItem> hourlyWaterTemp;
  const _HourlyWeatherCard({required this.items, this.hourlyWaterTemp = const []});

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

  double? _waterTempAt(String time) {
    for (final item in widget.hourlyWaterTemp) {
      if (item.time == time) return item.temperature;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.items[_selectedIndex];
    final w = selected.weather;
    final selectedWaterTemp = _waterTempAt(selected.time);
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
              height: 80,
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
                _DetailChip(
                  label: '수온',
                  value: selectedWaterTemp != null ? '${selectedWaterTemp.toStringAsFixed(1)}°C' : '-',
                ),
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
  final double? waterTemp;
  const _WeatherDetailCard({required this.weather, this.waterTemp});

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
            _Row(icon: '🌡️', label: '수온', value: waterTemp != null ? '${waterTemp!.toStringAsFixed(1)}°C' : '-'),
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
                  Text(e.height != null ? '해수면 높이 ${(e.height! / 100).toStringAsFixed(2)}m' : '-',
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
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 12),
        const Text('예측하지 못했습니다.'),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
      ]),
    );
  }
}
