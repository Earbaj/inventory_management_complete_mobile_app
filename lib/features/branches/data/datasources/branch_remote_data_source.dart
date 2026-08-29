import 'dart:developer' as developer;
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/branch_model.dart';

abstract class BranchRemoteDataSource {
  Future<List<BranchModel>> getBranches({bool forceRefresh = false});
  Future<BranchModel> createBranch({
    required String name,
    required String address,
    required String phone,
  });
}

class BranchRemoteDataSourceImpl implements BranchRemoteDataSource {
  final ApiClient apiClient;

  BranchRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<BranchModel>> getBranches({bool forceRefresh = false}) async {
    developer.log('🏢 [BranchRemoteDataSource] getBranches(forceRefresh: $forceRefresh) calling GET ${ApiEndpoints.branches}...', name: 'BranchRemoteDataSource');
    try {
      final response = await apiClient.get(
        ApiEndpoints.branches,
        cache: true,
        cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.forceCache,
        maxStale: const Duration(minutes: 30),
      );

      final List list = response is List
          ? response
          : (response['branches'] ?? response['data'] ?? []);

      developer.log('✅ [BranchRemoteDataSource] getBranches() success. Parsed ${list.length} branches.', name: 'BranchRemoteDataSource');
      return list.map((json) => BranchModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      developer.log('⚠️ [BranchRemoteDataSource] getBranches() API Error: $e', name: 'BranchRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<BranchModel> createBranch({
    required String name,
    required String address,
    required String phone,
  }) async {
    developer.log('🏢 [BranchRemoteDataSource] createBranch() calling POST ${ApiEndpoints.branches} (name: "$name")...', name: 'BranchRemoteDataSource');
    try {
      final response = await apiClient.post(
        ApiEndpoints.branches,
        body: {
          'name': name,
          'address': address,
          'phone': phone,
        },
      );

      developer.log('✅ [BranchRemoteDataSource] createBranch() success.', name: 'BranchRemoteDataSource');
      final Map<String, dynamic> data = response is Map<String, dynamic>
          ? (response['branch'] ?? response['data'] ?? response) as Map<String, dynamic>
          : <String, dynamic>{};
      final createdBranch = BranchModel.fromJson(data);

      // Force refresh cache to invalidate previous stale cache and store updated branch list
      try {
        await getBranches(forceRefresh: true);
      } catch (_) {}

      return createdBranch;
    } catch (e) {
      developer.log('⚠️ [BranchRemoteDataSource] createBranch() API Error: $e', name: 'BranchRemoteDataSource');
      rethrow;
    }
  }
}
