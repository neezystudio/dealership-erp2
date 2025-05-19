import 'dispatch_item.dart';
import '../resources.dart';

class BranchDispatchItem extends DispatchItem<BranchDispatchResource> {
  BranchDispatchItem.create(BranchDispatchResource dispatchResource,
      [Map<String, dynamic> dispatchItem])
      : super.create(dispatchResource, dispatchItem);

  BranchDispatchItem.from(BranchDispatchResource dispatchResource,
      Map<String, dynamic> dispatchItem)
      : super.from(dispatchResource, dispatchItem);
}
