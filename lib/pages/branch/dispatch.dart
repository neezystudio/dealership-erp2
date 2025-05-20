import 'package:flutter/material.dart';

import '../../models/all.dart';
import '../../resources.dart';
import '../../widgets/page.dart';
import '../../widgets/dispatch.dart';

class BranchDispatchPage extends SambazaPage {
  static String route = '/branch/dispatch';

  static BranchDispatchPage create(BuildContext context) =>
      BranchDispatchPage();

  BranchDispatchPage()
      : super(body: _BranchDispatchView(), title: 'Branch Dispatch');
}

class _BranchDispatchView
    extends SambazaDispatchWidget<BranchDispatch, BranchDispatchItem> {
  _BranchDispatchView()
      : super(
          modelFactory: ([Map<String, dynamic>? fields]) =>
              BranchDispatch.create(fields),
          resource: BranchDispatchResource(),
          subtitle:
              (BranchDispatch dispatch, [BranchDispatchItem? dispatchItem]) {
                return <String>[
                  'KES ${dispatchItem!.value.toInt().toString()}'
                ];
              },
              title: (BranchDispatch dispatch, [BranchDispatchItem? dispatchItem]) =>
              '${dispatchItem!.quantity.toString()} Cards',
        );
}
