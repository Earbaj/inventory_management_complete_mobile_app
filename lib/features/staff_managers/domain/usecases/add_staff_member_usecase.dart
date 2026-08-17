import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

/// UseCase: Adds a new staff member.
class AddStaffMemberUseCase {
  final StaffRepository repository;

  const AddStaffMemberUseCase(this.repository);

  Future<StaffEntity> call(StaffEntity staff) {
    return repository.addStaffMember(staff);
  }
}
