import 'package:dio/dio.dart';
import 'package:fishing_app/core/api/api_client.dart';
import 'package:fishing_app/features/community/data/community_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'community_repository.g.dart';

@riverpod
CommunityRepository communityRepository(Ref ref) {
  return CommunityRepository(ref.watch(dioProvider));
}

class CommunityRepository {
  final Dio _dio;
  CommunityRepository(this._dio);

  Future<CommunityPostPage> getPosts({int page = 0, int size = 20}) async {
    final res = await _dio.get('/community/posts', queryParameters: {'page': page, 'size': size});
    return CommunityPostPage.fromJson(res.data as Map<String, dynamic>);
  }

  Future<CommunityPostDetail> getPost(int visitId) async {
    final res = await _dio.get('/community/posts/$visitId');
    return CommunityPostDetail.fromJson(res.data as Map<String, dynamic>);
  }

  Future<LikeResult> like(int visitId) async {
    final res = await _dio.post('/community/posts/$visitId/likes');
    return LikeResult.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> unlike(int visitId) => _dio.delete('/community/posts/$visitId/likes');

  Future<List<CommunityComment>> getComments(int visitId) async {
    final res = await _dio.get('/community/posts/$visitId/comments');
    return (res.data as List).map((e) => CommunityComment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CommunityComment> createComment(int visitId, String content) async {
    final res = await _dio.post('/community/posts/$visitId/comments', data: {'content': content});
    return CommunityComment.fromJson(res.data as Map<String, dynamic>);
  }

  Future<CommunityComment> updateComment(int commentId, String content) async {
    final res = await _dio.put('/community/comments/$commentId', data: {'content': content});
    return CommunityComment.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteComment(int commentId) => _dio.delete('/community/comments/$commentId');
}
