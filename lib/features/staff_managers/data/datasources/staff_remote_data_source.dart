import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/config/env_config.dart';
import '../models/staff_model.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffModel>> getStaffMembers({int page = 1, int limit = 20});
  Future<StaffModel> addStaffMember(StaffModel staffModel);
  Future<StaffModel> updateStaffMember(StaffModel staffModel);
  Future<void> deleteStaffMember(String staffId);
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final ApiClient apiClient;

  StaffRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<StaffModel>> getStaffMembers({int page = 1, int limit = 20}) async {
    developer.log('👥 [StaffRemoteDataSource] getStaffMembers() page: $page, limit: $limit...', name: 'StaffRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/staff',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List list = response is List ? response : (response['staff'] ?? response['data'] ?? []);
      developer.log('✅ [StaffRemoteDataSource] getStaffMembers() success. Parsed ${list.length} staff members.', name: 'StaffRemoteDataSource');
      return list.map((json) => StaffModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('❌ [StaffRemoteDataSource] getStaffMembers() API Error: $e', name: 'StaffRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<StaffModel> addStaffMember(StaffModel staffModel) async {
    developer.log('👥 [StaffRemoteDataSource] addStaffMember() called for name: "${staffModel.name}" (role: ${staffModel.role})', name: 'StaffRemoteDataSource');
    try {
      final response = await apiClient.post(
        '${EnvConfig.apiBaseUrl}/api/staff',
        body: staffModel.toJson(),
      );

      developer.log('✅ [StaffRemoteDataSource] addStaffMember() success.', name: 'StaffRemoteDataSource');
      return StaffModel.fromJson(response is Map<String, dynamic> ? response : staffModel.toJson());
    } catch (e, stackTrace) {
      developer.log('❌ [StaffRemoteDataSource] addStaffMember() API Error: $e', name: 'StaffRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<StaffModel> updateStaffMember(StaffModel staffModel) async {
    developer.log('👥 [StaffRemoteDataSource] updateStaffMember() called for staffId: "${staffModel.id}"', name: 'StaffRemoteDataSource');
    try {
      final response = await apiClient.put(
        '${EnvConfig.apiBaseUrl}/api/staff/${staffModel.id}',
        body: staffModel.toJson(),
      );

      developer.log('✅ [StaffRemoteDataSource] updateStaffMember() success.', name: 'StaffRemoteDataSource');
      return StaffModel.fromJson(response is Map<String, dynamic> ? response : staffModel.toJson());
    } catch (e, stackTrace) {
      developer.log('❌ [StaffRemoteDataSource] updateStaffMember() API Error: $e', name: 'StaffRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteStaffMember(String staffId) async {
    developer.log('👥 [StaffRemoteDataSource] deleteStaffMember() called for staffId: "$staffId"', name: 'StaffRemoteDataSource');
    try {
      await apiClient.delete(
        '${EnvConfig.apiBaseUrl}/api/staff/$staffId',
      );
      developer.log('✅ [StaffRemoteDataSource] deleteStaffMember() success.', name: 'StaffRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [StaffRemoteDataSource] deleteStaffMember() API Error: $e', name: 'StaffRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
