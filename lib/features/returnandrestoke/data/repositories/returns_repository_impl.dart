import '../../../../core/error/failures.dart';
import '../../domain/entities/return_item_entity.dart';
import '../../domain/repositories/returns_repository.dart';
import '../datasources/returns_local_data_source.dart';
import '../datasources/returns_remote_data_source.dart';
import '../mappers/returns_mapper.dart';

class ReturnsRepositoryImpl implements ReturnsRepository {
  final ReturnsRemoteDataSource remoteDataSource;
  final ReturnsLocalDataSource localDataSource;

  ReturnsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<ReturnItemEntity> processReturn(ReturnItemEntity returnEntity) async {
    final modelToSave = ReturnsMapper.entityToModel(returnEntity);
    try {
      final savedModel = await remoteDataSource.processReturn(modelToSave);
      final currentCache = await localDataSource.getCachedReturnLogs();
      await localDataSource.cacheReturnLogs([savedModel, ...currentCache]);
      return ReturnsMapper.modelToEntity(savedModel);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to process item return. Please try again.');
    }
  }

  @override
  Future<List<ReturnItemEntity>> getReturnLogs() async {
    try {
      final remoteModels = await remoteDataSource.getReturnLogs();
      await localDataSource.cacheReturnLogs(remoteModels);
      return remoteModels.map(ReturnsMapper.modelToEntity).toList();
    } catch (_) {
      final cachedModels = await localDataSource.getCachedReturnLogs();
      if (cachedModels.isEmpty) {
        throw const ServerFailure('Something went wrong. Could not load return logs.');
      }
      return cachedModels.map(ReturnsMapper.modelToEntity).toList();
    }
  }
}
