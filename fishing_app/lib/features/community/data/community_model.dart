import 'package:fishing_app/features/prediction/data/prediction_model.dart';

class CatchSummary {
  final String fishName;
  final int count;
  CatchSummary({required this.fishName, required this.count});

  factory CatchSummary.fromJson(Map<String, dynamic> json) => CatchSummary(
        fishName: json['fishName'] as String,
        count: json['count'] as int,
      );
}

class CommunityPost {
  final int visitId;
  final String authorNickname;
  final String? pointName;
  final String? pointAddress;
  final DateTime visitDate;
  final String? title;
  final String? weatherCondition;
  final List<CatchSummary> catches;
  final int likeCount;
  final int commentCount;
  final bool liked;

  CommunityPost({
    required this.visitId,
    required this.authorNickname,
    this.pointName,
    this.pointAddress,
    required this.visitDate,
    this.title,
    this.weatherCondition,
    this.catches = const [],
    required this.likeCount,
    required this.commentCount,
    required this.liked,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
        visitId: json['visitId'] as int,
        authorNickname: json['authorNickname'] as String,
        pointName: json['pointName'] as String?,
        pointAddress: json['pointAddress'] as String?,
        visitDate: DateTime.parse(json['visitDate'] as String),
        title: json['title'] as String?,
        weatherCondition: json['weatherCondition'] as String?,
        catches: (json['catches'] as List<dynamic>? ?? [])
            .map((e) => CatchSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
        likeCount: json['likeCount'] as int,
        commentCount: json['commentCount'] as int,
        liked: json['liked'] as bool,
      );
}

class CommunityPostPage {
  final List<CommunityPost> content;
  final bool last;
  final int number;

  CommunityPostPage({required this.content, required this.last, required this.number});

  factory CommunityPostPage.fromJson(Map<String, dynamic> json) => CommunityPostPage(
        content: (json['content'] as List<dynamic>)
            .map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
            .toList(),
        last: json['last'] as bool,
        number: json['number'] as int,
      );
}

class CommunityPostDetail {
  final int visitId;
  final String authorNickname;
  final String? pointName;
  final String? pointAddress;
  final DateTime visitDate;
  final String? title;
  final String? content;
  final String? memo;
  final WeatherData? weather;
  final TideData? tide;
  final List<CatchSummary> catches;
  final int likeCount;
  final int commentCount;
  final bool liked;

  CommunityPostDetail({
    required this.visitId,
    required this.authorNickname,
    this.pointName,
    this.pointAddress,
    required this.visitDate,
    this.title,
    this.content,
    this.memo,
    this.weather,
    this.tide,
    this.catches = const [],
    required this.likeCount,
    required this.commentCount,
    required this.liked,
  });

  factory CommunityPostDetail.fromJson(Map<String, dynamic> json) => CommunityPostDetail(
        visitId: json['visitId'] as int,
        authorNickname: json['authorNickname'] as String,
        pointName: json['pointName'] as String?,
        pointAddress: json['pointAddress'] as String?,
        visitDate: DateTime.parse(json['visitDate'] as String),
        title: json['title'] as String?,
        content: json['content'] as String?,
        memo: json['memo'] as String?,
        weather: json['weather'] != null ? WeatherData.fromJson(json['weather'] as Map<String, dynamic>) : null,
        tide: json['tide'] != null ? TideData.fromJson(json['tide'] as Map<String, dynamic>) : null,
        catches: (json['catches'] as List<dynamic>? ?? [])
            .map((e) => CatchSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
        likeCount: json['likeCount'] as int,
        commentCount: json['commentCount'] as int,
        liked: json['liked'] as bool,
      );
}

class LikeResult {
  final int likeCount;
  final bool liked;
  LikeResult({required this.likeCount, required this.liked});

  factory LikeResult.fromJson(Map<String, dynamic> json) => LikeResult(
        likeCount: json['likeCount'] as int,
        liked: json['liked'] as bool,
      );
}

class CommunityComment {
  final int id;
  final String authorNickname;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommunityComment({
    required this.id,
    required this.authorNickname,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) => CommunityComment(
        id: json['id'] as int,
        authorNickname: json['authorNickname'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
      );
}
