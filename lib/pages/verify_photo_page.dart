import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_top_bar.dart';
import '../auth/auth_controller.dart';

class VerifyPhotoPage extends ConsumerStatefulWidget {
  const VerifyPhotoPage({super.key});

  @override
  ConsumerState<VerifyPhotoPage> createState() => _VerifyPhotoPageState();
}

class _VerifyPhotoPageState extends ConsumerState<VerifyPhotoPage> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            AppTopBar(title: '田んぼへGO', onHelp: () => _help(context)),
            const SizedBox(height: 10),
            const Text(
              'プロフィール写真',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              '顔がはっきり分かる写真を登録してください。\n（いまはモック。後でカメラ/アルバム選択に差し替え）',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),

            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF2F2F2),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Icon(_selected ? Icons.check : Icons.person, size: 54),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => setState(() => _selected = !_selected),
                child: Text(_selected ? '写真を変更（モック）' : '写真を選ぶ（モック）'),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _selected
                    ? () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .setVerifyPhotoDone(true);
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
      builder: (_) =>
          const AlertDialog(title: Text('ヘルプ'), content: Text('（ここに写真ルール）')),
    );
  }
}
