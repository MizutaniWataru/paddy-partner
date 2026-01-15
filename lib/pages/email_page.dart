// lib/pages/email_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';

class EmailPage extends ConsumerStatefulWidget {
  const EmailPage({super.key});

  @override
  ConsumerState<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends ConsumerState<EmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authControllerProvider).asData?.value;
    if (_email.text.isEmpty && (s?.email ?? '').isNotEmpty) {
      _email.text = s!.email!;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('メールアドレス')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                    hintText: '例: example@example.com',
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'メールアドレスを入力してください';
                    if (!t.contains('@')) return '形式が違います';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final ctrl = ref.read(authControllerProvider.notifier);
                      await ctrl.setEmail(_email.text.trim());
                      await ctrl.sendEmailOtp();

                      if (!context.mounted) return;
                      context.go('/email-otp');
                    },
                    child: const Text('認証コードを送信'),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '※開発中はワンタイムパスワードがデバッグログに出ます',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
