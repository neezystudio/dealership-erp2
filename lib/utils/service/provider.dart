import 'container.dart';
import '../service.dart';

class SambazaServiceProvider {
  static SambazaServiceContainer _container = SambazaServiceContainer();

  const SambazaServiceProvider();

  SambazaService call(Type type) => _container.$get(type);

  void register(SambazaService service) {
    if (_container.has(service.runtimeType)) {
      print('SambazaServiceProvider: Skipping service registration for ${service.runtimeType}. Registration is only allowed once');
      return;
    }
    _container.$set(service.runtimeType, service);
  }

}