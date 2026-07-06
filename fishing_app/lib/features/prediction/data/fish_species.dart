class FishSpecies {
  final String name;
  final String emoji;
  final List<int> peakMonths;
  final double minTemp;
  final double maxTemp;
  final double maxWindSpeed;
  final String description;

  const FishSpecies({
    required this.name,
    required this.emoji,
    required this.peakMonths,
    required this.minTemp,
    required this.maxTemp,
    required this.maxWindSpeed,
    required this.description,
  });

  bool get isInSeason {
    final month = DateTime.now().month;
    return peakMonths.contains(month);
  }

  // 어종별 낚시 점수 보정 (날씨 기반)
  int adjustScore(int baseScore, double? temp, double? windSpeed) {
    int score = baseScore;
    if (temp != null) {
      if (temp >= minTemp && temp <= maxTemp) score += 15;
      else if (temp < minTemp - 5 || temp > maxTemp + 5) score -= 20;
      else score -= 5;
    }
    if (windSpeed != null && windSpeed > maxWindSpeed) {
      score -= ((windSpeed - maxWindSpeed) * 5).round();
    }
    if (isInSeason) score += 10;
    return score.clamp(0, 100);
  }
}

const fishSpeciesList = [
  FishSpecies(
    name: '농어',
    emoji: '🐟',
    peakMonths: [5, 6, 7, 8, 9, 10],
    minTemp: 15,
    maxTemp: 28,
    maxWindSpeed: 6,
    description: '봄~가을 연안 낚시의 대표 어종',
  ),
  FishSpecies(
    name: '감성돔',
    emoji: '🐠',
    peakMonths: [3, 4, 5, 9, 10, 11],
    minTemp: 12,
    maxTemp: 22,
    maxWindSpeed: 5,
    description: '봄·가을 갯바위 낚시 인기 어종',
  ),
  FishSpecies(
    name: '참돔',
    emoji: '🎣',
    peakMonths: [4, 5, 9, 10, 11],
    minTemp: 13,
    maxTemp: 23,
    maxWindSpeed: 5,
    description: '봄·가을 선상 낚시 대표 어종',
  ),
  FishSpecies(
    name: '방어',
    emoji: '🐡',
    peakMonths: [10, 11, 12, 1, 2],
    minTemp: 5,
    maxTemp: 18,
    maxWindSpeed: 7,
    description: '가을~겨울 제주·남해 최고 어종',
  ),
  FishSpecies(
    name: '고등어',
    emoji: '🐟',
    peakMonths: [4, 5, 6, 9, 10],
    minTemp: 12,
    maxTemp: 24,
    maxWindSpeed: 8,
    description: '봄·가을 항구 및 방파제 인기 어종',
  ),
  FishSpecies(
    name: '삼치',
    emoji: '🎣',
    peakMonths: [9, 10, 11],
    minTemp: 15,
    maxTemp: 25,
    maxWindSpeed: 6,
    description: '가을 루어·선상 낚시 최고 어종',
  ),
  FishSpecies(
    name: '볼락',
    emoji: '🐠',
    peakMonths: [11, 12, 1, 2, 3],
    minTemp: 5,
    maxTemp: 15,
    maxWindSpeed: 5,
    description: '겨울~봄 야간 방파제 낚시 어종',
  ),
  FishSpecies(
    name: '우럭',
    emoji: '🐟',
    peakMonths: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    minTemp: 8,
    maxTemp: 24,
    maxWindSpeed: 7,
    description: '연중 낚을 수 있는 선상 낚시 대표 어종',
  ),
  FishSpecies(
    name: '갈치',
    emoji: '🎣',
    peakMonths: [7, 8, 9, 10],
    minTemp: 20,
    maxTemp: 30,
    maxWindSpeed: 5,
    description: '여름~가을 야간 선상 낚시 어종',
  ),
  FishSpecies(
    name: '광어',
    emoji: '🐡',
    peakMonths: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    minTemp: 8,
    maxTemp: 22,
    maxWindSpeed: 6,
    description: '연중 루어·선상 낚시 인기 어종',
  ),
];
