import 'airtime.dart';
import 'common/all.dart';
import '../services/api.dart';
import '../utils/injectable.dart';
import '../utils/resource.dart';
import '../utils/model.dart';

enum DispatchItemStatus { created, received, processing }

final Map<String, DispatchItemStatus> _dispatchItemStatusMap = DispatchItemStatus.values
    .asMap()
    .map<String, DispatchItemStatus>((int i, DispatchItemStatus d) =>
        MapEntry(d.toString().split('.').last, d));

abstract class DispatchItem<R extends SambazaResource> extends SambazaModel
    with SambazaInjectable, SambazaModelTimestamps {
      String _status;

  Airtime get airtime;
  String get dispatch;
  final R dispatchResource;
  num get quantity;
  set quantity(q);
  bool get received;
  num get value;
  DispatchItemStatus get status => _dispatchItemStatusMap[_status];
  set status(DispatchItemStatus d) {
    _status = d.toString().split('.').last;
    fields['received'] = d == DispatchItemStatus.received;
  }

  String get $status => _status;

  @override
  final List<Type> $inject = <Type>[SambazaAPI];

  DispatchItem.create(this.dispatchResource,
      [Map<String, dynamic>? dispatchItem])
      : super.create(dispatchItem!);

  DispatchItem.from(this.dispatchResource, Map<String, dynamic> dispatchItem)
      : super.from(dispatchItem);

  @override
  void init() {
    know(<String>[
      'airtime',
      'dispatch',
      'quantity',
      'received',
      'serial_first',
      'serial_last',
      'value',
    ]);
    relate('airtime', Airtime.create(fields['airtime']));
    _status = (received ? DispatchItemStatus.received : DispatchItemStatus.created).toString().split('.').last;
    inject();
    super.init();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);

  Future<String> receive() => $$<SambazaAPI>()
          .send('${dispatchResource.endpoint}receive/', <String, String>{
        'dispatch_item_id': id,
      });
}
