import 'package:equatable/equatable.dart';

abstract class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Trigger CSV export for inventory product list.
class TriggerExportInventoryEvent extends ExportEvent {
  const TriggerExportInventoryEvent();
}

/// Event: Trigger CSV export for customer list & due balances.
class TriggerExportCustomersEvent extends ExportEvent {
  const TriggerExportCustomersEvent();
}

/// Event: Trigger CSV export for sales invoices history.
class TriggerExportSalesEvent extends ExportEvent {
  const TriggerExportSalesEvent();
}

/// Event: Trigger CSV export for single customer ledger statement.
class TriggerExportCustomerLedgerEvent extends ExportEvent {
  final String customerId;

  const TriggerExportCustomerLedgerEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}
