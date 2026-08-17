import '../../../../core/error/failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_data_source.dart';
import '../datasources/customer_remote_data_source.dart';
import '../mappers/customer_mapper.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;
  final CustomerLocalDataSource localDataSource;

  CustomerRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<CustomerEntity>> getCustomers({String? searchQuery}) async {
    try {
      final remoteModels = await remoteDataSource.getCustomers(search: searchQuery);
      await localDataSource.cacheCustomers(remoteModels);
      return remoteModels.map(CustomerMapper.modelToEntity).toList();
    } catch (_) {
      // API hit failed -> Try fallback to local cache
      final cachedModels = await localDataSource.getCachedCustomers();

      // If cache expired (> 5 mins) or empty -> Throw Failure to show UI Error Widget
      if (cachedModels.isEmpty) {
        throw const ServerFailure('Something went wrong. Could not load customers data.');
      }

      var filtered = cachedModels;
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        filtered = filtered.where((customer) =>
            customer.name.toLowerCase().contains(q) ||
            customer.phone.contains(q)).toList();
      }

      return filtered.map(CustomerMapper.modelToEntity).toList();
    }
  }

  @override
  Future<CustomerEntity> addCustomer(CustomerEntity customer) async {
    final modelToSave = CustomerMapper.entityToModel(customer);
    try {
      final savedModel = await remoteDataSource.addCustomer(modelToSave);
      final currentCache = await localDataSource.getCachedCustomers();
      await localDataSource.cacheCustomers([savedModel, ...currentCache]);
      return CustomerMapper.modelToEntity(savedModel);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to add customer. Please try again.');
    }
  }

  @override
  Future<CustomerEntity> updateCustomer(CustomerEntity customer) async {
    final modelToUpdate = CustomerMapper.entityToModel(customer);
    try {
      final updatedModel = await remoteDataSource.updateCustomer(modelToUpdate);
      final currentCache = await localDataSource.getCachedCustomers();
      final index = currentCache.indexWhere((el) => el.id == customer.id);
      if (index != -1) {
        currentCache[index] = updatedModel;
        await localDataSource.cacheCustomers(currentCache);
      }
      return CustomerMapper.modelToEntity(updatedModel);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to update customer. Please try again.');
    }
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    try {
      await remoteDataSource.deleteCustomer(customerId);
      final currentCache = await localDataSource.getCachedCustomers();
      currentCache.removeWhere((el) => el.id == customerId);
      await localDataSource.cacheCustomers(currentCache);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to delete customer. Please try again.');
    }
  }
}
