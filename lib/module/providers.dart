// lib/module/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pref_city_module.dart';

final prefCityMasterProvider = FutureProvider<PrefCityMaster>((ref) async {
  return PrefCityMaster.loadFromAsset('assets/pref_city.json');
});
