import '../../domain/entities/staff_entity.dart';

abstract class StaffState {
  const StaffState();
}

class StaffInitialState extends StaffState {
  const StaffInitialState();
}

class StaffLoadingState extends StaffState {
  const StaffLoadingState();
}

class StaffLoadedState extends StaffState {
  final List<StaffEntity> staffMembers;
  final List<StaffEntity> filteredStaff;
  final String searchQuery;

  const StaffLoadedState({
    required this.staffMembers,
    required this.filteredStaff,
    required this.searchQuery,
  });
}

class StaffOperationSuccessState extends StaffState {
  final String message;

  const StaffOperationSuccessState(this.message);
}

class StaffErrorState extends StaffState {
  final String message;

  const StaffErrorState(this.message);
}
