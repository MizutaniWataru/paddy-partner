import 'package:flutter/material.dart';

class AppTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onHelp;

  const AppTopBar({super.key, required this.title, this.onHelp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          if (onHelp != null)
            TextButton(
              onPressed: onHelp,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF2F2F2),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
              ),
              child: const Text('ヘルプ'),
            )
          else
            const SizedBox(width: 72),
        ],
      ),
    );
  }
}
