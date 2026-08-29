import '../entities/pagination_meta_entity.dart';

/// Repository interface contract for Recycle Bin & Data Recovery operations.
abstract class RecycleBinRepository {
  /// Fetches soft-deleted items with pagination metadata (GET /api/trash).
  Future<PaginatedTrashEntity> getTrashItems({
    String? entityType,
    String? search,
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  });

  /// Restores soft-deleted item back to active database list (POST /api/trash/restore/:entityType/:id).
  Future<void> restoreItem({
    required String entityType,
    required String id,
  });

  /// Permanently hard-deletes record from MongoDB (DELETE /api/trash/permanent/:entityType/:id).
  Future<void> permanentDeleteItem({
    required String entityType,
    required String id,
  });
}
