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
  FishSpecies(
    name: '문어',
    emoji: '🐙',
    peakMonths: [9, 10, 11, 12, 1, 2, 3],
    minTemp: 8,
    maxTemp: 20,
    maxWindSpeed: 6,
    description: '가을~겨울 갯바위·선상 낚시 인기 어종',
  ),
  FishSpecies(
    name: '오징어',
    emoji: '🦑',
    peakMonths: [6, 7, 8, 9, 10, 11, 12],
    minTemp: 15,
    maxTemp: 25,
    maxWindSpeed: 6,
    description: '여름~가을 야간 에깅·선상 낚시 대표 어종',
  ),
  FishSpecies(
    name: '쭈꾸미',
    emoji: '🐙',
    peakMonths: [3, 4, 5, 9, 10, 11],
    minTemp: 12,
    maxTemp: 22,
    maxWindSpeed: 6,
    description: '봄·가을 서해 대표 주꾸미 낚시 시즌',
  ),
  FishSpecies(
    name: '한치',
    emoji: '🦑',
    peakMonths: [6, 7, 8, 9, 10],
    minTemp: 18,
    maxTemp: 26,
    maxWindSpeed: 6,
    description: '여름~가을 제주 대표 한치 낚시 시즌',
  ),
  FishSpecies(
    name: '갑오징어',
    emoji: '🦑',
    peakMonths: [4, 5, 6, 10, 11],
    minTemp: 14,
    maxTemp: 24,
    maxWindSpeed: 6,
    description: '봄·가을 연안 갑오징어 낚시 시즌',
  ),
  FishSpecies(
    name: '꽃게',
    emoji: '🦀',
    peakMonths: [4, 5, 6, 9, 10, 11],
    minTemp: 12,
    maxTemp: 24,
    maxWindSpeed: 7,
    description: '봄·가을 서해 꽃게 낚시 대표 시즌',
  ),
  FishSpecies(
    name: '대하',
    emoji: '🦐',
    peakMonths: [9, 10, 11],
    minTemp: 15,
    maxTemp: 24,
    maxWindSpeed: 6,
    description: '가을 서해 대하 낚시·축제 시즌',
  ),
  FishSpecies(
    name: '전어',
    emoji: '🐟',
    peakMonths: [8, 9, 10],
    minTemp: 18,
    maxTemp: 26,
    maxWindSpeed: 6,
    description: '가을 전어 낚시 축제 시즌',
  ),
  FishSpecies(
    name: '숭어',
    emoji: '🐟',
    peakMonths: [9, 10, 11, 12, 1, 2],
    minTemp: 8,
    maxTemp: 20,
    maxWindSpeed: 7,
    description: '가을~겨울 방파제·하구 대표 어종',
  ),
  FishSpecies(
    name: '학공치',
    emoji: '🎣',
    peakMonths: [10, 11, 12, 1],
    minTemp: 8,
    maxTemp: 18,
    maxWindSpeed: 6,
    description: '가을~겨울 학공치 낚시 인기 시즌',
  ),
  FishSpecies(
    name: '벵에돔',
    emoji: '🐠',
    peakMonths: [6, 7, 8, 9, 10],
    minTemp: 18,
    maxTemp: 26,
    maxWindSpeed: 6,
    description: '여름~가을 갯바위 벵에돔 낚시 시즌',
  ),
  FishSpecies(
    name: '돌돔',
    emoji: '🐡',
    peakMonths: [6, 7, 8, 9],
    minTemp: 20,
    maxTemp: 27,
    maxWindSpeed: 5,
    description: '여름 갯바위 돌돔 낚시 최고 시즌',
  ),
  FishSpecies(
    name: '다금바리',
    emoji: '🐡',
    peakMonths: [6, 7, 8, 9],
    minTemp: 20,
    maxTemp: 27,
    maxWindSpeed: 5,
    description: '여름 제주 다금바리 낚시 시즌',
  ),
  FishSpecies(
    name: '참조기',
    emoji: '🐟',
    peakMonths: [4, 5, 6],
    minTemp: 14,
    maxTemp: 22,
    maxWindSpeed: 6,
    description: '봄 서해 참조기 낚시 시즌',
  ),
  FishSpecies(
    name: '민어',
    emoji: '🐟',
    peakMonths: [7, 8, 9],
    minTemp: 20,
    maxTemp: 28,
    maxWindSpeed: 6,
    description: '여름 서해 민어 낚시 대표 시즌',
  ),
  FishSpecies(
    name: '열기',
    emoji: '🐠',
    peakMonths: [11, 12, 1, 2, 3],
    minTemp: 8,
    maxTemp: 16,
    maxWindSpeed: 6,
    description: '겨울 선상 열기(불볼락) 낚시 인기 어종',
  ),
  FishSpecies(
    name: '가자미',
    emoji: '🐟',
    peakMonths: [11, 12, 1, 2, 3],
    minTemp: 5,
    maxTemp: 15,
    maxWindSpeed: 6,
    description: '겨울 선상 가자미 낚시 시즌',
  ),
  FishSpecies(
    name: '보리멸',
    emoji: '🐟',
    peakMonths: [5, 6, 7, 8, 9],
    minTemp: 18,
    maxTemp: 26,
    maxWindSpeed: 5,
    description: '여름 백사장 보리멸 낚시 시즌',
  ),
  FishSpecies(
    name: '노래미',
    emoji: '🐟',
    peakMonths: [1, 2, 3, 4, 10, 11, 12],
    minTemp: 8,
    maxTemp: 18,
    maxWindSpeed: 6,
    description: '가을~봄 갯바위 노래미 낚시 어종',
  ),
  FishSpecies(
    name: '대구',
    emoji: '🐟',
    peakMonths: [12, 1, 2],
    minTemp: 2,
    maxTemp: 12,
    maxWindSpeed: 7,
    description: '겨울 진해만 대구 낚시 시즌',
  ),
];
