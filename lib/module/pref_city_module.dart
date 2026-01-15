// lib/module/pref_city_module.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class PrefCityMaster {
  final Map<String, List<String>> data;

  PrefCityMaster(this.data);

  List<String> get prefs => data.keys.toList()..sort();

  List<String> citiesOf(String pref) => (data[pref] ?? <String>[]);

  static Future<PrefCityMaster> loadFromAsset(String path) async {
    final raw = await rootBundle.loadString(path);
    final jsonMap = json.decode(raw);

    if (jsonMap is! Map<String, dynamic>) {
      throw const FormatException('pref_city.json は Map 形式である必要があります');
    }

    final out = <String, List<String>>{};
    for (final e in jsonMap.entries) {
      final k = e.key;
      final v = e.value;
      if (v is List) {
        out[k] = v.map((x) => x.toString()).toList();
      } else {
        out[k] = <String>[];
      }
    }
    return PrefCityMaster(out);
  }
}
