// lib/pages/phone_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../widgets/app_bottom_bar.dart';

class PhonePage extends ConsumerStatefulWidget {
  const PhonePage({super.key});

  @override
  ConsumerState<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends ConsumerState<PhonePage> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();

  static const _countries = <({String label, String code})>[
    (label: '日本 (+81)', code: '+81'),
    (label: '米国 (+1)', code: '+1'),
    (label: '韓国 (+82)', code: '+82'),
    (label: '台湾 (+886)', code: '+886'),
  ];

  String _countryCode = '+81';

  bool get _canNext {
    final t = _phone.text.trim();
    final digits = t.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isNotEmpty && digits.length >= 10;
  }

  @override
  void initState() {
    super.initState();
    _phone.addListener(() {
      if (mounted) setState(() {});
    });
  }

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
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9\- ]'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: '携帯電話番号',
                          hintText: '例: 09012345678',
                        ),
                        validator: (v) {
                          final digits = (v ?? '').trim().replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          if (digits.isEmpty) return '電話番号を入力して';
                          if (digits.length < 10) return '短すぎます';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
        onNext: _canNext
            ? () async {
                if (!_formKey.currentState!.validate()) return;

                await ref
                    .read(authControllerProvider.notifier)
                    .setPhone(
                      countryCode: _countryCode,
                      phone: _phone.text.trim(),
                    );

                if (!context.mounted) return;
                context.push('/name');
              }
            : null,
        nextEnabled: _canNext,
      ),
    );
  }
}
