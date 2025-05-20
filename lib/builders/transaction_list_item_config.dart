import 'package:flutter/material.dart';

import '../models/all.dart';
import '../utils/all.dart';

class SambazaTransactionListItemConfigBuilder
    extends SambazaListItemConfigBuilder<Transaction, SambazaModel> {
  SambazaTransactionListItemConfigBuilder()
    : super(
        group:
            (Transaction transaction, [SambazaModel? listItem]) =>
                SambazaListItemConfigBuilder.strFromTime(transaction.createdAt),
        leading: _buildLeading,
        subtitle: (Transaction transaction, [SambazaModel? listItem]) {
          DateTime time = transaction.createdAt;
          return <String>[
            'KES ${transaction.value.toInt().toString()}',
            'Placed at ${time.hour.toString()}:${time.minute.toString()}',
          ];
        },
        title:
            (Transaction transaction, [SambazaModel? listItem]) =>
                transaction.transactionNumber.toString(),
        trailing: _buildTrailing,
      );

  static List<Widget> _buildLeading(
    Transaction transaction, [
    SambazaModel? listItem,
  ]) => <Widget>[
    Icon(
      transaction.method == TransactionMethod.mpesa
          ? Icons.smartphone
          : Icons.account_balance,
      color: Colors.white,
      semanticLabel:
          transaction.method == TransactionMethod.mpesa
              ? 'M-Pesa'
              : 'Bank Transfer',
    ),
    Text(
      transaction.method == TransactionMethod.mpesa ? 'M-PESA' : 'Bank',
      style: TextStyle(color: Colors.white, fontSize: 8),
    ),
  ];

  static Widget _buildTrailing(
    Transaction transaction, [
    SambazaModel? listItem,
  ]) {
    return Column(
      children: <Widget>[
        Icon(
          transaction.status == TransactionStatus.approved
              ? Icons.done
              : Icons.schedule,
          color:
              transaction.status == TransactionStatus.approved
                  ? Colors.green
                  : Colors.cyan,
          semanticLabel: 'status is ${transaction.status.toString()}',
        ),
        Text(
          transaction.$status,
          style: TextStyle(
            color:
                transaction.status == TransactionStatus.approved
                    ? Colors.green
                    : Colors.cyan,
            fontSize: 8,
          ),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }
}
