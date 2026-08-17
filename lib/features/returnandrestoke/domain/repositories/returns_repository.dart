import '../entities/return_item_entity.dart';

/// Abstract Returns Repository Interface Contract
abstract class ReturnsRepository {
  /// Submits return item transaction & updates stock (POST /api/returns).
  Future<ReturnItemEntity> processReturn(ReturnItemEntity returnEntity);

  /// Fetches history logs of past return transactions (GET /api/returns).
  Future<List<ReturnItemEntity>> getReturnLogs();
}
