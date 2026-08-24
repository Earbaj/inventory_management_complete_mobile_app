import '../../../../core/error/failures.dart';
import '../../domain/entities/export_file_entity.dart';
import '../../domain/repositories/export_repository.dart';
import '../datasources/export_remote_data_source.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportRemoteDataSource remoteDataSource;

  ExportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ExportFileEntity> exportInventory() async {
    try {
      return await remoteDataSource.exportInventory();
    } catch (e) {
      throw ServerFailure(e is Failure ? e.message : e.toString());
    }
  }

  @override
  Future<ExportFileEntity> exportCustomers() async {
    try {
      return await remoteDataSource.exportCustomers();
    } catch (e) {
      throw ServerFailure(e is Failure ? e.message : e.toString());
    }
  }

  @override
  Future<ExportFileEntity> exportSales() async {
    try {
      return await remoteDataSource.exportSales();
    } catch (e) {
      throw ServerFailure(e is Failure ? e.message : e.toString());
    }
  }

  @override
  Future<ExportFileEntity> exportCustomerLedger(String customerId) async {
    try {
      return await remoteDataSource.exportCustomerLedger(customerId);
    } catch (e) {
      throw ServerFailure(e is Failure ? e.message : e.toString());
    }
  }
}
