import 'branch_dispatch_item.dart';
import 'dispatch.dart';
import '../resources.dart';

class BranchDispatch extends Dispatch<BranchDispatchResource> {
  BranchDispatch.create([Map<String, dynamic> dispatch])
      : super.create(dispatch ?? <String, dynamic>{});

  BranchDispatch.from(Map<String, dynamic> dispatch) : super.from(dispatch);

  @override
  void init() {
    resource = BranchDispatchResource();
    listOn<BranchDispatchItem>(
        'dispatch_items',
        List<Map<String, dynamic>>.from(fields['dispatch_items']),
        ([Map<String, dynamic> dI]) => BranchDispatchItem.create(resource, dI));
    super.init();
  }
}
