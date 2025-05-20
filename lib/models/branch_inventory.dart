import 'inventory.dart';
import '../resources.dart';

class BranchInventory extends Inventory<BranchInventoryResource> {
  BranchInventory.create([Map<String, dynamic>? inventory])
      : super.create(inventory ?? <String, dynamic>{});

  BranchInventory.from(super.inventory) : super.from();

  @override
  void init() {
    resource = BranchInventoryResource();
    super.init();
  }
}
