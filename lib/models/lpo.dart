import 'dart:convert';

import 'common/all.dart';
import 'lpo_item.dart';
import '../resources.dart';
import '../services/all.dart';
import '../utils/all.dart';
    
enum LPOStatus { approved, created, fulfilled, processing, rejected }

final Map<String, LPOStatus> _lpoStatusMap =
    LPOStatus.values.asMap().map<String, LPOStatus>(
        (int i, LPOStatus l) =>
            MapEntry(l.toString().split('.').last, l));

class LPO extends SambazaModel<LPOResource> with SambazaInjectable, SambazaModelFlags, SambazaModelTimestamps {
  final List<Type> $inject = <Type>[SambazaAPI];

  String get batch;
  String get collectionCentre;
  String get company;
  List<LPOItem> get lpoItems;
  String get lpoNumber;
  LPOStatus get status => _lpoStatusMap[$status];
  String get $status => fields['status'];

  LPO.create([Map<String, dynamic> lpo]) : super.create(lpo);

  LPO.from(Map<String, dynamic> lpo) : super.from(lpo);

  @override
  init() {
    know(<String>[
      'batch',
      'collection_centre',
      'company',
      'lpo_items',
      'lpo_number',
      'status',
    ]);
    listOn<LPOItem>(
        'lpo_items',
        List<Map<String, dynamic>>.from(fields['lpo_items']),
        ([Map<String, dynamic> lI]) => LPOItem.create(LPOResource(), lI));
    super.init();
    resource = LPOResource();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);

  Future<void> approve() =>
      $$<SambazaAPI>().send('${resource.endpoint}approve/', <String, String>{
        'lpo_id': id,
      }).then((String response) =>
          fields.addAll(Map<String, dynamic>.from(json.decode(response))));
}
