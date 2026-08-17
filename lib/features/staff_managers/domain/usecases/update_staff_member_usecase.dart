import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

/// UseCase: Updates a staff member's role or status.
class UpdateStaffMemberUseCase {
  final StaffRepository repository;

  const UpdateStaffMemberUseCase(this.repository);

  Future<StaffEntity> call(StaffEntity staff) {
    return repository.updateStaffMember(staff);
  }
}
