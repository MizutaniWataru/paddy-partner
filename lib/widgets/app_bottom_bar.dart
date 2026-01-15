// lib/widgets/app_bottom_bar.dart
import 'package:flutter/material.dart';

class AppBottomBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  /// trueなら「次へ」ボタンを有効化
  final bool nextEnabled;

  /// 「次へ」のラベル
  final String nextText;

  /// 戻るボタンのアイコン
  final IconData backIcon;

  const AppBottomBar({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.nextEnabled,
    this.nextText = '次へ',
    this.backIcon = Icons.arrow_back,
  });

  @override
  Widget build(BuildContext context) {
    final canNext = nextEnabled && onNext != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            // ===== 戻る =====
            SizedBox(
              width: 54,
              height: 54,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side: BorderSide.none,
                  backgroundColor: const Color(0xFFF2F2F2),
                ),
                child: Icon(backIcon),
              ),
            ),

            const Spacer(),

            // ===== 次へ =====
            SizedBox(
              width: 150,
              height: 54,
              child: FilledButton.icon(
                onPressed: canNext ? onNext : null,
                style: FilledButton.styleFrom(
                  backgroundColor: canNext
                      ? Colors.black
                      : const Color(0xFFE0E0E0),
                  shape: const StadiumBorder(),
                ),
                icon: Text(
                  nextText,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                label: Icon(
                  Icons.arrow_forward,
                  color: canNext ? Colors.white : Colors.black26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
