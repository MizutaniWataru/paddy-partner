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
  final _formKey = GlobalKey<FormState>();
  final _bank = TextEditingController();
  final _branch = TextEditingController();
  final _account = TextEditingController();
  final _name = TextEditingController();

  @override
  void dispose() {
    _bank.dispose();
    _branch.dispose();
    _account.dispose();
    _name.dispose();
    super.dispose();
  }

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
              'キャッシュカード',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              '報酬の受け取りに使う口座情報を入力してください。',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _bank,
                    decoration: const InputDecoration(labelText: '銀行名'),
                    validator: (v) => (v ?? '').trim().isEmpty ? '入力して' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _branch,
                    decoration: const InputDecoration(labelText: '支店名'),
                    validator: (v) => (v ?? '').trim().isEmpty ? '入力して' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _account,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '口座番号'),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return '入力して';
                      if (t.length < 6) return '短すぎるかも';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: '口座名義'),
                    validator: (v) => (v ?? '').trim().isEmpty ? '入力して' : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await ref
                        .read(authControllerProvider.notifier)
                        .setVerifyBankDone(true);
                    if (!context.mounted) return;
                    context.go('/verify');
                  }
                },
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
          const AlertDialog(title: Text('ヘルプ'), content: Text('（ここに口座入力の注意）')),
    );
  }
}
