import 'common/all.dart';
import '../utils/model.dart';

class Debt extends SambazaModel with SambazaModelTimestamps {
  String get branch;
  String get company;
  num get percentage;
  num get totalSales;
  num get totalTransactions;
  String get user;
  num get value;

  Debt.create([Map<String, dynamic>? debt]) : super.create(debt ?? {});

  Debt.from(super.debt) : super.from();

  @override
  void init() {
    know(<String>[
      'branch',
      'company',
      'percentage',
      'total_sales',
      'total_transactions',
      'value',
    ]);
    super.init();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);
}
