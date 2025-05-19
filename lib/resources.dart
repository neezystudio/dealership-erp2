import 'utils/api.dart';
import 'utils/resource.dart';

class AirtimeResource extends SambazaResource {
  AirtimeResource() : super(SambazaAPIEndpoints.airtime);
}

class BatchResource extends SambazaResource {
  BatchResource() : super(SambazaAPIEndpoints.batches);
}

class BranchResource extends SambazaResource {
  BranchResource() : super(SambazaAPIEndpoints.branches);
}

class BranchDispatchResource extends SambazaResource {
  BranchDispatchResource() : super(SambazaAPIEndpoints.dispatch, '/branch');
}

class BranchInventoryResource extends SambazaResource {
  BranchInventoryResource() : super(SambazaAPIEndpoints.inventory, '/branch');
}

class CollectionCentreResource extends SambazaResource {
  CollectionCentreResource(): super(SambazaAPIEndpoints.collectionCentres);
}

class CompanyResource extends SambazaResource {
  CompanyResource(): super(SambazaAPIEndpoints.companies);
}

class DSADispatchResource extends SambazaResource {
  DSADispatchResource() : super(SambazaAPIEndpoints.dispatch, '/dsa');
}

class DSAInventoryResource extends SambazaResource {
  DSAInventoryResource() : super(SambazaAPIEndpoints.inventory, '/dsa');
}

class LPOResource extends SambazaResource {
  LPOResource() : super(SambazaAPIEndpoints.lpos);
}

class OrderResource extends SambazaResource {
  OrderResource() : super(SambazaAPIEndpoints.orders);
}

class RollupResource extends SambazaResource {
  RollupResource(): super(SambazaAPIEndpoints.rollup);
}

class SaleResource extends SambazaResource {
  SaleResource() : super(SambazaAPIEndpoints.sales);
}

class ServiceRequestResource extends SambazaResource {
  ServiceRequestResource() : super(SambazaAPIEndpoints.requests);
}

class StockTransferResource extends SambazaResource {
  StockTransferResource() : super(SambazaAPIEndpoints.stockTransfers);
}

class TelcoResource extends SambazaResource {
  TelcoResource() : super(SambazaAPIEndpoints.telcos);
}

class TransactionResource extends SambazaResource {
  TransactionResource(): super(SambazaAPIEndpoints.transactions);
}

class UserResource extends SambazaResource {
  UserResource() : super(SambazaAPIEndpoints.accounts, '/users');
}
