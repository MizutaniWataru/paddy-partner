// lib/auth/auth_state.dart
enum TransportType { walkBike, vehicle }

class AuthState {
  final String? email;
  final bool emailOtpSent;
  final String? emailOtpCode; // 開発用（本番はサーバ側）
  final bool emailVerified;

  final String countryCode; // 例: +81
  final String? phone;

  final String? familyName;
  final String? givenName;

  final bool consented;

  final String? pref;
  final String? city;

  final TransportType? transport;

  final bool isRegistered;

  final bool verifyIdDone;
  final bool verifyPhotoDone;
  final bool verifyBankDone;

  const AuthState({
    this.email,
    this.emailOtpSent = false,
    this.emailOtpCode,
    this.emailVerified = false,
    this.countryCode = '+81',
    this.phone,
    this.familyName,
    this.givenName,
    this.consented = false,
    this.pref,
    this.city,
    this.transport,
    this.isRegistered = false,
    this.verifyIdDone = false,
    this.verifyPhotoDone = false,
    this.verifyBankDone = false,
  });

  AuthState copyWith({
    String? email,
    bool? emailOtpSent,
    String? emailOtpCode,
    bool? emailVerified,
    String? countryCode,
    String? phone,
    String? familyName,
    String? givenName,
    bool? consented,
    String? pref,
    String? city,
    TransportType? transport,
    bool? isRegistered,
    bool clearEmailOtpCode = false,
    bool? verifyIdDone,
    bool? verifyPhotoDone,
    bool? verifyBankDone,
  }) {
    return AuthState(
      email: email ?? this.email,
      emailOtpSent: emailOtpSent ?? this.emailOtpSent,
      emailOtpCode: clearEmailOtpCode
          ? null
          : (emailOtpCode ?? this.emailOtpCode),
      emailVerified: emailVerified ?? this.emailVerified,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      familyName: familyName ?? this.familyName,
      givenName: givenName ?? this.givenName,
      consented: consented ?? this.consented,
      pref: pref ?? this.pref,
      city: city ?? this.city,
      transport: transport ?? this.transport,
      isRegistered: isRegistered ?? this.isRegistered,
      verifyIdDone: verifyIdDone ?? this.verifyIdDone,
      verifyPhotoDone: verifyPhotoDone ?? this.verifyPhotoDone,
      verifyBankDone: verifyBankDone ?? this.verifyBankDone,
    );
  }

  bool get allVerifyDone => verifyIdDone && verifyPhotoDone && verifyBankDone;
}
