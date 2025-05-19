import 'common/all.dart';
import 'telco.dart';
import '../resources.dart';
import '../utils/model.dart';

class Airtime extends SambazaModel<AirtimeResource>
    with SambazaModelTimestamps {
  Telco $telco;

  String get name;
  num get packetSize;
  num get price;
  num get sellingPrice;
  String get telco;
  num get value;

  Airtime.create([Map<String, dynamic> airtime]) : super.create(airtime);

  Airtime.from(Map<String, dynamic> airtime) : super.from(airtime);

  @override
  void init() {
    know(<String>[
      'name',
      'packet_size',
      'price',
      'selling_price',
      'telco',
      'value',
    ]);
    resource = AirtimeResource();
    super.init();
  }

  @override
  String get serialised => id;
}
