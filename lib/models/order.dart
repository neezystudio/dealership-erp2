import 'common/all.dart';
import 'order_item.dart';
import '../resources.dart';
import '../utils/model.dart';

class Order extends SambazaModel<OrderResource> with SambazaModelFlags, SambazaModelTimestamps {
  String get batch;
  String get branch;
  String get collectionCentre;
  String get comments;
  set comments(c);
  String get company;
  List<OrderItem> get orderItems;
  String get orderNumber;
  String get user;
  num get value;

  Order.create([Map<String, dynamic> order]) : super.create(order);

  Order.from(Map<String, dynamic> order) : super.from(order);

  @override
  init() {
    know(<String>[
      'batch',
      'branch',
      'collection_centre',
      'comments',
      'company',
      'order_items',
      'order_number',
      'value',
      'user',
    ]);
    listOn<OrderItem>(
        'order_items',
        List<Map<String, dynamic>>.from(fields['order_items']),
        ([Map<String, dynamic> oI]) => OrderItem.create(oI));
    resource = OrderResource();
    super.init();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);
}
