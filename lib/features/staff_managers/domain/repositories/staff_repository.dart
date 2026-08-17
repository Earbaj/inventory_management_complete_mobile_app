import '../entities/staff_entity.dart';

/// Abstract Staff Repository Interface Contract
abstract class StaffRepository {
  /// Fetches list of shop staff members (GET /api/staff).
  Future<List<StaffEntity>> getStaffMembers();

  /// Adds a new staff member (POST /api/staff).
  Future<StaffEntity> addStaffMember(StaffEntity staff);

  /// Updates an existing staff member's role/status (PUT /api/staff/:id).
  Future<StaffEntity> updateStaffMember(StaffEntity staff);

  /// Deletes a staff member (DELETE /api/staff/:id).
  Future<void> deleteStaffMember(String staffId);
}
