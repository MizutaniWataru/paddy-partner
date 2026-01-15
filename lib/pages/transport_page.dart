// lib/pages/transport_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';

class TransportPage extends ConsumerStatefulWidget {
  const TransportPage({super.key});

  @override
  ConsumerState<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends ConsumerState<TransportPage> {
  TransportType? _selected;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authControllerProvider).asData?.value;
    _selected ??= s?.transport;

    return Scaffold(
      appBar: AppBar(title: const Text('移動方法')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              RadioListTile<TransportType>(
                value: TransportType.walkBike,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v),
                title: const Text('徒歩・自転車'),
              ),
              const SizedBox(height: 8),
              RadioListTile<TransportType>(
                value: TransportType.vehicle,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v),
                title: const Text('車両'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _selected == null
                      ? null
                      : () async {
                          final ctrl = ref.read(
                            authControllerProvider.notifier,
                          );
                          await ctrl.setTransport(_selected!);
                          await ctrl.completeRegistration();
                          if (!context.mounted) return;
                          context.go('/verify');
                        },
                  child: const Text('次へ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
