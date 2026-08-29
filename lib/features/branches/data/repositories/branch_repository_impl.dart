import '../../../../core/error/failures.dart';
import '../../domain/entities/branch_entity.dart';
import '../../domain/repositories/branch_repository.dart';
import '../datasources/branch_remote_data_source.dart';

class BranchRepositoryImpl implements BranchRepository {
  final BranchRemoteDataSource remoteDataSource;

  BranchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BranchEntity>> getBranches({bool forceRefresh = false}) async {
    try {
      final models = await remoteDataSource.getBranches(forceRefresh: forceRefresh);
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<BranchEntity> createBranch({
    required String name,
    required String address,
    required String phone,
  }) async {
    try {
      final model = await remoteDataSource.createBranch(
        name: name,
        address: address,
        phone: phone,
      );
      return model.toEntity();
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure(e.toString());
    }
  }
}
