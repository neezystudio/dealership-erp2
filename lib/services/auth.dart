import 'package:corsac_jwt/corsac_jwt.dart';

import 'api.dart';
import 'storage.dart';
import '../models/all.dart';
import '../state.dart';
import '../utils/all.dart';

class SambazaAuth extends SambazaInjectableService {
  JWT _decodedJWT;
  DateTime _expiresAt;
  final Duration _maxRenewalTime = Duration(minutes: 5);
  final Duration _minRenewalTime = Duration(seconds: 30);
  String _rawJWT;
  String _rawToken;
  DateTime _renewAtStart;
  DateTime _renewAtStop;

  final List<Type> $inject = <Type>[SambazaAPI, SambazaStorage];
  User user;

  SambazaAuth() {
    $$<SambazaStorage>().ready.then((v) {
      if ($$<SambazaStorage>().has(SambazaState.AUTH_JWT_STORAGE_KEY)) {
        jwt = $$<SambazaStorage>().$get(SambazaState.AUTH_JWT_STORAGE_KEY);
      }
      if ($$<SambazaStorage>().has(SambazaState.AUTH_TOKEN_STORAGE_KEY)) {
        _rawToken = $$<SambazaStorage>().$get(SambazaState.AUTH_TOKEN_STORAGE_KEY);
      }
    });
  }

  void clear() {
    _decodedJWT = _expiresAt =
        _rawJWT = _renewAtStart = _renewAtStop = _rawToken = user = null;
  }

  Duration get expiresIn => _expiresAt.difference(DateTime.now());

  Duration get renewIn {
    DateTime now = DateTime.now();
    Duration toExpiry = _expiresAt.difference(now);
    Duration toRenewalMax = _renewAtStart.difference(now);
    Duration toRenewalMin = _renewAtStop.difference(now);
    return toRenewalMax.isNegative
        ? (toRenewalMin.isNegative ? toExpiry : toRenewalMin)
        : toRenewalMax;
  }

  String get jwt => _rawJWT ?? '';

  set jwt(String newJWT) {
    assert(newJWT.isNotEmpty);
    _rawJWT = newJWT;
    _decodedJWT = JWT.parse(newJWT);
    setUser();
    $$<SambazaStorage>().$set(SambazaState.AUTH_JWT_STORAGE_KEY, newJWT);
    // _expiresAt =
    //     DateTime.fromMillisecondsSinceEpoch(_decodedJWT.expiresAt * 1000);
    // _renewAtStart = _expiresAt.subtract(_maxRenewalTime);
    // _renewAtStop = _expiresAt.subtract(_minRenewalTime);
    // if (jwtIsValid) {
    //   $$<SambazaStorage>()
    //       .cache(SambazaState.AUTH_JWT_STORAGE_KEY, newJWT, expiresIn)
    //       .timeout(renewIn, onTimeout: () {
    //     SambazaResource(SambazaAPIEndpoints.accounts, '/token/refresh')
    //         .$save(<String, String>{'token': _rawJWT}).then(
    //             (Map<String, dynamic> result) {
    //       jwt = result['token'].toString();
    //     });
    //   });
    // }
  }

  String get token => _rawToken ?? '';

  set token(String newToken) {
    assert(newToken.isNotEmpty);
    _rawToken = newToken;
    $$<SambazaStorage>().$set(SambazaState.AUTH_TOKEN_STORAGE_KEY, newToken);
  }

  void setUser() {
    user = User.create(<String, dynamic>{
      'id': _decodedJWT.getClaim('user_id'),
      'email': _decodedJWT.getClaim('email'),
      'first_name': _decodedJWT.getClaim('first_name'),
      'last_name': _decodedJWT.getClaim('last_name'),
      'role': _decodedJWT.getClaim('is_regular_user')
          ? 'regular'
          : (_decodedJWT.getClaim('is_branch_admin') ? 'manager' : 'other'),
    });
  }

  bool get jwtIsValid {
    if (_rawJWT.isNotEmpty) {
      JWTValidator validator = new JWTValidator();
      Set<String> errors = validator.validate(_decodedJWT);
      return errors.length == 0;
    }
    return false;
  }
}
