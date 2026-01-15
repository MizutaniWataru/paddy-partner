// lib/pages/consent_page.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../widgets/app_bottom_bar.dart';

class ConsentPage extends ConsumerStatefulWidget {
  const ConsentPage({super.key});

  @override
  ConsumerState<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends ConsumerState<ConsentPage> {
  bool _checked = false;
  bool _inited = false;

  void _showDoc(BuildContext context, {required String title}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: const SingleChildScrollView(
          child: Text(
            '（ここに内容を入れる）\n\n'
            'いまはモック。後でWebページやAPIに差し替え。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authControllerProvider).asData?.value;

    // 初回だけ、保存済み状態を反映（buildのたびに上書きしない！）
    if (!_inited) {
      _checked = s?.consented ?? false;
      _inited = true;
    }

    final linkStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    );

    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.black54, height: 1.4);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // 画像寄せ：中央タイトル（改行）
              const Text(
                '利用規約に同意し、プライバ\nシー通知を確認する',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // 画像寄せ：本文 + 押せそうなリンク
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: bodyStyle,
                    children: [
                      const TextSpan(text: '以下の「同意する」を選択する事により、'),
                      TextSpan(
                        text: '利用規約',
                        style: linkStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showDoc(context, title: '利用規約'),
                      ),
                      const TextSpan(text: 'を確認して同意した事と、'),
                      TextSpan(
                        text: 'プライバシー通知',
                        style: linkStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showDoc(context, title: 'プライバシー通知'),
                      ),
                      const TextSpan(text: 'に合意したことを表明します。私は18歳以上です。'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 画像寄せ：チェック行（ラベルもタップ可能）
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _checked = !_checked),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _checked,
                        onChanged: (v) => setState(() => _checked = v ?? false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 6),
                      const Text('同意する', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomBar(
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/welcome');
          }
        },
        onNext: _checked
            ? () async {
                await ref
                    .read(authControllerProvider.notifier)
                    .setConsented(true);
                if (!context.mounted) return;
                context.push('/location');
              }
            : null,
        nextEnabled: _checked,
      ),
    );
  }
}
