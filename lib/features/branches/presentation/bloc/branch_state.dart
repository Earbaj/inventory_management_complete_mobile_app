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

  const BranchLoadedState({
    required this.branches,
  });
}

class BranchOperationSuccessState extends BranchState {
  final String message;

  const BranchOperationSuccessState(this.message);
}

class BranchErrorState extends BranchState {
  final String message;

  const BranchErrorState(this.message);
}
