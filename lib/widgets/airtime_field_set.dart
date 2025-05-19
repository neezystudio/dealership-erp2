import 'package:flutter/material.dart';

import 'field_row.dart';

class SambazaAirtimeFieldSet extends StatelessWidget {
  final String airtimeFieldName;
  final Widget Function(String) formFieldBuilder;
  final void Function() deleteSetCallback;
  final String quantityFieldName;

  SambazaAirtimeFieldSet(
    this.formFieldBuilder, {
    required this.airtimeFieldName,
    required this.quantityFieldName,
    required void Function() onDelete,
  }) : deleteSetCallback = onDelete ?? (() {});

  @override
  Widget build(BuildContext context) => SambazaFieldRow(
        children: <Widget>[
          SambazaFieldRow.child(
            field: formFieldBuilder(airtimeFieldName),
            flex: 5,
          ),
          SambazaFieldRow.child(
            field: formFieldBuilder(quantityFieldName),
            flex: 2,
          ),
          Expanded(
            child: IconButton(
              icon: Icon(
                Icons.delete,
                semanticLabel: 'Remove item',
              ),
              onPressed: deleteSetCallback,
            ),
          ),
        ],
      );
}
