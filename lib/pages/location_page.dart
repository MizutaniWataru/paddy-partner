// lib/pages/location_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../module/providers.dart';
import '../widgets/app_bottom_bar.dart';

class LocationPage extends ConsumerStatefulWidget {
  const LocationPage({super.key});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  String? _pref;
  String? _city;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider).asData?.value;

    // 初期値をAuthStateから反映
    _pref ??= auth?.pref;
    _city ??= auth?.city;

    final masterAsync = ref.watch(prefCityMasterProvider);
    final canNext =
        (_pref != null && _city != null) && masterAsync is AsyncData;

    return Scaffold(
      appBar: AppBar(title: const Text('収入を得る場所')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: masterAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('マスタ読み込みに失敗しました'),
                const SizedBox(height: 8),
                Text(e.toString(), style: const TextStyle(color: Colors.red)),
              ],
            ),
            data: (master) {
              final prefs = master.prefs;
              final cities = _pref == null
                  ? <String>[]
                  : master.citiesOf(_pref!);

              // 県を変えたら市はリセット
              if (_pref != null && _city != null && !cities.contains(_city)) {
                _city = null;
              }

              return Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _pref,
                    items: prefs
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _pref = v;
                        _city = null;
                      });
                    },
                    decoration: const InputDecoration(labelText: '県'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _city,
                    items: cities
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _city = v),
                    decoration: const InputDecoration(labelText: '市区町村'),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
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
        onNext: canNext
            ? () async {
                await ref
                    .read(authControllerProvider.notifier)
                    .setLocation(pref: _pref!, city: _city!);
                if (!context.mounted) return;
                context.push('/transport');
              }
            : null,
        nextEnabled: canNext,
      ),
    );
  }
}
