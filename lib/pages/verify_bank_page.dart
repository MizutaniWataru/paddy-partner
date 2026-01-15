import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_top_bar.dart';
import '../auth/auth_controller.dart';

class VerifyBankPage extends ConsumerStatefulWidget {
  const VerifyBankPage({super.key});

  @override
  ConsumerState<VerifyBankPage> createState() => _VerifyBankPageState();
}

class _VerifyBankPageState extends ConsumerState<VerifyBankPage> {
  bool _cardDone = false;

  @override
  Widget build(BuildContext context) {
    final canNext = _cardDone;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            AppTopBar(title: '田んぼへGO', onHelp: () => _help(context)),
            const SizedBox(height: 10),

            const Text(
              'キャッシュカード',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            const Text(
              '報酬の受け取りに使う口座を確認するため、キャッシュカードを撮影してください。\n'
              '（いまはモック。後でカメラ撮影・画像アップロードに差し替え）',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            _MockPhotoCard(
              title: 'キャッシュカード（表面）',
              done: _cardDone,
              onTap: () => setState(() => _cardDone = !_cardDone),
              subText: _cardDone ? '撮影済み（モック）' : 'タップして撮影（モック）',
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: canNext
                    ? () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .setVerifyBankDone(true);

                        if (!context.mounted) return;
                        context.go('/verify');
                      }
                    : null,
                child: const Text('次へ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _help(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('ヘルプ'),
        content: Text('（ここに撮影時の注意・読み取れる情報など）'),
      ),
    );
  }
}

class _MockPhotoCard extends StatelessWidget {
  final String title;
  final String subText;
  final bool done;
  final VoidCallback onTap;

  const _MockPhotoCard({
    required this.title,
    required this.subText,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.photo_camera,
              color: done ? Colors.green : Colors.black87,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
