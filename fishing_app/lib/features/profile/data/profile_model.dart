class UserProfile {
  final int id;
  final String email;
  final String nickname;
  final String mapProvider;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.nickname,
    required this.mapProvider,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as int,
        email: json['email'] as String,
        nickname: json['nickname'] as String,
        mapProvider: json['mapProvider'] as String,
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      );
}

class PreferredFishSpeciesData {
  final int? id;
  final String speciesName;
  final bool isDefault;

  PreferredFishSpeciesData({this.id, required this.speciesName, this.isDefault = false});

  factory PreferredFishSpeciesData.fromJson(Map<String, dynamic> json) => PreferredFishSpeciesData(
        id: json['id'] as int?,
        speciesName: json['speciesName'] as String,
        isDefault: json['isDefault'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'speciesName': speciesName,
        'isDefault': isDefault,
      };
}

class PreferredRegion {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final bool isDefault;
  final List<PreferredFishSpeciesData> species;
  final DateTime? createdAt;

  PreferredRegion({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.isDefault = false,
    this.species = const [],
    this.createdAt,
  });

  factory PreferredRegion.fromJson(Map<String, dynamic> json) => PreferredRegion(
        id: json['id'] as int,
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'] as String?,
        isDefault: json['isDefault'] as bool? ?? false,
        species: (json['species'] as List<dynamic>? ?? [])
            .map((e) => PreferredFishSpeciesData.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      );
}
