import 'common/all.dart';
import '../resources.dart';
import '../services/api.dart';
import '../utils/all.dart';

enum StockTransferParty { branch, dsa }
enum StockTransferStatus { approved, created, fulfilled, processing }

final Map<String, StockTransferParty> _stockTransferPartyMap =
    StockTransferParty.values.asMap().map<String, StockTransferParty>(
        (int i, StockTransferParty s) =>
            MapEntry(s.toString().split('.').last, s));
final Map<String, StockTransferStatus> _stockTransferStatusMap =
    StockTransferStatus.values.asMap().map<String, StockTransferStatus>(
        (int i, StockTransferStatus s) =>
            MapEntry(s.toString().split('.').last, s));

class StockTransfer extends SambazaModel<StockTransferResource>
    with SambazaInjectable, SambazaModelFlags, SambazaModelTimestamps {
  @override
  final List<Type> $inject = <Type>[SambazaAPI];

  String get airtime;
  String get branch;
  String get company;
  String get destination;
  String get $destinationType => fields['destination_type'];
  StockTransferParty get destinationType =>
      _stockTransferPartyMap[$destinationType];
  set destinationType(StockTransferParty d) {
    fields['destination_type'] = d.toString().split('.').last;
  }

  String get origin;
  String get $originType => fields['origin_type'];
  StockTransferParty get originType => _stockTransferPartyMap[$originType];
  set originType(StockTransferParty o) {
    fields['origin_type'] = o.toString().split('.').last;
  }

  num get quantity;
  String get $status => fields['status'];
  StockTransferStatus get status => _stockTransferStatusMap[$status];
  set status(StockTransferStatus s) {
    fields['status'] = s.toString().split('.').last;
  }

  num get value;

  StockTransfer.create([super.fields]) : super.create();

  StockTransfer.from(super.fields) : super.from();

  @override
  void init() {
    inject();
    know(<String>[
      'airtime',
      'branch',
      'company',
      'destination',
      'destination_type',
      'origin',
      'origin_type',
      'quantity',
      'status',
      'value',
    ]);
    resource = StockTransferResource();
    super.init();
  }

  Future<void> approve() =>
      $$<SambazaAPI>().send('${resource.endpoint}approve/', <String, String>{
        'transfer_id': id,
      });

  Future<void> fulfill() =>
      $$<SambazaAPI>().send('${resource.endpoint}fullfill/', <String, String>{
        'transfer_id': id,
      });
}
