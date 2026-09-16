import 'dart:async';
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
  final Completer<void>? completer;

  const AddStaffEvent(this.staff, {this.completer});
}

/// Event: Updates staff member details or role.
class UpdateStaffEvent extends StaffEvent {
  final StaffEntity staff;
  final Completer<void>? completer;

  const UpdateStaffEvent(this.staff, {this.completer});
}

/// Event: Deletes a staff member.
class DeleteStaffEvent extends StaffEvent {
  final String staffId;
  final Completer<void>? completer;

  const DeleteStaffEvent(this.staffId, {this.completer});
}
