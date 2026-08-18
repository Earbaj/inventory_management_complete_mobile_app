import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/staff_model.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffModel>> getStaffMembers({
    int page = 1,
    int limit = 20,
    String? search,
  });
  Future<StaffModel> addStaffMember(StaffModel staffModel);
  Future<StaffModel> updateStaffMember(StaffModel staffModel);
  Future<StaffModel> updateStaffPermissions(String staffId, StaffPermissions permissions);
  Future<void> deleteStaffMember(String staffId);
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final ApiClient apiClient;

  StaffRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<StaffModel>> getStaffMembers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    developer.log(
      '👥 [StaffRemoteDataSource] getStaffMembers() calling GET ${ApiEndpoints.staff} (page: $page, limit: $limit, search: "$search")...',
      name: 'StaffRemoteDataSource',
    );
    try {
      final response = await apiClient.get(
        ApiEndpoints.staff,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      );

      final List list = response is List
          ? response
          : (response['data'] ?? response['staff'] ?? response['users'] ?? response['items'] ?? []);

      developer.log(
        '✅ [StaffRemoteDataSource] getStaffMembers() success. Parsed ${list.length} staff members.',
        name: 'StaffRemoteDataSource',
      );
      return list.map((json) => StaffModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log(
        '❌ [StaffRemoteDataSource] getStaffMembers() API Error: $e',
        name: 'StaffRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<StaffModel> addStaffMember(StaffModel staffModel) async {
    developer.log(
      '👥 [StaffRemoteDataSource] addStaffMember() calling POST ${ApiEndpoints.staff} for name: "${staffModel.name}"',
      name: 'StaffRemoteDataSource',
    );
    try {
      final response = await apiClient.post(
        ApiEndpoints.staff,
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
    developer.log(
      '👥 [StaffRemoteDataSource] updateStaffMember() calling PATCH ${ApiEndpoints.staffPermissions(staffModel.id)}',
      name: 'StaffRemoteDataSource',
    );
    try {
      final response = await apiClient.patch(
        ApiEndpoints.staffPermissions(staffModel.id),
        body: {
          'permissions': staffModel.permissions.toJson(),
        },
      );

      developer.log('✅ [StaffRemoteDataSource] updateStaffMember() success.', name: 'StaffRemoteDataSource');
      return StaffModel.fromJson(response is Map<String, dynamic> ? response : staffModel.toJson());
    } catch (e, stackTrace) {
      developer.log('❌ [StaffRemoteDataSource] updateStaffMember() API Error: $e', name: 'StaffRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<StaffModel> updateStaffPermissions(String staffId, StaffPermissions permissions) async {
    developer.log(
      '👥 [StaffRemoteDataSource] updateStaffPermissions() calling PATCH ${ApiEndpoints.staffPermissions(staffId)}',
      name: 'StaffRemoteDataSource',
    );
    try {
      final response = await apiClient.patch(
        ApiEndpoints.staffPermissions(staffId),
        body: {
          'permissions': permissions.toJson(),
        },
      );

      developer.log('✅ [StaffRemoteDataSource] updateStaffPermissions() success.', name: 'StaffRemoteDataSource');
      return StaffModel.fromJson(response is Map<String, dynamic> ? response : {});
    } catch (e, stackTrace) {
      developer.log('❌ [StaffRemoteDataSource] updateStaffPermissions() API Error: $e', name: 'StaffRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteStaffMember(String staffId) async {
    developer.log(
      '👥 [StaffRemoteDataSource] deleteStaffMember() calling DELETE ${ApiEndpoints.staffById(staffId)}',
      name: 'StaffRemoteDataSource',
    );
    try {
      await apiClient.delete(
        ApiEndpoints.staffById(staffId),
      );
      developer.log('✅ [StaffRemoteDataSource] deleteStaffMember() success.', name: 'StaffRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [StaffRemoteDataSource] deleteStaffMember() API Error: $e', name: 'StaffRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
