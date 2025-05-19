import 'common/all.dart';
import 'dispatch_item.dart';
import '../utils/model.dart';
import '../utils/resource.dart';

abstract class Dispatch<R extends SambazaResource> extends SambazaModel<R>
    with SambazaModelTimestamps {
  String get branch;
  String get company;
  List<DispatchItem> get dispatchItems;
  num get value;

  Dispatch.create([Map<String, dynamic> dispatch]) : super.create(dispatch);

  Dispatch.from(Map<String, dynamic> dispatch) : super.from(dispatch);

  @override
  void init() {
    know(<String>[
      'airtime',
      'branch',
      'company',
      'value',
    ]);
    super.init();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);
}
