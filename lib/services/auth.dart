import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'api.dart';
import 'storage.dart';
import '../models/all.dart';
import '../state.dart';
import '../utils/all.dart';

class SambazaAuth extends SambazaInjectableService {
  JWT? _decodedJWT;
  DateTime? _expiresAt;
  final Duration _maxRenewalTime = Duration(minutes: 5);
  final Duration _minRenewalTime = Duration(seconds: 30);
  String? _rawJWT;
  String? _rawToken;
  DateTime? _renewAtStart;
  DateTime? _renewAtStop;

  @override
  final List<Type> $inject = <Type>[SambazaAPI, SambazaStorage];
  User? user;

  SambazaAuth() {
    $$<SambazaStorage>().ready.then((v) {
      if ($$<SambazaStorage>().has(SambazaState.AUTH_JWT_STORAGE_KEY)) {
        jwt = $$<SambazaStorage>().$get(SambazaState.AUTH_JWT_STORAGE_KEY);
      }
      if ($$<SambazaStorage>().has(SambazaState.AUTH_TOKEN_STORAGE_KEY)) {
        _rawToken = $$<SambazaStorage>().$get(
          SambazaState.AUTH_TOKEN_STORAGE_KEY,
        );
      }
    });
  }

  void clear() {
    _decodedJWT = null;
    _expiresAt = null;
    _rawJWT = null;
    _renewAtStart = null;
    _renewAtStop = null;
    _rawToken = null;
    user = null;
  }

  Duration get expiresIn =>
      _expiresAt?.difference(DateTime.now()) ?? Duration.zero;

  Duration get renewIn {
    DateTime now = DateTime.now();
    Duration toExpiry = _expiresAt?.difference(now) ?? Duration.zero;
    Duration toRenewalMax = _renewAtStart?.difference(now) ?? Duration.zero;
    Duration toRenewalMin = _renewAtStop?.difference(now) ?? Duration.zero;
    return toRenewalMax.isNegative
        ? (toRenewalMin.isNegative ? toExpiry : toRenewalMin)
        : toRenewalMax;
  }

  String get jwt => _rawJWT ?? '';

  set jwt(String newJWT) {
    assert(newJWT.isNotEmpty);
    _rawJWT = newJWT;
    _decodedJWT = JWT.decode(newJWT); // Decodes without verifying signature
    setUser();
    $$<SambazaStorage>().$set(SambazaState.AUTH_JWT_STORAGE_KEY, newJWT);

    // You may want to extract expiry and renewal times from the JWT claims:
    final exp = _decodedJWT?.payload['exp'];
    if (exp != null) {
      _expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      _renewAtStart = _expiresAt?.subtract(_maxRenewalTime);
      _renewAtStop = _expiresAt?.subtract(_minRenewalTime);
    }
  }

  String get token => _rawToken ?? '';

  set token(String newToken) {
    assert(newToken.isNotEmpty);
    _rawToken = newToken;
    $$<SambazaStorage>().$set(SambazaState.AUTH_TOKEN_STORAGE_KEY, newToken);
  }

  void setUser() {
    if (_decodedJWT == null) return;
    user = User.create(<String, dynamic>{
      'id': _decodedJWT!.payload['user_id'],
      'email': _decodedJWT!.payload['email'],
      'first_name': _decodedJWT!.payload['first_name'],
      'last_name': _decodedJWT!.payload['last_name'],
      'role':
          _decodedJWT!.payload['is_regular_user'] == true
              ? 'regular'
              : (_decodedJWT!.payload['is_branch_admin'] == true
                  ? 'manager'
                  : 'other'),
    });
  }

  bool get jwtIsValid {
    if (_rawJWT != null && _rawJWT!.isNotEmpty) {
      try {
        JWT.verify(_rawJWT!, SecretKey('')); // Use your secret key if needed
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
