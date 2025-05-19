import 'airtime.dart';
import 'common/all.dart';
import '../utils/model.dart';

class SaleItem extends SambazaModel with SambazaModelTimestamps {
  Airtime get airtime;
  String get notes;
  num get quantity;
  set quantity(q);
  String get sale;
  num get value;

  SaleItem.create([Map<String, dynamic> saleItem]) : super.create(saleItem);

  SaleItem.from(Map<String, dynamic> saleItem) : super.from(saleItem);

  @override
  void init() {
    know(<String>[
      'airtime',
      'notes',
      'quantity',
      'sale',
      'value',
    ]);
    relate('airtime', Airtime.create(fields['airtime']));
    super.init();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);
}
