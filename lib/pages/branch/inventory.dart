import 'package:flutter/material.dart';

import '../../models/branch_inventory.dart';
import '../../resources.dart';
import '../../widgets/page.dart';
import '../../widgets/inventory.dart';

class BranchInventoryPage extends SambazaPage {
  static String route = '/branch/inventory';

  static BranchInventoryPage create(BuildContext context) =>
      BranchInventoryPage();

  BranchInventoryPage()
      : super(body: _BranchInventoryView(), title: 'Branch Inventory');
}

class _BranchInventoryView extends SambazaInventoryWidget<BranchInventory> {
  _BranchInventoryView()
      : super(
            modelFactory: ([Map<String, dynamic> fields]) =>
                BranchInventory.create(fields),
            resource: BranchInventoryResource());
}
