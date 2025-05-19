import 'inventory.dart';
import '../resources.dart';

class DSAInventory extends Inventory<DSAInventoryResource> {
  DSAInventory.create([Map<String, dynamic> inventory])
      : super.create(inventory ?? <String, dynamic>{});

  DSAInventory.from(Map<String, dynamic> inventory) : super.from(inventory);

  @override
  void init() {
    resource = DSAInventoryResource();
    super.init();
  }
}
