import '../../../../core/error/failures.dart';
import '../../domain/entities/trash_item_entity.dart';
import '../../domain/repositories/recycle_bin_repository.dart';
import '../datasources/recycle_bin_remote_data_source.dart';

class RecycleBinRepositoryImpl implements RecycleBinRepository {
  final RecycleBinRemoteDataSource remoteDataSource;

  RecycleBinRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TrashItemEntity>> getTrashItems({
    String? entityType,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final models = await remoteDataSource.getTrashItems(
        entityType: entityType,
        search: search,
        page: page,
        limit: limit,
      );
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<void> restoreItem({
    required String entityType,
    required String id,
  }) async {
    try {
      await remoteDataSource.restoreItem(entityType, id);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<void> permanentDeleteItem({
    required String entityType,
    required String id,
  }) async {
    try {
      await remoteDataSource.permanentDeleteItem(entityType, id);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure(e.toString());
    }
  }
}
