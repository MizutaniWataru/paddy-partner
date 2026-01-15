import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../widgets/app_top_bar.dart';

class VerifyIdPage extends ConsumerStatefulWidget {
  const VerifyIdPage({super.key});

  @override
  ConsumerState<VerifyIdPage> createState() => _VerifyIdPageState();
}

class _VerifyIdPageState extends ConsumerState<VerifyIdPage> {
  bool _frontDone = false;
  bool _backDone = false;

  @override
  Widget build(BuildContext context) {
    final canNext = _frontDone && _backDone;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            AppTopBar(title: '田んぼへGO', onHelp: () => _help(context)),
            const SizedBox(height: 10),
            const Text(
              '身分証の提出',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              '運転免許証 / マイナンバーカード / パスポート などを提出してください。\n'
              '（いまはモック。後でカメラ撮影やアップロードに差し替え）',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            _MockUploadCard(
              title: '表面',
              done: _frontDone,
              onTap: () => setState(() => _frontDone = !_frontDone),
            ),
            const SizedBox(height: 12),
            _MockUploadCard(
              title: '裏面',
              done: _backDone,
              onTap: () => setState(() => _backDone = !_backDone),
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
                            .setVerifyIdDone(true);
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
        content: Text('（ここに提出ルールやFAQ）'),
      ),
    );
  }
}

class _MockUploadCard extends StatelessWidget {
  final String title;
  final bool done;
  final VoidCallback onTap;

  const _MockUploadCard({
    required this.title,
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
            Icon(done ? Icons.check_circle : Icons.upload_file),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                done ? '$title：提出済み（モック）' : '$title：タップで提出（モック）',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
