// lib/router.dart
// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_controller.dart';

// pages
import 'pages/welcome_page.dart';
import 'pages/email_page.dart';
import 'pages/email_otp_page.dart';
import 'pages/phone_page.dart';
import 'pages/name_page.dart';
import 'pages/consent_page.dart';
import 'pages/location_page.dart';
import 'pages/transport_page.dart';
import 'pages/done_page.dart';
import 'pages/verify_page.dart';
import 'pages/verify_id_page.dart';
import 'pages/verify_photo_page.dart';
import 'pages/verify_bank_page.dart';
import 'pages/home_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final authAsync = ref.read(authControllerProvider);
      final s = authAsync.asData?.value;

      // まだ初期化中なら何もしない（スプラッシュを作るならそこへ飛ばしてもOK）
      if (s == null) return null;

      if (s.isRegistered) {
        final path = state.uri.path;

        if (s.allVerifyDone) {
          if (path != '/home') return '/home';
          return null;
        }

        if (!path.startsWith('/verify')) return '/verify';
        return null;
      }

      // ここから「順番強制」
      final path = state.uri.path;

      // welcome はいつでもOK
      if (path == '/welcome') return null;

      // email未入力なら email へ
      if ((s.email ?? '').isEmpty) {
        return path == '/email' ? null : '/email';
      }

      // email認証前なら email-otp へ
      if (!s.emailVerified) {
        return path == '/email-otp' ? null : '/email-otp';
      }

      // phone 未入力なら phone へ
      if ((s.phone ?? '').isEmpty) {
        return path == '/phone' ? null : '/phone';
      }

      // 名前未入力なら name へ
      if ((s.familyName ?? '').isEmpty || (s.givenName ?? '').isEmpty) {
        return path == '/name' ? null : '/name';
      }

      // 同意してなければ consent へ
      if (!s.consented) {
        return path == '/consent' ? null : '/consent';
      }

      // 県/市が未入力なら location へ
      if ((s.pref ?? '').isEmpty || (s.city ?? '').isEmpty) {
        return path == '/location' ? null : '/location';
      }

      // 移動方法未選択なら transport へ
      if (s.transport == null) {
        return path == '/transport' ? null : '/transport';
      }

      // ここまで揃ったら doneへ誘導（登録保存は transport の次でやる想定）
      if (path != '/done') return '/done';

      return null;
    },
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomePage()),
      GoRoute(path: '/email', builder: (_, _) => const EmailPage()),
      GoRoute(path: '/email-otp', builder: (_, _) => const EmailOtpPage()),
      GoRoute(path: '/phone', builder: (_, _) => const PhonePage()),
      GoRoute(path: '/name', builder: (_, _) => const NamePage()),
      GoRoute(path: '/consent', builder: (_, _) => const ConsentPage()),
      GoRoute(path: '/location', builder: (_, _) => const LocationPage()),
      GoRoute(path: '/transport', builder: (_, _) => const TransportPage()),
      GoRoute(path: '/done', builder: (_, _) => const DonePage()),
      GoRoute(path: '/verify', builder: (_, _) => const VerifyPage()),
      GoRoute(path: '/verify/id', builder: (_, _) => const VerifyIdPage()),
      GoRoute(
        path: '/verify/photo',
        builder: (_, __) => const VerifyPhotoPage(),
      ),
      GoRoute(path: '/verify/bank', builder: (_, _) => const VerifyBankPage()),
      GoRoute(path: '/home', builder: (_, _) => const HomePage()),
    ],
  );

  // 認証状態が変わったらリダイレクト再評価
  ref.listen(authControllerProvider, (_, __) => router.refresh());
  return router;
});
