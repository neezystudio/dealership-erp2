import 'not_found_exception.dart';
import '../cache.dart';
import '../service.dart';

class SambazaServiceContainer implements SambazaCache<Type, SambazaService> {
  static final SambazaServiceContainer _instance =
      SambazaServiceContainer._internal();

  final Map<Type, SambazaService> _services = <Type, SambazaService>{};

  factory SambazaServiceContainer() => _instance;

  SambazaServiceContainer._internal();

  bool has(Type type) => _services.containsKey(type);

  void $set(Type type, SambazaService value) {
    _services[type] = value;
  }

  SambazaService $get(Type type) {
    if (_services.containsKey(type)) {
      return _services[type];
    } else {
      throw SambazaServiceNotFoundException(
          'No service of type \'${type.toString()}\' could be found',
          'Service not found');
    }
  }
}
