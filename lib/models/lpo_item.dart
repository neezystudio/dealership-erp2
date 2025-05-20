import 'dart:convert';

import 'airtime.dart';
import 'common/all.dart';
import '../resources.dart';
import '../services/all.dart';
import '../utils/all.dart';

enum LPOItemScaleStatus { processing, scaled, unscaled }

class LPOItem extends SambazaInjectableModel
    with SambazaInjectable, SambazaModelTimestamps {
  @override
  final List<Type> $inject = <Type>[SambazaAPI];
  final LPOResource lpoResource;

  Airtime get airtime;
  bool get assigned => serialFirst != serialLast;
  String get lpo;
  num get packets;
  num get price;
  num get quantity;
  num get serialFirst;
  num get serialLast;
  num get value;

  LPOItem.create(this.lpoResource, [Map<String, dynamic>? lpoItem])
      : super.create(lpoItem!);

  LPOItem.from(this.lpoResource, Map<String, dynamic> lpoItem)
      : super.from(lpoItem);

  @override
  void init() {
    know(<String>[
      'airtime',
      'lpo',
      'lpoItems',
      'packets',
      'price',
      'quantity',
      'serial_first',
      'serial_last',
      'value',
    ]);
    relate('airtime', Airtime.create(fields['airtime']));
    super.init();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);

  Future<void> assignSerial(num serialFirst, num serialLast) => $$<SambazaAPI>()
          .send('${lpoResource.endpoint}assign_serials/', <String, dynamic>{
        'item_id': id,
        'serial_first': serialFirst,
        'serial_last': serialLast,
      }).then((_) {
        fields['serial_first'] = serialFirst;
        fields['serial_last'] = serialLast;
      });

  Future<void> scale() =>
      $$<SambazaAPI>().send('${lpoResource.endpoint}scale/', <String, dynamic>{
        'item_id': id,
        'scale_up': true,
      }).then((String response) =>
          fields.addAll(Map<String, dynamic>.from(json.decode(response))));
}
