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
  final bool isListLoading;

  const StaffLoadedState({
    required this.staffMembers,
    required this.filteredStaff,
    required this.searchQuery,
    this.isListLoading = false,
  });
}

class StaffOperationSuccessState extends StaffState {
  final String message;

  const StaffOperationSuccessState(this.message);
}

class StaffErrorState extends StaffState {
  final String message;
  final List<StaffEntity> previousStaff;

  const StaffErrorState(this.message, {this.previousStaff = const []});
}
