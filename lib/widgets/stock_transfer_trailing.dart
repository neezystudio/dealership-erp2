import 'package:flutter/material.dart';

import '../models/all.dart';
import '../services/all.dart';

class StockTransferTrailing extends StatefulWidget {
  final String entity;
  final StockTransfer stockTransfer;

  StockTransferTrailing(
    this.entity,
    this.stockTransfer,
  );

  @override
  _StockTransferTrailingState createState() => _StockTransferTrailingState();
}

class _StockTransferTrailingState extends State<StockTransferTrailing> {
  final List<Type> $inject = <Type>[
    SambazaAuth,
  ];

  bool get entityIsDestination =>
      widget.entity == widget.stockTransfer.destination;

  bool get entityIsOrigin => widget.entity == widget.stockTransfer.origin;

  bool stockTransferIs(
    StockTransferStatus s,
  ) =>
      widget.stockTransfer.status == s;

  @override
  Widget build(
    BuildContext context,
  ) =>
      stockTransferIs(
        StockTransferStatus.processing,
      )
          ? _processing()
          : stockTransferIs(
                    StockTransferStatus.created,
                  ) &&
                  entityIsDestination
              ? _createdDestinationWidget()
              : stockTransferIs(
                        StockTransferStatus.created,
                      ) &&
                      entityIsOrigin
                  ? _createdOriginWidget()
                  : stockTransferIs(
                            StockTransferStatus.approved,
                          ) &&
                          entityIsDestination
                      ? _approvedDestinationWidget()
                      : stockTransferIs(
                                StockTransferStatus.approved,
                              ) &&
                              entityIsOrigin
                          ? _approvedOriginWidget()
                          : stockTransferIs(
                              StockTransferStatus.fulfilled,
                            )
                              ? _fulfilled()
                              : _unknown();

  Widget _approvedDestinationWidget() => GestureDetector(
        child: Column(
          children: <Widget>[
            Text(
              'Approved',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 8,
              ),
            ),
            Icon(
              Icons.check_circle_outline,
              semanticLabel: 'Fulfill',
            ),
            Text(
              'Fulfill',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 8,
              ),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        onTap: () {
          setState(() {
            widget.stockTransfer.status = StockTransferStatus.processing;
          });
          widget.stockTransfer.fulfill().then((x) {
            setState(() {
              widget.stockTransfer.status = StockTransferStatus.fulfilled;
            });
          }).catchError((e) {
            print(e);
            setState(() {
              widget.stockTransfer.status = StockTransferStatus.approved;
            });
          });
        },
      );

  Widget _approvedOriginWidget() => Column(
        children: <Widget>[
          Icon(
            Icons.done,
            color: Colors.green,
            semanticLabel: 'Approved',
          ),
          Text(
            'Approved',
            style: TextStyle(
              color: Colors.green,
              fontSize: 8,
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );

  Widget _createdDestinationWidget() => Column(
        children: <Widget>[
          Icon(
            Icons.schedule,
            semanticLabel: 'Created',
          ),
          Text(
            'Created',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 8,
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );

  Widget _createdOriginWidget() => GestureDetector(
        child: Column(
          children: <Widget>[
            Text(
              'Created',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 8,
              ),
            ),
            Icon(
              Icons.check_circle_outline,
              color: Colors.cyan,
              semanticLabel: 'Approve',
            ),
            Text(
              'Approve',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 8,
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        onTap: () {
          setState(() {
            widget.stockTransfer.status = StockTransferStatus.processing;
          });
          widget.stockTransfer.approve().then((x) {
            setState(() {
              widget.stockTransfer.status = StockTransferStatus.approved;
            });
          }).catchError((e) {
            print(e);
            setState(() {
              widget.stockTransfer.status = StockTransferStatus.created;
            });
          });
        },
      );

  Widget _fulfilled() => Column(
        children: <Widget>[
          Icon(
            Icons.done_all,
            color: Colors.green,
            semanticLabel: 'Fulfilled',
          ),
          Text(
            'Fulfilled',
            style: TextStyle(
              color: Colors.green,
              fontSize: 8,
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );

  Widget _processing() =>
      CircularProgressIndicator(semanticsLabel: widget.stockTransfer.$status);

  Widget _unknown() => Column(
        children: <Widget>[
          Icon(
            Icons.warning,
            semanticLabel: 'unknown',
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
}
