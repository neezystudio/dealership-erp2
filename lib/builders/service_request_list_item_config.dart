import 'package:flutter/material.dart';

import '../models/all.dart';
import '../utils/all.dart';

class SambazaServiceRequestListItemConfigBuilder
    extends SambazaListItemConfigBuilder<ServiceRequest, SambazaModel> {
  SambazaServiceRequestListItemConfigBuilder()
      : super(
          group: (ServiceRequest request, [SambazaModel lI]) =>
              SambazaListItemConfigBuilder.strFromTime(request.createdAt),
          leading: _buildLeading,
          subtitle: (ServiceRequest request, [SambazaModel lI]) {
            DateTime time = request.createdAt;
            return <String>[
              'KES ${request.amount.toInt().toString()}',
              'Placed at ${time.hour.toString()}:${time.minute.toString()}',
            ];
          },
          title: (ServiceRequest request, [SambazaModel lI]) =>
              request.requestNumber.toString(),
          trailing: _buildTrailing,
        );

  static List<Widget> _buildLeading(ServiceRequest request,
          [SambazaModel lI]) =>
      <Widget>[
        Icon(
          request.status == ServiceRequestStatus.fulfilled
              ? Icons.schedule
              : Icons.check,
          color: Colors.white,
          semanticLabel: request.$get('status').toString(),
        ),
      ];

  static Widget _buildTrailing(ServiceRequest request, [SambazaModel lI]) =>
      Column(
        children: <Widget>[
          Icon(
            <ServiceRequestStatus, IconData>{
              ServiceRequestStatus.approved: Icons.done,
              ServiceRequestStatus.created: Icons.schedule,
              ServiceRequestStatus.fulfilled: Icons.done_all,
              ServiceRequestStatus.rejected: Icons.cancel,
            }[request.status],
            color: <ServiceRequestStatus, Color>{
              ServiceRequestStatus.approved: Colors.cyan,
              ServiceRequestStatus.created: Colors.grey,
              ServiceRequestStatus.fulfilled: Colors.green,
              ServiceRequestStatus.rejected: Colors.red,
            }[request.status],
            semanticLabel: request.$get('status').toString(),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
}
