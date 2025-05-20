import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';

import 'services/all.dart';
import 'utils/all.dart';

class SambazaState extends Model {
  static const String AUTH_JWT_STORAGE_KEY = 'SAMBAZA_JWT';
  static const String AUTH_TOKEN_STORAGE_KEY = 'SAMBAZA_TOKEN';
  static const String FCM_TOKEN_STORAGE_KEY = 'FCMRegistrationToken';
  static List<String> months = <String>[
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static List<String> weekdays = <String>[
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final SambazaServiceProvider $provider = SambazaServiceProvider();

  SambazaState() {
    for (var serviceFactory in SambazaServices.factories) {
      serviceFactory().register(this);
    }
  }

  static SambazaState of(BuildContext context) =>
      ScopedModel.of<SambazaState>(context);

  void appStateChanged() => notifyListeners();

  Future<SambazaState> ready() =>
      $provide<SambazaStorage>().ready.then((x) => this);

  T $provide<T extends SambazaService>() => $provider(T);
}
