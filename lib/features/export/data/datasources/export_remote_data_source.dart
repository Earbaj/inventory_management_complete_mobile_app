import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/export_file_entity.dart';

abstract class ExportRemoteDataSource {
  Future<ExportFileEntity> exportInventory();
  Future<ExportFileEntity> exportCustomers();
  Future<ExportFileEntity> exportSales();
  Future<ExportFileEntity> exportCustomerLedger(String customerId);
}

class ExportRemoteDataSourceImpl implements ExportRemoteDataSource {
  final ApiClient apiClient;

  ExportRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ExportFileEntity> exportInventory() async {
    developer.log(
      '📥 [ExportRemoteDataSource] exportInventory() requesting ${ApiEndpoints.exportInventory}',
      name: 'ExportRemoteDataSource',
    );
    try {
      final csvContent = await apiClient.getCsv(ApiEndpoints.exportInventory);

      developer.log(
        '✅ [ExportRemoteDataSource] exportInventory() success. Received ${csvContent.length} bytes CSV.',
        name: 'ExportRemoteDataSource',
      );

      return ExportFileEntity(
        fileName: 'inventory_export.csv',
        csvContent: csvContent,
        fileType: 'csv',
        exportedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ [ExportRemoteDataSource] exportInventory() API Error: $e',
        name: 'ExportRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<ExportFileEntity> exportCustomers() async {
    developer.log(
      '📥 [ExportRemoteDataSource] exportCustomers() requesting ${ApiEndpoints.exportCustomers}',
      name: 'ExportRemoteDataSource',
    );
    try {
      final csvContent = await apiClient.getCsv(ApiEndpoints.exportCustomers);

      developer.log(
        '✅ [ExportRemoteDataSource] exportCustomers() success. Received ${csvContent.length} bytes CSV.',
        name: 'ExportRemoteDataSource',
      );

      return ExportFileEntity(
        fileName: 'customers_export.csv',
        csvContent: csvContent,
        fileType: 'csv',
        exportedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ [ExportRemoteDataSource] exportCustomers() API Error: $e',
        name: 'ExportRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<ExportFileEntity> exportSales() async {
    developer.log(
      '📥 [ExportRemoteDataSource] exportSales() requesting ${ApiEndpoints.exportSales}',
      name: 'ExportRemoteDataSource',
    );
    try {
      final csvContent = await apiClient.getCsv(ApiEndpoints.exportSales);

      developer.log(
        '✅ [ExportRemoteDataSource] exportSales() success. Received ${csvContent.length} bytes CSV.',
        name: 'ExportRemoteDataSource',
      );

      return ExportFileEntity(
        fileName: 'sales_export.csv',
        csvContent: csvContent,
        fileType: 'csv',
        exportedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ [ExportRemoteDataSource] exportSales() API Error: $e',
        name: 'ExportRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<ExportFileEntity> exportCustomerLedger(String customerId) async {
    final endpoint = ApiEndpoints.exportCustomerLedger(customerId);
    developer.log(
      '📥 [ExportRemoteDataSource] exportCustomerLedger() customerId: "$customerId", endpoint: "$endpoint"',
      name: 'ExportRemoteDataSource',
    );
    try {
      final csvContent = await apiClient.getCsv(endpoint);

      developer.log(
        '✅ [ExportRemoteDataSource] exportCustomerLedger() success for customerId "$customerId". Received ${csvContent.length} bytes CSV.',
        name: 'ExportRemoteDataSource',
      );

      return ExportFileEntity(
        fileName: 'customer_ledger_export.csv',
        csvContent: csvContent,
        fileType: 'csv',
        exportedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ [ExportRemoteDataSource] exportCustomerLedger() API Error for customerId "$customerId": $e',
        name: 'ExportRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
