// lib/auth/auth_controller.dart
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'auth_state.dart';
import 'auth_storage.dart';

final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthState> {
  late final AuthStorage _storage;

  @override
  Future<AuthState> build() async {
    _storage = ref.read(authStorageProvider);
    return _storage.load();
  }

  // --- Email ---
  Future<void> setEmail(String email) async {
    final s = state.value ?? const AuthState();
    // emailを変えたら以降の認証はリセット
    state = AsyncData(
      s.copyWith(
        email: email,
        emailOtpSent: false,
        emailVerified: false,
        clearEmailOtpCode: true,
      ),
    );
  }

  Future<void> sendEmailOtp() async {
    final s = state.value ?? const AuthState();
    if ((s.email ?? '').isEmpty) return;

    final code = _genOtp();

    if (kDebugMode) {
      debugPrint('[DEV EMAIL OTP] $code  -> ${s.email}');
    }

    state = AsyncData(
      s.copyWith(emailOtpSent: true, emailOtpCode: code, emailVerified: false),
    );
  }

  Future<void> resendEmailOtp() async {
    await Future.delayed(const Duration(milliseconds: 400));
    await sendEmailOtp();
  }

  Future<bool> verifyEmailOtp(String input) async {
    final s = state.value ?? const AuthState();
    final ok = (s.emailOtpCode != null && s.emailOtpCode == input);

    state = AsyncData(
      s.copyWith(
        emailVerified: ok,
        // 本番っぽくするなら、成功したらコード破棄
        clearEmailOtpCode: ok,
      ),
    );
    return ok;
  }

  // --- Phone ---
  Future<void> setPhone({
    required String countryCode,
    required String phone,
  }) async {
    final s = state.value ?? const AuthState();
    state = AsyncData(s.copyWith(countryCode: countryCode, phone: phone));
  }

  // --- Name ---
  Future<void> setName({
    required String familyName,
    required String givenName,
  }) async {
    final s = state.value ?? const AuthState();
    state = AsyncData(s.copyWith(familyName: familyName, givenName: givenName));
  }

  // --- Consent ---
  Future<void> setConsented(bool value) async {
    final s = state.value ?? const AuthState();
    state = AsyncData(s.copyWith(consented: value));
  }

  // --- Location ---
  Future<void> setLocation({required String pref, required String city}) async {
    final s = state.value ?? const AuthState();
    state = AsyncData(s.copyWith(pref: pref, city: city));
  }

  // --- Transport & Finish ---
  Future<void> setTransport(TransportType t) async {
    final s = state.value ?? const AuthState();
    state = AsyncData(s.copyWith(transport: t));
  }

  Future<void> completeRegistration() async {
    final s = state.value ?? const AuthState();
    final done = s.copyWith(isRegistered: true);
    state = AsyncData(done);
    await _storage.saveRegistered(done);
  }

  Future<void> resetAll() async {
    await _storage.clear();
    state = const AsyncData(AuthState());
  }

  Future<void> setVerifyIdDone(bool v) async {
    final s = state.value ?? const AuthState();
    final next = s.copyWith(verifyIdDone: v);
    state = AsyncData(next);
    await _storage.saveRegistered(next);
  }

  Future<void> setVerifyPhotoDone(bool v) async {
    final s = state.value ?? const AuthState();
    final next = s.copyWith(verifyPhotoDone: v);
    state = AsyncData(next);
    await _storage.saveRegistered(next);
  }

  Future<void> setVerifyBankDone(bool v) async {
    final s = state.value ?? const AuthState();
    final next = s.copyWith(verifyBankDone: v);
    state = AsyncData(next);
    await _storage.saveRegistered(next);
  }

  String _genOtp() {
    final rnd = Random.secure();
    final n = rnd.nextInt(900000) + 100000;
    return n.toString();
  }
}
