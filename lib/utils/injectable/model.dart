import '../injectable.dart';
import '../model.dart';
import '../resource.dart';

abstract class SambazaInjectableModel<R extends SambazaResource>
    extends SambazaModel<R> with SambazaInjectable {
  SambazaInjectableModel.create([Map<String, dynamic> fields])
      : super.create(fields);

  SambazaInjectableModel.from(Map<String, dynamic> fields) : super.from(fields);

  @override
  void init() {
    inject();
    super.init();
  }
}
