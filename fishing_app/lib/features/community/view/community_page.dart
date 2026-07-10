import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/community/data/community_model.dart';
import 'package:fishing_app/features/community/provider/community_provider.dart';
import 'package:fishing_app/features/community/view/community_post_create_page.dart';
import 'package:fishing_app/features/community/view/community_post_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String weatherIcon(String? c) => switch (c) {
      '맑음' => '☀️',
      '구름많음' => '⛅',
      '흐림' => '☁️',
      '비' || '비/눈' => '🌧️',
      '눈' => '❄️',
      '소나기' => '🌦️',
      _ => '🌡️',
    };

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(communityFeedProvider.notifier).loadMore();
    }
  }

  void _startWritePost() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CommunityPostCreatePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncFeed = ref.watch(communityFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(communityFeedProvider)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startWritePost,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('글쓰기'),
      ),
      body: asyncFeed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('아직 공개된 낚시 일지가 없습니다.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(communityFeedProvider.future),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _PostCard(post: posts[i]),
            ),
          );
        },
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final CommunityPost post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr =
        '${post.visitDate.year}-${post.visitDate.month.toString().padLeft(2, '0')}-${post.visitDate.day.toString().padLeft(2, '0')}';

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CommunityPostDetailPage(visitId: post.visitId)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 14, child: Text(post.authorNickname.substring(0, 1))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(post.authorNickname, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              if (post.pointName != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      [post.pointName, post.pointAddress].where((s) => s != null && s.isNotEmpty).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ]),
              ],
              if (post.title != null && post.title!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(post.title!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
              if (post.weatherCondition != null || post.catches.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (post.weatherCondition != null)
                      Chip(
                        label: Text('${weatherIcon(post.weatherCondition)} ${post.weatherCondition}'),
                        visualDensity: VisualDensity.compact,
                      ),
                    for (final c in post.catches)
                      Chip(
                        label: Text('${c.fishName} ${c.count}마리'),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  InkWell(
                    onTap: () => ref.read(communityFeedProvider.notifier).toggleLike(post.visitId, post.liked),
                    child: Row(
                      children: [
                        Icon(
                          post.liked ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: post.liked ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text('${post.likeCount}'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.mode_comment_outlined, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
