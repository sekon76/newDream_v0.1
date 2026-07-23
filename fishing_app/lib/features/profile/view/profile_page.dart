import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/auth/provider/auth_provider.dart';
import 'package:fishing_app/features/profile/data/profile_model.dart';
import 'package:fishing_app/features/profile/provider/profile_provider.dart';
import 'package:fishing_app/features/profile/view/password_change_page.dart';
import 'package:fishing_app/features/profile/view/preferred_region_create_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _setAsDefault(WidgetRef ref, BuildContext context, PreferredRegion region) async {
    final ok = await ref.read(profileActionsProvider.notifier).updateRegion(
          region.id,
          name: region.name,
          latitude: region.latitude,
          longitude: region.longitude,
          address: region.address,
          isDefault: true,
          species: region.species,
        );
    if (!context.mounted) return;
    if (!ok) {
      final error = ref.read(profileActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기본 지역 설정 실패: ${apiErrorMessage(error)}')),
      );
    }
  }

  Future<void> _deleteRegion(WidgetRef ref, BuildContext context, PreferredRegion region) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('선호 지역 삭제'),
        content: Text('"${region.name}"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await ref.read(profileActionsProvider.notifier).deleteRegion(region.id);
    if (!context.mounted) return;
    if (!ok) {
      final error = ref.read(profileActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${apiErrorMessage(error)}')),
      );
    }
  }

  Future<void> _logout(WidgetRef ref, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('로그아웃')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authNotifierProvider.notifier).logout();
    ref.invalidate(authStateProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(myProfileProvider);
    final asyncRegions = ref.watch(preferredRegionsProvider);
    final defaultRegionId = asyncRegions.valueOrNull?.firstWhere(
      (r) => r.isDefault,
      orElse: () => PreferredRegion(id: -1, name: '', latitude: 0, longitude: 0),
    ).id;

    return Scaffold(
      appBar: AppBar(title: const Text('내 정보')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myProfileProvider);
          ref.invalidate(preferredRegionsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            asyncProfile.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
              error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text(apiErrorMessage(e))),
              data: (profile) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(profile.email, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PasswordChangePage()),
                        ),
                        icon: const Icon(Icons.lock_outline, size: 18),
                        label: const Text('비밀번호 변경'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('선호 지역', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PreferredRegionCreatePage()),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('추가'),
                ),
              ],
            ),
            Text(
              '기본으로 선택한 지역·어종은 조과예측 화면 첫 진입 시 자동으로 검색됩니다.',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            asyncRegions.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
              error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text(apiErrorMessage(e))),
              data: (regions) {
                if (regions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('등록된 선호 지역이 없습니다.')),
                  );
                }
                return Column(
                  children: regions.map((region) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Radio<int>(
                          value: region.id,
                          groupValue: defaultRegionId,
                          onChanged: (_) => _setAsDefault(ref, context, region),
                        ),
                        title: Text(region.name),
                        subtitle: region.species.isNotEmpty
                            ? Text(region.species.map((s) => s.isDefault ? '${s.speciesName} ★' : s.speciesName).join(', '))
                            : (region.address != null ? Text(region.address!) : null),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PreferredRegionCreatePage(existing: region)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _deleteRegion(ref, context, region),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => _logout(ref, context),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('로그아웃'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
