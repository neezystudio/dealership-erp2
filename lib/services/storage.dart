import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/all.dart';
import '../utils/state_notifier/service.dart';

class SambazaStorage extends SambazaInjectableService
    with SambazaStateNotifier, SambazaServiceStateNotifier {
  final Map<String, dynamic> _cache = <String, dynamic>{};
  final Map<String, DateTime> _cacheTimes = <String, DateTime>{};
  late SharedPreferences _prefs;
  late Future<void> ready;

  SambazaStorage() {
    ready = SharedPreferences.getInstance().then(_init);
  }

  void _init(SharedPreferences prefs) {
    _prefs = prefs;
    String? persisted = _prefs.getString('SambazaCache');
    String? times = _prefs.getString('SambazaCacheTimes');
    _cacheTimes.addAll(
      json
          .decode(times!)
          .cast<String, int>()
          .map<String, DateTime>(
            (String key, int time) =>
                MapEntry(key, DateTime.fromMillisecondsSinceEpoch(time)),
          ),
    );
    _cache.addAll(json.decode(persisted!).cast<String, dynamic>());
    List<String> toRemove = <String>[];
    _cacheTimes.forEach((String key, DateTime expiry) {
      DateTime now = DateTime.now();
      Duration toExpiry = expiry.difference(now);
      if (toExpiry.isNegative) {
        toRemove.add(key);
      } else {
        Future.delayed(toExpiry, () {
          if (_cacheTimes.containsKey(key) &&
              _cacheTimes[key]!.isAtSameMomentAs(expiry)) {
            remove(key);
          }
        });
      }
    });
    for (var key in toRemove) {
      remove(key);
    }
  }

  void _persist() {
    _prefs.setString(
      'SambazaCacheTimes',
      json.encode(
        _cacheTimes.map<String, int>(
          (String key, DateTime dateTime) =>
              MapEntry(key, dateTime.millisecondsSinceEpoch),
        ),
      ),
    );
    _prefs.setString('SambazaCache', json.encode(_cache));
  }

  Future<void> cache(
    String key,
    dynamic value, [
    Duration duration = const Duration(minutes: 5),
  ]) {
    if (duration.isNegative) {
      return Future.sync(() {
        remove(key);
      });
    }
    DateTime expiry = DateTime.now().add(duration);
    _cacheTimes[key] = expiry;
    $set(key, value, false);
    return Future.delayed(duration, () {
      if (_cacheTimes.containsKey(key) &&
          _cacheTimes[key]!.isAtSameMomentAs(expiry)) {
        remove(key);
      }
    });
  }

  void clear() {
    List<String> toRemove = _cache.keys.toList();
    for (var key in toRemove) {
      remove(key, false);
    }
    notifyState();
  }

  bool has(String key) => _cache.containsKey(key);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    String key = invocation.memberName.toString().replaceAll('=', '');
    if (invocation.isGetter == true) {
      if (has(key)) {
        return $get(key);
      }
    } else if (invocation.isSetter == true) {
      return $set(key, invocation.positionalArguments.first);
    }
    super.noSuchMethod(invocation);
  }

  dynamic $get(String key, [dynamic defaultValue]) =>
      has(key) ? _cache[key] : defaultValue;

  void remove(String key, [notify = true]) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    }
    if (_cacheTimes.containsKey(key)) {
      _cacheTimes.remove(key);
    }
    if (notify) {
      notifyState();
    }
    _persist();
  }

  void $set(String key, dynamic value, [notify = true]) {
    _cache[key] = value;
    if (notify) {
      notifyState();
    }
    _persist();
  }

  void $setAll(Map<String, dynamic> pairs, [notify = true]) {
    _cache.addAll(pairs);
    if (notify) {
      notifyState();
    }
    _persist();
  }
}
