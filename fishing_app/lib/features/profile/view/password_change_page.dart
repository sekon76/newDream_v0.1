import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/profile/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordChangePage extends ConsumerStatefulWidget {
  const PasswordChangePage({super.key});

  @override
  ConsumerState<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends ConsumerState<PasswordChangePage> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(profileActionsProvider.notifier).changePassword(
          currentPassword: _currentCtrl.text,
          newPassword: _newCtrl.text,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 변경되었습니다.')),
      );
      Navigator.of(context).pop();
    } else {
      final error = ref.read(profileActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('변경 실패: ${apiErrorMessage(error)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileActionsProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 변경')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _currentCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '현재 비밀번호', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty) ? '현재 비밀번호를 입력하세요.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '새 비밀번호 (8자 이상)', border: OutlineInputBorder()),
                  validator: (v) {
                    if (v == null || v.isEmpty) return '새 비밀번호를 입력하세요.';
                    if (v.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '새 비밀번호 확인', border: OutlineInputBorder()),
                  validator: (v) => (v != _newCtrl.text) ? '새 비밀번호가 일치하지 않습니다.' : null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('변경하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
