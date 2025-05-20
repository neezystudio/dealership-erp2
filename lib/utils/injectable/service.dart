import 'not_injected_exception.dart';
import '../injectable.dart';
import '../service.dart';
import '../service/provider.dart';

abstract class SambazaInjectableService extends SambazaService
    with SambazaInjectable {
      
  final SambazaServiceProvider _provider = SambazaServiceProvider();

  @override
  E $<E extends SambazaService>(Type type) {
    if (!$inject.contains(type)) {
      throw SambazaServiceNotInjectedException(
          'There was a problem trying to access an injected service of type \'${type.toString()}\' ',
          'Service not injected');
    }
    return _provider(type);
  }
  
}
