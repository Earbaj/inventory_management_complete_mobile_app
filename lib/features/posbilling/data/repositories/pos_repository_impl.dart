import '../../../../core/error/failures.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/repositories/pos_repository.dart';
import '../datasources/pos_local_data_source.dart';
import '../datasources/pos_remote_data_source.dart';
import '../mappers/pos_mapper.dart';

class PosRepositoryImpl implements PosRepository {
  final PosRemoteDataSource remoteDataSource;
  final PosLocalDataSource localDataSource;

  PosRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<SaleEntity> createSale(SaleEntity sale) async {
    final modelToSave = PosMapper.saleEntityToModel(sale);
    try {
      final savedModel = await remoteDataSource.createSale(modelToSave);
      final currentCache = await localDataSource.getCachedSales();
      await localDataSource.cacheSales([savedModel, ...currentCache]);
      return PosMapper.saleModelToEntity(savedModel);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to complete sale checkout. Please try again.');
    }
  }

  @override
  Future<List<SaleEntity>> getSalesLogs() async {
    try {
      final remoteModels = await remoteDataSource.getSalesLogs();
      await localDataSource.cacheSales(remoteModels);
      return remoteModels.map(PosMapper.saleModelToEntity).toList();
    } catch (_) {
      final cachedModels = await localDataSource.getCachedSales();
      if (cachedModels.isEmpty) {
        throw const ServerFailure('Something went wrong. Could not load sales logs.');
      }
      return cachedModels.map(PosMapper.saleModelToEntity).toList();
    }
  }
}
