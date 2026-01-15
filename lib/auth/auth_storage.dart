// lib/auth/auth_storage.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_state.dart';

class AuthStorage {
  static const _kRegistered = 'registered';
  static const _kEmail = 'email';
  static const _kCountry = 'countryCode';
  static const _kPhone = 'phone';
  static const _kFamily = 'familyName';
  static const _kGiven = 'givenName';
  static const _kConsented = 'consented';
  static const _kPref = 'pref';
  static const _kCity = 'city';
  static const _kTransport = 'transport';
  static const _kVerifyIdDone = 'verifyIdDone';
  static const _kVerifyPhotoDone = 'verifyPhotoDone';
  static const _kVerifyBankDone = 'verifyBankDone';

  Future<AuthState> load() async {
    final sp = await SharedPreferences.getInstance();
    final registered = sp.getBool(_kRegistered) ?? false;

    final transportStr = sp.getString(_kTransport);
    TransportType? transport;
    if (transportStr == 'walkBike') transport = TransportType.walkBike;
    if (transportStr == 'vehicle') transport = TransportType.vehicle;

    return AuthState(
      isRegistered: registered,
      email: sp.getString(_kEmail),
      countryCode: sp.getString(_kCountry) ?? '+81',
      phone: sp.getString(_kPhone),
      familyName: sp.getString(_kFamily),
      givenName: sp.getString(_kGiven),
      consented: sp.getBool(_kConsented) ?? false,
      pref: sp.getString(_kPref),
      city: sp.getString(_kCity),
      transport: transport,
      verifyIdDone: sp.getBool(_kVerifyIdDone) ?? false,
      verifyPhotoDone: sp.getBool(_kVerifyPhotoDone) ?? false,
      verifyBankDone: sp.getBool(_kVerifyBankDone) ?? false,
    );
  }

  Future<void> saveRegistered(AuthState s) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kRegistered, s.isRegistered);

    if (s.email != null) await sp.setString(_kEmail, s.email!);
    await sp.setString(_kCountry, s.countryCode);
    if (s.phone != null) await sp.setString(_kPhone, s.phone!);

    if (s.familyName != null) await sp.setString(_kFamily, s.familyName!);
    if (s.givenName != null) await sp.setString(_kGiven, s.givenName!);

    await sp.setBool(_kConsented, s.consented);

    if (s.pref != null) await sp.setString(_kPref, s.pref!);
    if (s.city != null) await sp.setString(_kCity, s.city!);

    if (s.transport != null) {
      await sp.setString(
        _kTransport,
        s.transport == TransportType.walkBike ? 'walkBike' : 'vehicle',
      );
    }
    await sp.setBool(_kVerifyIdDone, s.verifyIdDone);
    await sp.setBool(_kVerifyPhotoDone, s.verifyPhotoDone);
    await sp.setBool(_kVerifyBankDone, s.verifyBankDone);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kRegistered);
    await sp.remove(_kEmail);
    await sp.remove(_kCountry);
    await sp.remove(_kPhone);
    await sp.remove(_kFamily);
    await sp.remove(_kGiven);
    await sp.remove(_kConsented);
    await sp.remove(_kPref);
    await sp.remove(_kCity);
    await sp.remove(_kTransport);
    await sp.remove(_kVerifyIdDone);
    await sp.remove(_kVerifyPhotoDone);
    await sp.remove(_kVerifyBankDone);
  }
}
