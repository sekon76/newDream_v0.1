import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/community/data/community_model.dart';
import 'package:fishing_app/features/community/provider/community_provider.dart';
import 'package:fishing_app/features/community/view/community_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityPostDetailPage extends ConsumerStatefulWidget {
  final int visitId;
  const CommunityPostDetailPage({super.key, required this.visitId});

  @override
  ConsumerState<CommunityPostDetailPage> createState() => _CommunityPostDetailPageState();
}

class _CommunityPostDetailPageState extends ConsumerState<CommunityPostDetailPage> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final content = _commentCtrl.text.trim();
    if (content.isEmpty) return;
    final ok = await ref.read(communityCommentActionsProvider.notifier).create(widget.visitId, content);
    if (!mounted) return;
    if (ok) {
      _commentCtrl.clear();
      FocusScope.of(context).unfocus();
    } else {
      final error = ref.read(communityCommentActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 등록 실패: ${apiErrorMessage(error)}')),
      );
    }
  }

  Future<void> _editComment(CommunityComment comment) async {
    final controller = TextEditingController(text: comment.content);
    final newContent = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('댓글 수정'),
        content: TextField(controller: controller, maxLines: 3, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('수정'),
          ),
        ],
      ),
    );
    if (newContent == null || newContent.isEmpty || !mounted) return;
    final ok = await ref
        .read(communityCommentActionsProvider.notifier)
        .update(comment.id, widget.visitId, newContent);
    if (!mounted) return;
    if (!ok) {
      final error = ref.read(communityCommentActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 수정 실패: ${apiErrorMessage(error)}')),
      );
    }
  }

  Future<void> _deleteComment(CommunityComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('이 댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await ref.read(communityCommentActionsProvider.notifier).delete(comment.id, widget.visitId);
    if (!mounted) return;
    if (!ok) {
      final error = ref.read(communityCommentActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 삭제 실패: ${apiErrorMessage(error)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(communityPostDetailProvider(widget.visitId));
    final asyncComments = ref.watch(communityCommentsProvider(widget.visitId));
    final isCommenting = ref.watch(communityCommentActionsProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('낚시 일지')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: asyncDetail.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(apiErrorMessage(e))),
                data: (post) => ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _PostDetailBody(post: post),
                    const Divider(height: 32),
                    Text('댓글 ${post.commentCount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    asyncComments.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(apiErrorMessage(e)),
                      ),
                      data: (comments) {
                        if (comments.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text('첫 댓글을 남겨보세요.', style: TextStyle(color: Colors.grey)),
                          );
                        }
                        return Column(
                          children: comments
                              .map((c) => _CommentTile(
                                    comment: c,
                                    onEdit: () => _editComment(c),
                                    onDelete: () => _deleteComment(c),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      decoration: const InputDecoration(hintText: '댓글을 입력하세요', border: OutlineInputBorder()),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: isCommenting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                    onPressed: isCommenting ? null : _submitComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostDetailBody extends ConsumerWidget {
  final CommunityPostDetail post;
  const _PostDetailBody({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr =
        '${post.visitDate.year}-${post.visitDate.month.toString().padLeft(2, '0')}-${post.visitDate.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 16, child: Text(post.authorNickname.substring(0, 1))),
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
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ]),
        ],
        if (post.title != null && post.title!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(post.title!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
        if (post.content != null && post.content!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(post.content!),
        ],
        if (post.memo != null && post.memo!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(post.memo!, style: const TextStyle(color: Colors.grey)),
        ],
        if (post.weather != null || post.catches.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (post.weather?.condition != null)
                Chip(label: Text('${weatherIcon(post.weather!.condition)} ${post.weather!.condition}')),
              if (post.weather?.temperature != null)
                Chip(label: Text('${post.weather!.temperature!.toStringAsFixed(1)}°C')),
              for (final c in post.catches) Chip(label: Text('${c.fishName} ${c.count}마리')),
            ],
          ),
        ],
        const SizedBox(height: 16),
        InkWell(
          onTap: () =>
              ref.read(communityDetailLikeActionsProvider.notifier).toggle(post.visitId, post.liked),
          child: Row(
            children: [
              Icon(
                post.liked ? Icons.favorite : Icons.favorite_border,
                color: post.liked ? Colors.red : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text('좋아요 ${post.likeCount}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommunityComment comment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _CommentTile({required this.comment, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final timeStr = '${comment.createdAt.month}/${comment.createdAt.day} '
        '${comment.createdAt.hour.toString().padLeft(2, '0')}:${comment.createdAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 12, child: Text(comment.authorNickname.substring(0, 1), style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.authorNickname, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.content),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
            onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'edit', child: Text('수정')),
              PopupMenuItem(value: 'delete', child: Text('삭제')),
            ],
          ),
        ],
      ),
    );
  }
}
