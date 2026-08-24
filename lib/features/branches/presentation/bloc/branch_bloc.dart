import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/branch_entity.dart';
import '../../domain/usecases/create_branch_usecase.dart';
import '../../domain/usecases/get_branches_usecase.dart';
import 'branch_event.dart';
import 'branch_state.dart';

class BranchBloc extends Bloc<BranchEvent, BranchState> {
  final GetBranchesUseCase getBranchesUseCase;
  final CreateBranchUseCase createBranchUseCase;

  List<BranchEntity> _branches = [];

  BranchBloc({
    required this.getBranchesUseCase,
    required this.createBranchUseCase,
  }) : super(const BranchInitialState()) {
    on<FetchBranchesEvent>(_onFetchBranches);
    on<CreateBranchEvent>(_onCreateBranch);
  }

  List<BranchEntity> get branches => List.unmodifiable(_branches);

  Future<void> _onFetchBranches(
    FetchBranchesEvent event,
    Emitter<BranchState> emit,
  ) async {
    emit(const BranchLoadingState());
    try {
      _branches = await getBranchesUseCase();
      emit(BranchLoadedState(branches: List.from(_branches)));
    } catch (e) {
      emit(BranchErrorState(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
    }
  }

  Future<void> _onCreateBranch(
    CreateBranchEvent event,
    Emitter<BranchState> emit,
  ) async {
    try {
      final newBranch = await createBranchUseCase(
        name: event.name,
        address: event.address,
        phone: event.phone,
      );
      _branches.add(newBranch);
      emit(BranchOperationSuccessState('Branch "${newBranch.name}" created successfully!'));
      emit(BranchLoadedState(branches: List.from(_branches)));
    } catch (e) {
      emit(BranchErrorState(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
    }
  }
}
