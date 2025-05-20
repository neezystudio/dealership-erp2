import '../injectable.dart';
import '../model.dart';
import '../resource.dart';

abstract class SambazaInjectableModel<R extends SambazaResource>
    extends SambazaModel<R> with SambazaInjectable {
  SambazaInjectableModel.create(super.fields)
      : super.create();

  SambazaInjectableModel.from(super.fields) : super.from();

  @override
  void init() {
    inject();
    super.init();
  }
}
