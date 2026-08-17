import '../../../../core/network/api_client.dart';
import '../../../../core/config/env_config.dart';
import '../models/staff_model.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffModel>> getStaffMembers();
  Future<StaffModel> addStaffMember(StaffModel staffModel);
  Future<StaffModel> updateStaffMember(StaffModel staffModel);
  Future<void> deleteStaffMember(String staffId);
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final ApiClient apiClient;

  StaffRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<StaffModel>> getStaffMembers() async {
    final response = await apiClient.get(
      '${EnvConfig.apiBaseUrl}/api/staff',
    );

    final List list = response is List ? response : (response['staff'] ?? response['data'] ?? []);
    return list.map((json) => StaffModel.fromJson(json)).toList();
  }

  @override
  Future<StaffModel> addStaffMember(StaffModel staffModel) async {
    final response = await apiClient.post(
      '${EnvConfig.apiBaseUrl}/api/staff',
      body: staffModel.toJson(),
    );

    return StaffModel.fromJson(response is Map<String, dynamic> ? response : staffModel.toJson());
  }

  @override
  Future<StaffModel> updateStaffMember(StaffModel staffModel) async {
    final response = await apiClient.put(
      '${EnvConfig.apiBaseUrl}/api/staff/${staffModel.id}',
      body: staffModel.toJson(),
    );

    return StaffModel.fromJson(response is Map<String, dynamic> ? response : staffModel.toJson());
  }

  @override
  Future<void> deleteStaffMember(String staffId) async {
    await apiClient.delete(
      '${EnvConfig.apiBaseUrl}/api/staff/$staffId',
    );
  }
}
