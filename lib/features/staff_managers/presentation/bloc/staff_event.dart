import '../../domain/entities/staff_entity.dart';

abstract class StaffEvent {
  const StaffEvent();
}

/// Event: Fetches staff members list.
class FetchStaffEvent extends StaffEvent {
  final String? searchQuery;

  const FetchStaffEvent([this.searchQuery]);
}

/// Event: Adds a new staff member.
class AddStaffEvent extends StaffEvent {
  final StaffEntity staff;

  const AddStaffEvent(this.staff);
}

/// Event: Updates staff member details or role.
class UpdateStaffEvent extends StaffEvent {
  final StaffEntity staff;

  const UpdateStaffEvent(this.staff);
}

/// Event: Deletes a staff member.
class DeleteStaffEvent extends StaffEvent {
  final String staffId;

  const DeleteStaffEvent(this.staffId);
}
