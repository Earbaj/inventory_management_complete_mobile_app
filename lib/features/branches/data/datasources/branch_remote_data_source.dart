import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/branch_model.dart';

abstract class BranchRemoteDataSource {
  Future<List<BranchModel>> getBranches();
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
  Future<List<BranchModel>> getBranches() async {
    developer.log('🏢 [BranchRemoteDataSource] getBranches() calling GET ${ApiEndpoints.branches}...', name: 'BranchRemoteDataSource');
    try {
      final response = await apiClient.get(ApiEndpoints.branches);

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
      return BranchModel.fromJson(response is Map<String, dynamic> ? response : {});
    } catch (e) {
      developer.log('⚠️ [BranchRemoteDataSource] createBranch() API Error: $e', name: 'BranchRemoteDataSource');
      rethrow;
    }
  }
}
