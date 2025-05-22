import 'dart:convert';

import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SambazaModel extends Model {
  final Map<String, dynamic> _cache = <String, dynamic>{};
  late SharedPreferences _prefs; // ✅ FIXED HERE
  late Future<void> _ready;

  SambazaModel() {
    _ready = SharedPreferences.getInstance().then(_init);
  }

  void _init(SharedPreferences prefs) {
    _prefs = prefs;
    String? persisted = _prefs.getString('SambazaCache');
    _cache.addAll(json.decode(persisted));
    }

  void _persist() => _prefs.setString('SambazaCache', json.encode(_cache));

  void cache(String key, dynamic value, [duration = const Duration(minutes: 5)]) {
    save(key, value, false);
    Future.delayed(
      duration,
      () {
        remove(key);
      },
    );
  }

  bool has(String key) => _cache.containsKey(key);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      var ret = _cache[invocation.memberName.toString()];
      if (ret != null) {
        return ret;
      } else {
        super.noSuchMethod(invocation);
      }
    }
    if (invocation.isSetter) {
      save(invocation.memberName.toString().replaceAll('=', ''), invocation.positionalArguments.first);
    } else {
      super.noSuchMethod(invocation);
    }
  }

  void remove(String key) {
    _cache.remove(key);
    notifyListeners();
    _persist();
  }

  void save(String key, dynamic value, [notify = true]) {
    _cache[key] = value;
    if (notify == true) {
      notifyListeners();
    }
    _persist();
  }

  void saveAll(Map<String, dynamic> pairs, [notify = true]) {
    _cache.addAll(pairs);
    if (notify == true) {
      notifyListeners();
    }
    _persist();
  }

  Future<void> whenReady() => _ready;
}
