import 'inventory.dart';
import '../resources.dart';

class DSAInventory extends Inventory<DSAInventoryResource> {
  DSAInventory.create([Map<String, dynamic>? inventory])
      : super.create(inventory ?? <String, dynamic>{});

  DSAInventory.from(super.inventory) : super.from();

  @override
  void init() {
    resource = DSAInventoryResource();
    super.init();
  }
}
