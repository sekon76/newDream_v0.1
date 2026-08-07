import 'package:fishing_app/core/api/api_exception.dart';
import 'package:fishing_app/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FindPasswordPage extends ConsumerStatefulWidget {
  const FindPasswordPage({super.key});

  @override
  ConsumerState<FindPasswordPage> createState() => _FindPasswordPageState();
}

class _FindPasswordPageState extends ConsumerState<FindPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).resetPassword(
          _emailCtrl.text.trim(),
          _newCtrl.text,
        );
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state is AsyncError) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('비밀번호 재설정 실패'),
          content: Text(apiErrorMessage(state.error)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인')),
          ],
        ),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('비밀번호 재설정 완료'),
          content: const Text('새 비밀번호로 로그인해주세요.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인')),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 찾기')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '가입 시 사용한 이메일과 새로 설정할 비밀번호를 입력하세요.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? '올바른 이메일을 입력하세요.' : null,
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
                      : const Text('비밀번호 재설정'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
