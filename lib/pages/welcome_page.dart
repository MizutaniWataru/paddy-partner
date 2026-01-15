// lib/pages/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authControllerProvider).asData?.value;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          children: [
            const SizedBox(height: 8),

            // 上の余白（iPhoneステータスバー風）
            const SizedBox(height: 10),

            // ===== Uberっぽいロゴ（仮） =====
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    '田',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              '田んぼへGO の利用を開始する',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 22),

            const Text(
              '携帯電話番号またはメールアドレス',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),

            Form(
              key: _formKey,
              child: TextFormField(
                controller: _input,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: '電話番号またはメールアドレスを入力',
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.person_outline),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return '入力して';
                  // 今はメールだけ想定なのでゆるくチェック
                  if (!t.contains('@')) return 'メールアドレスを入力して';
                  return null;
                },
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final email = _input.text.trim();

                  final ctrl = ref.read(authControllerProvider.notifier);

                  await ctrl.setEmail(email);
                  await ctrl.sendEmailOtp();

                  if (!context.mounted) return;
                  context.go('/email_otp');
                },

                child: const Text(
                  '続行',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('または', style: TextStyle(color: Colors.black54)),
                ),
                Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 16),

            // ===== アカウント探す（仮） =====
            TextButton.icon(
              onPressed: () {
                // TODO: 将来の導線
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text('自分のアカウントを探す'),
                    content: Text('（後で実装）'),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('自分のアカウントを探す'),
            ),

            const SizedBox(height: 18),

            const Text(
              '続行すると、田んぼへGO からの通知メールを受け取ることに同意したものとみなされます。',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 18),

            // ===== 開発用：現在email表示（消してOK） =====
            if ((s?.email ?? '').isNotEmpty)
              Text(
                '（dev）現在のメール: ${s!.email}',
                style: const TextStyle(fontSize: 12, color: Colors.black38),
              ),
          ],
        ),
      ),
    );
  }
}
