// lib/router.dart
// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_controller.dart';
import 'auth/auth_state.dart';

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

      if (s == null) return null;

      final path = state.uri.path;

      // ===== 登録済み =====
      if (s.isRegistered) {
        if (s.allVerifyDone) {
          if (path != '/home') return '/home';
          return null;
        }

        if (!path.startsWith('/verify')) return '/verify';
        return null;
      }

      // ===== 未登録 =====
      // welcomeはいつでもOK
      if (path == '/welcome') return null;

      // 途中で verify/home に入ろうとしたらブロック
      if (path.startsWith('/verify') || path == '/home') {
        // ↓ gate に戻す
        return _gatePath(s);
      }

      // 「次に進むべき場所（未完了の最初）」＝ gate
      final gate = _gatePath(s);

      // gateより "先" に行こうとしたら止める（=スキップ禁止）
      // gateより "前" はOK（戻れる）
      final flowIndex = <String, int>{
        '/welcome': 0,
        '/email': 1,
        '/email-otp': 2,
        '/phone': 3,
        '/name': 4,
        '/consent': 5,
        '/location': 6,
        '/transport': 7,
        '/done': 8,
      };

      int idx(String p) => flowIndex[p] ?? 999;

      if (idx(path) > idx(gate)) return gate;

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

String _gatePath(AuthState s) {
  if ((s.email ?? '').isEmpty) return '/email';
  if (!s.emailVerified) return '/email-otp';
  if ((s.phone ?? '').isEmpty) return '/phone';
  if ((s.familyName ?? '').isEmpty || (s.givenName ?? '').isEmpty) {
    return '/name';
  }
  if (!s.consented) return '/consent';
  if ((s.pref ?? '').isEmpty || (s.city ?? '').isEmpty) return '/location';
  if (s.transport == null) return '/transport';
  return '/done';
}
