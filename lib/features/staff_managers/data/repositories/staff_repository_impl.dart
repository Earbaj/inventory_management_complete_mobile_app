import '../../../../core/error/failures.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_local_data_source.dart';
import '../datasources/staff_remote_data_source.dart';
import '../mappers/staff_mapper.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remoteDataSource;
  final StaffLocalDataSource localDataSource;

  StaffRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<StaffEntity>> getStaffMembers() async {
    try {
      final remoteModels = await remoteDataSource.getStaffMembers();
      await localDataSource.cacheStaffMembers(remoteModels);
      return remoteModels.map(StaffMapper.modelToEntity).toList();
    } catch (_) {
      final cachedModels = await localDataSource.getCachedStaffMembers();
      if (cachedModels.isEmpty) {
        throw const ServerFailure('Something went wrong. Could not load staff list.');
      }
      return cachedModels.map(StaffMapper.modelToEntity).toList();
    }
  }

  @override
  Future<StaffEntity> addStaffMember(StaffEntity staff) async {
    final modelToSave = StaffMapper.entityToModel(staff);
    try {
      final savedModel = await remoteDataSource.addStaffMember(modelToSave);
      final currentCache = await localDataSource.getCachedStaffMembers();
      await localDataSource.cacheStaffMembers([savedModel, ...currentCache]);
      return StaffMapper.modelToEntity(savedModel);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to add staff member. Please try again.');
    }
  }

  @override
  Future<StaffEntity> updateStaffMember(StaffEntity staff) async {
    final modelToUpdate = StaffMapper.entityToModel(staff);
    try {
      final updatedModel = await remoteDataSource.updateStaffMember(modelToUpdate);
      final currentCache = await localDataSource.getCachedStaffMembers();
      final index = currentCache.indexWhere((s) => s.id == updatedModel.id);
      if (index != -1) {
        currentCache[index] = updatedModel;
        await localDataSource.cacheStaffMembers(currentCache);
      }
      return StaffMapper.modelToEntity(updatedModel);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to update staff member. Please try again.');
    }
  }

  @override
  Future<void> deleteStaffMember(String staffId) async {
    try {
      await remoteDataSource.deleteStaffMember(staffId);
      final currentCache = await localDataSource.getCachedStaffMembers();
      currentCache.removeWhere((s) => s.id == staffId);
      await localDataSource.cacheStaffMembers(currentCache);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to delete staff member. Please try again.');
    }
  }
}
