// lib/pages/email_otp_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import '../auth/auth_controller.dart';

class EmailOtpPage extends ConsumerStatefulWidget {
  const EmailOtpPage({super.key});

  @override
  ConsumerState<EmailOtpPage> createState() => _EmailOtpPageState();
}

class _EmailOtpPageState extends ConsumerState<EmailOtpPage> {
  static const int _len = 6;

  final _controllers = List.generate(_len, (_) => TextEditingController());
  final _focusNodes = List.generate(_len, (_) => FocusNode());

  String? _error;
  bool _resending = false;

  String get _code => _controllers.map((c) => c.text.trim()).join();

  bool get _canNext =>
      _code.length == _len && !_code.contains(RegExp(r'[^0-9]'));

  @override
  void initState() {
    super.initState();

    for (final f in _focusNodes) {
      f.addListener(() {
        if (mounted) setState(() {});
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _setAllFromPaste(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;

    for (var i = 0; i < _len; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }

    final nextIndex = digits.length >= _len ? _len - 1 : digits.length;
    _focusNodes[nextIndex].requestFocus();
    setState(() => _error = null);
  }

  Future<void> _onNext(BuildContext context) async {
    setState(() => _error = null);

    final code = _code;
    if (code.length != _len) {
      setState(() => _error = '${_len}桁で入力して');
      return;
    }

    final ok = await ref
        .read(authControllerProvider.notifier)
        .verifyEmailOtp(code);

    if (!context.mounted) return;

    if (!ok) {
      setState(() => _error = 'コードが違います');
      return;
    }

    context.go('/phone');
  }

  Future<void> _onResend(BuildContext context) async {
    if (_resending) return;
    setState(() {
      _resending = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).resendEmailOtp();

      if (!context.mounted) return;

      for (final c in _controllers) {
        c.clear();
      }
      FocusScope.of(context).unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusNodes[0].requestFocus();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('認証コードを再送信しました')));
    } catch (_) {
      if (!context.mounted) return;
      setState(() => _error = '再送信に失敗しました');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authControllerProvider).asData?.value;
    final email = s?.email ?? '-';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),

              Text(
                '次の宛先に送信された ${_len}桁のコードを入力してください：',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                email,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 34),

              // ===== OTP ボックス =====
              LayoutBuilder(
                builder: (context, constraints) {
                  final gap = constraints.maxWidth < 360 ? 8.0 : 12.0;

                  double boxSize =
                      (constraints.maxWidth - gap * (_len - 1)) / _len;

                  boxSize = boxSize.clamp(28.0, 58.0);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_len, (i) {
                      final isActive = _focusNodes[i].hasFocus;

                      return Padding(
                        padding: EdgeInsets.only(
                          right: i == _len - 1 ? 0 : gap,
                        ),
                        child: SizedBox(
                          width: boxSize,
                          height: boxSize,
                          child: TextField(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                            autofillHints: const [AutofillHints.oneTimeCode],
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF3F3F3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isActive
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() => _error = null);

                              if (value.length > 1) {
                                _setAllFromPaste(value);
                                return;
                              }

                              if (value.isNotEmpty) {
                                if (i < _len - 1) {
                                  _focusNodes[i + 1].requestFocus();
                                } else {
                                  _focusNodes[i].unfocus();
                                }
                                setState(() {});
                                return;
                              }

                              if (value.isEmpty && i > 0) {
                                _focusNodes[i - 1].requestFocus();
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),

              const SizedBox(height: 10),

              const Text(
                'ヒント：受信トレイと迷惑メールのフォルダを確認してください',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),

              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],

              const SizedBox(height: 18),

              // ===== 再送信 =====
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _resending ? null : () => _onResend(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F2F2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(_resending ? '送信中...' : '再送信'),
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    final code = ref
                        .read(authControllerProvider)
                        .asData
                        ?.value
                        .emailOtpCode;
                    if (code == null || code.isEmpty) {
                      setState(() => _error = 'OTPがまだ発行されてない');
                      return;
                    }
                    _setAllFromPaste(code);
                  },
                  child: const Text('DEV: OTPを自動入力'),
                ),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              // 戻る
              SizedBox(
                width: 54,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => context.go('/welcome'),
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: BorderSide.none,
                    backgroundColor: const Color(0xFFF2F2F2),
                  ),
                  child: const Icon(Icons.arrow_back),
                ),
              ),
              const Spacer(),

              // 次へ
              SizedBox(
                width: 150,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _canNext ? () => _onNext(context) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _canNext
                        ? Colors.black
                        : const Color(0xFFE0E0E0),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Text(
                    '次へ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  label: Icon(
                    Icons.arrow_forward,
                    color: _canNext ? Colors.white : Colors.black26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
