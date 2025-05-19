import 'airtime.dart';
import 'common/all.dart';
import '../utils/model.dart';

class OrderItem extends SambazaModel with SambazaModelTimestamps {
  Airtime get airtime;
  String get order;
  num get prorate;
  num get quantity;
  set quantity(q);
  num get value;

  OrderItem.create([Map<String, dynamic> orderItem]) : super.create(orderItem);

  OrderItem.from(Map<String, dynamic> orderItem) : super.from(orderItem);

  @override
  void init() {
    know(<String>[
      'airtime',
      'order',
      'prorate',
      'quantity',
      'value',
    ]);
    if (fields['airtime'] is Map) {
      relate('airtime', Airtime.create(fields['airtime']));
    }
    super.init();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);
}
