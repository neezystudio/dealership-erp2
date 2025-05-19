import 'airtime.dart';
import 'common/all.dart';
import '../utils/model.dart';
import '../utils/resource.dart';

abstract class Inventory<R extends SambazaResource> extends SambazaModel<R>
    with SambazaModelTimestamps {
  Airtime get airtime;
  String get branch;
  String get company;
  num get quantity;
  num get value;

  Inventory.create([Map<String, dynamic> inventory]) : super.create(inventory);

  Inventory.from(Map<String, dynamic> inventory) : super.from(inventory);

  @override
  void init() {
    know(<String>[
      'airtime',
      'branch',
      'company',
      'quantity',
      'value',
    ]);
    relate('airtime', Airtime.create(fields['airtime']));
    super.init();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);
}
