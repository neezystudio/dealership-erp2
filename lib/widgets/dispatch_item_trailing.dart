import 'package:flutter/material.dart';

import '../models/dispatch_item.dart';

class DispatchItemTrailing extends StatefulWidget {
  final DispatchItem dispatchItem;

  const DispatchItemTrailing(this.dispatchItem, {super.key});

  @override
  _DispatchItemTrailing createState() => _DispatchItemTrailing();
}

class _DispatchItemTrailing extends State<DispatchItemTrailing> {

  bool dispatchItemIs(DispatchItemStatus d) => widget.dispatchItem.status == d;

  @override
  Widget build(BuildContext context) =>
      dispatchItemIs(DispatchItemStatus.processing)
          ? _processing()
          : dispatchItemIs(DispatchItemStatus.received)
              ? _received()
              : _receive();

  Widget _receive() => GestureDetector(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.check_circle_outline,
              color: Colors.cyan,
              semanticLabel: 'Received',
            ),
            Text(
              'Receive',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 8,
              ),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            widget.dispatchItem.status = DispatchItemStatus.processing;
          });
          widget.dispatchItem.receive().then((x) {
            setState(() {
              widget.dispatchItem.status = DispatchItemStatus.received;
            });
          }).catchError((e) {
            print(e);
            setState(() {
              widget.dispatchItem.status = DispatchItemStatus.created;
            });
          });
        },
      );

  Widget _received() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.check_circle,
            color: Colors.green,
            semanticLabel: 'Received',
          ),
          Text(
            'Received',
            style: TextStyle(
              color: Colors.green,
              fontSize: 8,
            ),
          ),
        ],
      );

  Widget _processing() =>
      CircularProgressIndicator(semanticsLabel: 'Receiving item');
}
