import 'injectable/not_injected_exception.dart';
import 'service.dart';
import 'service/provider.dart';

mixin SambazaInjectable<T extends SambazaService> {
  final List<Type> $inject = <Type>[];
  final Map<Type, T> $services = <Type, T>{};

  /// 
  ///Retrieve a service from the injected service cache
  ///
  ///@return SambazaService
  ///
  E $$<E extends T>() => $<E>(E);

  ///
  ///Retrieve a service from the list of injected services `$inject`
  ///
  ///@return SambazaService
  ///
  E $<E extends T>(Type type) {
    if (!$services.containsKey(type)) {
      throw SambazaServiceNotInjectedException(
          'There was a problem trying to access an injected service of type \'${type.toString()}\' ',
          'Service not injected');
    }
    return $services[type];
  }

  void inject() {
    SambazaServiceProvider provider = SambazaServiceProvider();
    for (var type in $inject) {
      $services[type] = provider(type);
    }
  }
}
