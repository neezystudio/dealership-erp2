import 'common/all.dart';
import '../resources.dart';
import '../utils/model.dart';

class Telco extends SambazaModel<TelcoResource>
    with SambazaModelTimestamps {
  String get country;
  String get name;

  Telco.create([super.telco]) : super.create();

  Telco.from(super.telco) : super.from();

  @override
  void init() {
    know(<String>[
      'country',
      'name',
    ]);
    resource = TelcoResource();
    super.init();
  }

  @override
  String get serialised => id;
}