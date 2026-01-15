// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('田んぼへGO')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Home（未実装）',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'ここに配達/作業一覧とか、稼働開始ボタンとかが入る想定。',
                style: TextStyle(color: Colors.black54),
              ),
              const Spacer(),

              // ===== 開発用リセット =====
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('【開発用】登録をリセット'),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('登録リセット'),
                        content: const Text('登録状態を初期化して、最初からやり直します。'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('キャンセル'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('リセット'),
                          ),
                        ],
                      ),
                    );

                    if (ok != true) return;

                    await ref.read(authControllerProvider.notifier).resetAll();

                    if (!context.mounted) return;
                    context.go('/welcome');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
