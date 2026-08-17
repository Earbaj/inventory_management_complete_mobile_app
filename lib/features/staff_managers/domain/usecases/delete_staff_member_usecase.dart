import '../repositories/staff_repository.dart';

/// UseCase: Deletes a staff member.
class DeleteStaffMemberUseCase {
  final StaffRepository repository;

  const DeleteStaffMemberUseCase(this.repository);

  Future<void> call(String staffId) {
    return repository.deleteStaffMember(staffId);
  }
}
