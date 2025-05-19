import 'common/all.dart';
import '../resources.dart';
import '../utils/model.dart';

class Telco extends SambazaModel<TelcoResource>
    with SambazaModelTimestamps {
  String get country;
  String get name;

  Telco.create([Map<String, dynamic> telco]) : super.create(telco);

  Telco.from(Map<String, dynamic> telco) : super.from(telco);

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