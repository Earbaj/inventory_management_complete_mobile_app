import 'dart:async';
import '../../domain/entities/staff_entity.dart';
import '../../domain/usecases/add_staff_member_usecase.dart';
import '../../domain/usecases/delete_staff_member_usecase.dart';
import '../../domain/usecases/get_staff_members_usecase.dart';
import '../../domain/usecases/update_staff_member_usecase.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc {
  final GetStaffMembersUseCase getStaffMembersUseCase;
  final AddStaffMemberUseCase addStaffMemberUseCase;
  final UpdateStaffMemberUseCase updateStaffMemberUseCase;
  final DeleteStaffMemberUseCase deleteStaffMemberUseCase;

  StaffState _state = const StaffInitialState();
  final _stateController = StreamController<StaffState>.broadcast();

  List<StaffEntity> _allStaffMembers = [];
  String _currentSearchQuery = '';

  StaffState get state => _state;
  Stream<StaffState> get stream => _stateController.stream;

  StaffBloc({
    required this.getStaffMembersUseCase,
    required this.addStaffMemberUseCase,
    required this.updateStaffMemberUseCase,
    required this.deleteStaffMemberUseCase,
  });

  void add(StaffEvent event) {
    _handleEvent(event);
  }

  void _emit(StaffState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _handleEvent(StaffEvent event) async {
    if (event is FetchStaffEvent) {
      await _onFetchStaff(event);
    } else if (event is AddStaffEvent) {
      await _onAddStaff(event);
    } else if (event is UpdateStaffEvent) {
      await _onUpdateStaff(event);
    } else if (event is DeleteStaffEvent) {
      await _onDeleteStaff(event);
    }
  }

  Future<void> _onFetchStaff(FetchStaffEvent event) async {
    _currentSearchQuery = event.searchQuery ?? _currentSearchQuery;

    if (_allStaffMembers.isEmpty) {
      _emit(const StaffLoadingState());
    }

    try {
      _allStaffMembers = await getStaffMembersUseCase();
      _emitLoadedState();
    } catch (e) {
      _emit(StaffErrorState(e.toString()));
    }
  }

  Future<void> _onAddStaff(AddStaffEvent event) async {
    try {
      final staff = event.staff;
      final savedStaff = staff.id.isNotEmpty ? staff : await addStaffMemberUseCase(staff);
      final exists = _allStaffMembers.any((s) => (s.id.isNotEmpty && s.id == savedStaff.id) || (s.email.isNotEmpty && s.email == savedStaff.email));
      if (!exists) {
        _allStaffMembers.insert(0, savedStaff);
      } else {
        final index = _allStaffMembers.indexWhere((s) => s.id == savedStaff.id);
        if (index != -1) _allStaffMembers[index] = savedStaff;
      }
      _emit(const StaffOperationSuccessState('Staff member added successfully!'));
      _emitLoadedState();
    } catch (e) {
      _emit(StaffErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateStaff(UpdateStaffEvent event) async {
    try {
      final updatedStaff = await updateStaffMemberUseCase(event.staff);
      final index = _allStaffMembers.indexWhere((s) => s.id == updatedStaff.id);
      if (index != -1) {
        _allStaffMembers[index] = updatedStaff;
      }
      _emit(const StaffOperationSuccessState('Staff details updated successfully!'));
      _emitLoadedState();
    } catch (e) {
      _emit(StaffErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteStaff(DeleteStaffEvent event) async {
    try {
      await deleteStaffMemberUseCase(event.staffId);
      _allStaffMembers.removeWhere((s) => s.id == event.staffId);
      _emit(const StaffOperationSuccessState('Staff member deleted successfully!'));
      _emitLoadedState();
    } catch (e) {
      _emit(StaffErrorState(e.toString()));
    }
  }

  void _emitLoadedState() {
    final query = _currentSearchQuery.trim().toLowerCase();
    final filtered = _allStaffMembers.where((staff) {
      final matchesSearch = query.isEmpty ||
          staff.name.toLowerCase().contains(query) ||
          staff.email.toLowerCase().contains(query) ||
          staff.phone.contains(query) ||
          staff.role.toLowerCase().contains(query);

      return matchesSearch;
    }).toList();

    _emit(StaffLoadedState(
      staffMembers: _allStaffMembers,
      filteredStaff: filtered,
      searchQuery: _currentSearchQuery,
    ));
  }

  void dispose() {
    _stateController.close();
  }
}
