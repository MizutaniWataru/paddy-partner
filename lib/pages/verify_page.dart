// lib/pages/verify_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';

class VerifyPage extends ConsumerStatefulWidget {
  const VerifyPage({super.key});

  @override
  ConsumerState<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends ConsumerState<VerifyPage> {
  String _workType = '長野・配達サービス・🚲・🚶';

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authControllerProvider).asData?.value;

    final name = [
      s?.familyName,
      s?.givenName,
    ].where((e) => (e ?? '').isNotEmpty).join(' ');

    final idDone = s?.verifyIdDone ?? false;
    final photoDone = s?.verifyPhotoDone ?? false;
    final bankDone = s?.verifyBankDone ?? false;
    final allDone = idDone && photoDone && bankDone;

    // 次にやるべきステップ（おすすめ）
    final rec = _recommended(
      idDone: idDone,
      photoDone: photoDone,
      bankDone: bankDone,
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            // ===== Header =====
            Row(
              children: [
                const Spacer(),
                const Text(
                  '田んぼへGO',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AlertDialog(
                        title: Text('ヘルプ'),
                        content: Text('（ここにFAQなど）'),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F2F2),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('ヘルプ'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const Text(
              '次の稼働タイプの登録：',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _workType,
                    items: const [
                      DropdownMenuItem(
                        value: '長野・配達サービス・🚲・🚶',
                        child: Text('長野・配達サービス・🚲・🚶'),
                      ),
                      DropdownMenuItem(
                        value: '東京・配達サービス・🚲・🚶',
                        child: Text('東京・配達サービス・🚲・🚶'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _workType = v ?? _workType),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: UnderlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              'ようこそ、${name.isEmpty ? '配達員' : name}様',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // 進捗バー（完了ぶんだけ少し濃く）
            Row(
              children: List.generate(3, (i) {
                final done =
                    (i == 0 && idDone) ||
                    (i == 1 && photoDone) ||
                    (i == 2 && bankDone);
                return Expanded(
                  child: Container(
                    height: 8,
                    margin: EdgeInsets.only(right: i == 2 ? 0 : 10),
                    decoration: BoxDecoration(
                      color: done
                          ? const Color(0xFFBDBDBD)
                          : const Color(0xFFE6E6E6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 18),

            // ===== Recommended block (ここをタップで遷移) =====
            if (!allDone) ...[
              InkWell(
                onTap: () => context.go(rec.route),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '推奨される次のステップ',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
            ] else ...[
              // 3つ終えたらhomeへ（まだ未実装でもOK）
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('ホームへ'),
                  ),
                ),
              ),
              const Divider(height: 1),
            ],

            // ===== List items =====
            _StepTile(
              title: '身分証',
              done: idDone,
              onTap: () => context.go('/verify/id'),
            ),
            const Divider(height: 1),

            _StepTile(
              title: 'プロフィール写真',
              done: photoDone,
              onTap: () => context.go('/verify/photo'),
            ),
            const Divider(height: 1),

            _StepTile(
              title: 'キャッシュカード',
              done: bankDone,
              onTap: () => context.go('/verify/bank'),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

class _Recommended {
  final String title;
  final String route;
  const _Recommended(this.title, this.route);
}

_Recommended _recommended({
  required bool idDone,
  required bool photoDone,
  required bool bankDone,
}) {
  if (!idDone) {
    return const _Recommended(
      '身分証 - パスポート、運転免許証、マイナンバーカード（外国籍の方は在留カード+パスポート2点）',
      '/verify/id',
    );
  }
  if (!photoDone) return const _Recommended('プロフィール写真', '/verify/photo');
  if (!bankDone) return const _Recommended('キャッシュカード', '/verify/bank');
  return const _Recommended('完了', '/home');
}

class _StepTile extends StatelessWidget {
  final String title;
  final bool done;
  final VoidCallback onTap;

  const _StepTile({
    required this.title,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: done
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '完了',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                SizedBox(width: 6),
                Icon(Icons.check_circle, size: 18),
              ],
            )
          : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
