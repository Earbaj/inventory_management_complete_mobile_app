import 'package:equatable/equatable.dart';
import '../../../recycle_bin/domain/entities/pagination_meta_entity.dart';
import '../../domain/entities/expense_entity.dart';

abstract class ExpensesState extends Equatable {
  const ExpensesState();

  @override
  List<Object?> get props => [];
}

class ExpensesInitialState extends ExpensesState {
  const ExpensesInitialState();
}

class ExpensesLoadingState extends ExpensesState {
  const ExpensesLoadingState();
}

class ExpensesLoadedState extends ExpensesState {
  final List<ExpenseEntity> expenses;
  final double totalExpenseAmount;
  final PaginationMetaEntity meta;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String? selectedCategory;

  const ExpensesLoadedState({
    required this.expenses,
    required this.totalExpenseAmount,
    required this.meta,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.selectedCategory,
  });

  ExpensesLoadedState copyWith({
    List<ExpenseEntity>? expenses,
    double? totalExpenseAmount,
    PaginationMetaEntity? meta,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? selectedCategory,
  }) {
    return ExpensesLoadedState(
      expenses: expenses ?? this.expenses,
      totalExpenseAmount: totalExpenseAmount ?? this.totalExpenseAmount,
      meta: meta ?? this.meta,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [
        expenses,
        totalExpenseAmount,
        meta,
        isLoadingMore,
        hasReachedMax,
        selectedCategory,
      ];
}

class ExpensesOperationSuccessState extends ExpensesState {
  final String message;

  const ExpensesOperationSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class ExpensesErrorState extends ExpensesState {
  final String message;

  const ExpensesErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
