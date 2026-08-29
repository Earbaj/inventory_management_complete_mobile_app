import '../../domain/entities/branch_entity.dart';

abstract class BranchState {
  const BranchState();
}

class BranchInitialState extends BranchState {
  const BranchInitialState();
}

class BranchLoadingState extends BranchState {
  const BranchLoadingState();
}

class BranchLoadedState extends BranchState {
  final List<BranchEntity> branches;
  final bool isListLoading;

  const BranchLoadedState({
    required this.branches,
    this.isListLoading = false,
  });
}

class BranchOperationSuccessState extends BranchState {
  final String message;

  const BranchOperationSuccessState(this.message);
}

class BranchErrorState extends BranchState {
  final String message;
  final List<BranchEntity> previousBranches;

  const BranchErrorState(this.message, {this.previousBranches = const []});
}
