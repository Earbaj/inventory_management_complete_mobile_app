import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

/// UseCase: Fetches list of shop staff members.
class GetStaffMembersUseCase {
  final StaffRepository repository;

  const GetStaffMembersUseCase(this.repository);

  Future<List<StaffEntity>> call() {
    return repository.getStaffMembers();
  }
}
