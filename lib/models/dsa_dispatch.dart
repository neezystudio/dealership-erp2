import 'dsa_dispatch_item.dart';
import 'dispatch.dart';
import '../resources.dart';

class DSADispatch extends Dispatch<DSADispatchResource> {
  DSADispatch.create([Map<String, dynamic> dispatch])
      : super.create(dispatch ?? <String, dynamic>{});

  DSADispatch.from(Map<String, dynamic> dispatch) : super.from(dispatch);

  @override
  void init() {
    resource = DSADispatchResource();
    listOn<DSADispatchItem>(
        'dispatch_items',
        List<Map<String, dynamic>>.from(fields['dispatch_items']),
        ([Map<String, dynamic> dI]) => DSADispatchItem.create(resource, dI));
    super.init();
  }
}
