import 'package:fishing_app/features/community/data/community_model.dart';
import 'package:fishing_app/features/community/data/community_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'community_provider.g.dart';

@riverpod
class CommunityFeed extends _$CommunityFeed {
  int _page = 0;
  bool _hasMore = true;

  @override
  Future<List<CommunityPost>> build() async {
    _page = 0;
    _hasMore = true;
    final result = await ref.read(communityRepositoryProvider).getPosts(page: 0);
    _hasMore = !result.last;
    return result.content;
  }

  bool get hasMore => _hasMore;

  Future<void> loadMore() async {
    if (!_hasMore) return;
    final current = state.valueOrNull ?? [];
    final nextPage = _page + 1;
    final result = await ref.read(communityRepositoryProvider).getPosts(page: nextPage);
    _page = nextPage;
    _hasMore = !result.last;
    state = AsyncData([...current, ...result.content]);
  }

  Future<void> toggleLike(int visitId, bool currentlyLiked) async {
    final repo = ref.read(communityRepositoryProvider);
    final current = state.valueOrNull;
    if (current == null) return;
    final post = current.firstWhere((p) => p.visitId == visitId);

    late final int newCount;
    late final bool newLiked;
    if (currentlyLiked) {
      await repo.unlike(visitId);
      newCount = post.likeCount > 0 ? post.likeCount - 1 : 0;
      newLiked = false;
    } else {
      final result = await repo.like(visitId);
      newCount = result.likeCount;
      newLiked = result.liked;
    }

    state = AsyncData([
      for (final p in current)
        if (p.visitId == visitId)
          CommunityPost(
            visitId: p.visitId,
            authorNickname: p.authorNickname,
            pointName: p.pointName,
            pointAddress: p.pointAddress,
            visitDate: p.visitDate,
            title: p.title,
            weatherCondition: p.weatherCondition,
            catches: p.catches,
            likeCount: newCount,
            commentCount: p.commentCount,
            liked: newLiked,
          )
        else
          p,
    ]);
  }
}

@riverpod
Future<CommunityPostDetail> communityPostDetail(Ref ref, int visitId) {
  return ref.watch(communityRepositoryProvider).getPost(visitId);
}

@riverpod
class CommunityDetailLikeActions extends _$CommunityDetailLikeActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> toggle(int visitId, bool currentlyLiked) async {
    final repo = ref.read(communityRepositoryProvider);
    if (currentlyLiked) {
      await repo.unlike(visitId);
    } else {
      await repo.like(visitId);
    }
    ref.invalidate(communityPostDetailProvider(visitId));
    ref.invalidate(communityFeedProvider);
  }
}

@riverpod
Future<List<CommunityComment>> communityComments(Ref ref, int visitId) {
  return ref.watch(communityRepositoryProvider).getComments(visitId);
}

@riverpod
class CommunityCommentActions extends _$CommunityCommentActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create(int visitId, String content) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(communityRepositoryProvider).createComment(visitId, content));
    if (state is AsyncData) {
      ref.invalidate(communityCommentsProvider(visitId));
      ref.invalidate(communityPostDetailProvider(visitId));
      ref.invalidate(communityFeedProvider);
    }
    return state is AsyncData;
  }

  Future<bool> update(int commentId, int visitId, String content) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(communityRepositoryProvider).updateComment(commentId, content));
    if (state is AsyncData) ref.invalidate(communityCommentsProvider(visitId));
    return state is AsyncData;
  }

  Future<bool> delete(int commentId, int visitId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(communityRepositoryProvider).deleteComment(commentId));
    if (state is AsyncData) {
      ref.invalidate(communityCommentsProvider(visitId));
      ref.invalidate(communityPostDetailProvider(visitId));
      ref.invalidate(communityFeedProvider);
    }
    return state is AsyncData;
  }
}
