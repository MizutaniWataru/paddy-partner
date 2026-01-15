// lib/pages/phone_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../widgets/app_bottom_bar.dart';

class NamePage extends ConsumerStatefulWidget {
  const NamePage({super.key});

  @override
  ConsumerState<NamePage> createState() => _NamePageState();
}

class _NamePageState extends ConsumerState<NamePage> {
  final _formKey = GlobalKey<FormState>();
  final _family = TextEditingController();
  final _given = TextEditingController();

  bool get _canNext =>
      _family.text.trim().isNotEmpty && _given.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _family.addListener(() {
      if (mounted) setState(() {});
    });
    _given.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _family.dispose();
    _given.dispose();
    super.dispose();
  }

  Future<void> _onNext(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authControllerProvider.notifier)
        .setName(
          familyName: _family.text.trim(),
          givenName: _given.text.trim(),
        );

    if (!context.mounted) return;
    context.push('/consent');
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authControllerProvider).asData?.value;

    if (_family.text.isEmpty && (s?.familyName ?? '').isNotEmpty) {
      _family.text = s!.familyName!;
    }
    if (_given.text.isEmpty && (s?.givenName ?? '').isNotEmpty) {
      _given.text = s!.givenName!;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('お名前')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('お名前を入力してください'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _family,
                  decoration: const InputDecoration(labelText: '姓'),
                  validator: (v) => (v ?? '').trim().isEmpty ? '姓を入力して' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _given,
                  decoration: const InputDecoration(labelText: '名'),
                  validator: (v) => (v ?? '').trim().isEmpty ? '名を入力して' : null,
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
        onNext: _canNext ? () => _onNext(context) : null,
        nextEnabled: _canNext,
      ),
    );
  }
}
