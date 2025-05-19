import 'common/all.dart';
import 'sale_item.dart';
import '../resources.dart';
import '../utils/model.dart';

class Sale extends SambazaModel<SaleResource>
    with SambazaModelFlags, SambazaModelTimestamps {
  String get batch;
  String get branch;
  String get company;
  String get notes;
  set notes(n);
  List<SaleItem> get saleItems;
  String get saleNumber;
  String get user;
  num get value;

  Sale.create([Map<String, dynamic> sale]) : super.create(sale);

  Sale.from(Map<String, dynamic> sale) : super.from(sale);

  @override
  init() {
    know(<String>[
      'branch',
      'company',
      'notes',
      'sale_items',
      'sale_number',
      'value',
      'user',
    ]);
    listOn<SaleItem>(
        'sale_items',
        List<Map<String, dynamic>>.from(fields['sale_items']),
        ([Map<String, dynamic> oI]) => SaleItem.create(oI));
    resource = SaleResource();
    super.init();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);
}
