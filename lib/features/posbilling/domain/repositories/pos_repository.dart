
import '../entities/sale_entity.dart';

/// Abstract POS Repository Contract
abstract class PosRepository {
  /// Submits checkout sale transaction to backend (POST /api/sales).
  Future<SaleEntity> createSale(SaleEntity sale);

  /// Fetches history logs of past sale transactions (GET /api/sales).
  Future<List<SaleEntity>> getSalesLogs();
}
