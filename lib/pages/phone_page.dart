// lib/pages/phone_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';

class PhonePage extends ConsumerStatefulWidget {
  const PhonePage({super.key});

  @override
  ConsumerState<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends ConsumerState<PhonePage> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();

  // 最低限の国リスト（必要なら増やす）
  static const _countries = <({String label, String code})>[
    (label: '日本 (+81)', code: '+81'),
    (label: '米国 (+1)', code: '+1'),
    (label: '韓国 (+82)', code: '+82'),
    (label: '台湾 (+886)', code: '+886'),
  ];

  String _countryCode = '+81';

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authControllerProvider).asData?.value;
    if (s != null) {
      _countryCode = s.countryCode;
      // phoneは毎回上書きしない（入力中に消えるの防止）
      if (_phone.text.isEmpty && (s.phone ?? '').isNotEmpty) {
        _phone.text = s.phone!;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('携帯電話番号')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        initialValue: _countryCode,
                        items: _countries
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.code,
                                child: Text(c.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _countryCode = v ?? '+81'),
                        decoration: const InputDecoration(labelText: '国選択'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: '携帯電話番号',
                          hintText: '例: 09012345678',
                        ),
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return '電話番号を入力して';
                          if (t.length < 10) return '短すぎるかも';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      await ref
                          .read(authControllerProvider.notifier)
                          .setPhone(
                            countryCode: _countryCode,
                            phone: _phone.text.trim(),
                          );

                      if (!context.mounted) return;
                      context.go('/name');
                    },
                    child: const Text('次へ'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
