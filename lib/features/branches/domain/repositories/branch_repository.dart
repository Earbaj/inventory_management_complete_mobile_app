import '../entities/branch_entity.dart';

/// Repository interface contract for Branch Management operations.
abstract class BranchRepository {
  /// Fetches registered branches list for current shop (GET /api/branches).
  Future<List<BranchEntity>> getBranches({bool forceRefresh = false});

  /// Creates a new shop branch (POST /api/branches).
  Future<BranchEntity> createBranch({
    required String name,
    required String address,
    required String phone,
  });
}
