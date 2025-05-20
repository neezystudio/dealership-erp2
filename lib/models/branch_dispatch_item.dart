import 'dispatch_item.dart';
import '../resources.dart';

class BranchDispatchItem extends DispatchItem<BranchDispatchResource> {
  BranchDispatchItem.create(BranchDispatchResource dispatchResource,
      [Map<String, dynamic>? dispatchItem])
      : super.create(dispatchResource, dispatchItem!);

  BranchDispatchItem.from(super.dispatchResource,
      super.dispatchItem)
      : super.from();
}
