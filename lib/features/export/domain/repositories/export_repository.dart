import 'entities/export_file_entity.dart';

/// Abstract Repository Contract for Bulk Data Exports.
abstract class ExportRepository {
  /// Exports inventory product list to CSV (GET /api/export/inventory).
  Future<ExportFileEntity> exportInventory();

  /// Exports customer list and due balances to CSV (GET /api/export/customers).
  Future<ExportFileEntity> exportCustomers();

  /// Exports sales invoices history to CSV (GET /api/export/sales).
  Future<ExportFileEntity> exportSales();

  /// Exports single customer transaction ledger to CSV (GET /api/export/ledger/:customerId).
  Future<ExportFileEntity> exportCustomerLedger(String customerId);
}
