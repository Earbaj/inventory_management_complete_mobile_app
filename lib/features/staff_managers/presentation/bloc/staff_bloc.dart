import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/staff_entity.dart';
import '../../domain/usecases/add_staff_member_usecase.dart';
import '../../domain/usecases/delete_staff_member_usecase.dart';
import '../../domain/usecases/get_staff_members_usecase.dart';
import '../../domain/usecases/update_staff_member_usecase.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final GetStaffMembersUseCase getStaffMembersUseCase;
  final AddStaffMemberUseCase addStaffMemberUseCase;
  final UpdateStaffMemberUseCase updateStaffMemberUseCase;
  final DeleteStaffMemberUseCase deleteStaffMemberUseCase;

  List<StaffEntity> _allStaffMembers = [];
  String _currentSearchQuery = '';

  StaffBloc({
    required this.getStaffMembersUseCase,
    required this.addStaffMemberUseCase,
    required this.updateStaffMemberUseCase,
    required this.deleteStaffMemberUseCase,
  }) : super(const StaffInitialState()) {
    // Event Handlers Registration
    on<FetchStaffEvent>(_onFetchStaff);
    on<AddStaffEvent>(_onAddStaff);
    on<UpdateStaffEvent>(_onUpdateStaff);
    on<DeleteStaffEvent>(_onDeleteStaff);
  }

  Future<void> _onFetchStaff(
      FetchStaffEvent event,
      Emitter<StaffState> emit,
      ) async {
    _currentSearchQuery = event.searchQuery ?? _currentSearchQuery;

    if (_allStaffMembers.isEmpty) {
      emit(const StaffLoadingState());
    } else {
      _emitLoadedState(emit, isListLoading: true);
    }

    try {
      _allStaffMembers = await getStaffMembersUseCase();
      _emitLoadedState(emit, isListLoading: false);
    } catch (e) {
      emit(StaffErrorState(e.toString(), previousStaff: _allStaffMembers));
    }
  }

  Future<void> _onAddStaff(
      AddStaffEvent event,
      Emitter<StaffState> emit,
      ) async {
    try {
      final staff = event.staff;
      final savedStaff =
      staff.id.isNotEmpty ? staff : await addStaffMemberUseCase(staff);
      final exists = _allStaffMembers.any((s) =>
      (s.id.isNotEmpty && s.id == savedStaff.id) ||
          (s.email.isNotEmpty && s.email == savedStaff.email));

      if (!exists) {
        _allStaffMembers.insert(0, savedStaff);
      } else {
        final index = _allStaffMembers.indexWhere((s) => s.id == savedStaff.id);
        if (index != -1) _allStaffMembers[index] = savedStaff;
      }

      emit(const StaffOperationSuccessState('Staff member added successfully!'));
      _emitLoadedState(emit);
    } catch (e) {
      emit(StaffErrorState(e.toString(), previousStaff: _allStaffMembers));
    }
  }

  Future<void> _onUpdateStaff(
      UpdateStaffEvent event,
      Emitter<StaffState> emit,
      ) async {
    try {
      final updatedStaff = await updateStaffMemberUseCase(event.staff);
      final index =
      _allStaffMembers.indexWhere((s) => s.id == updatedStaff.id);
      if (index != -1) {
        _allStaffMembers[index] = updatedStaff;
      }

      emit(const StaffOperationSuccessState('Staff details updated successfully!'));
      _emitLoadedState(emit);
    } catch (e) {
      emit(StaffErrorState(e.toString(), previousStaff: _allStaffMembers));
    }
  }

  Future<void> _onDeleteStaff(
      DeleteStaffEvent event,
      Emitter<StaffState> emit,
      ) async {
    try {
      await deleteStaffMemberUseCase(event.staffId);
      _allStaffMembers.removeWhere((s) => s.id == event.staffId);

      emit(const StaffOperationSuccessState('Staff member deleted successfully!'));
      _emitLoadedState(emit);
    } catch (e) {
      emit(StaffErrorState(e.toString(), previousStaff: _allStaffMembers));
    }
  }

  void _emitLoadedState(Emitter<StaffState> emit, {bool isListLoading = false}) {
    final query = _currentSearchQuery.trim().toLowerCase();
    final filtered = _allStaffMembers.where((staff) {
      final matchesSearch = query.isEmpty ||
          staff.name.toLowerCase().contains(query) ||
          staff.email.toLowerCase().contains(query) ||
          staff.phone.contains(query) ||
          staff.role.toLowerCase().contains(query);

      return matchesSearch;
    }).toList();

    emit(StaffLoadedState(
      staffMembers: _allStaffMembers,
      filteredStaff: filtered,
      searchQuery: _currentSearchQuery,
      isListLoading: isListLoading,
    ));
  }
}