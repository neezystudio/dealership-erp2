import '../state.dart';

typedef SambazaServiceFactory<T extends SambazaService> = T Function();
typedef SambazaServiceRegistrar<T extends SambazaService> = T Function(
    SambazaState);

abstract class SambazaService {
  void register(SambazaState state) => state.$provider.register(this);
}
