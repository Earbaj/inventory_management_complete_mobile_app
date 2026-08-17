import '../../domain/entities/return_item_entity.dart';

abstract class ReturnsState {
  const ReturnsState();
}

class ReturnsInitialState extends ReturnsState {
  const ReturnsInitialState();
}

class ReturnsLoadingState extends ReturnsState {
  const ReturnsLoadingState();
}

class ReturnsLoadedState extends ReturnsState {
  final List<ReturnItemEntity> returnLogs;
  final List<ReturnItemEntity> filteredLogs;
  final String searchQuery;

  const ReturnsLoadedState({
    required this.returnLogs,
    required this.filteredLogs,
    required this.searchQuery,
  });

  double get totalRefundedAmount => returnLogs.fold(0.0, (sum, item) => sum + item.totalRefundAmount);
}

class ReturnsOperationSuccessState extends ReturnsState {
  final String message;

  const ReturnsOperationSuccessState(this.message);
}

class ReturnsErrorState extends ReturnsState {
  final String message;

  const ReturnsErrorState(this.message);
}
