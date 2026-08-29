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
  final bool isListLoading;

  const ExpensesLoadedState({
    required this.expenses,
    required this.totalExpenseAmount,
    required this.meta,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.selectedCategory,
    this.isListLoading = false,
  });

  ExpensesLoadedState copyWith({
    List<ExpenseEntity>? expenses,
    double? totalExpenseAmount,
    PaginationMetaEntity? meta,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? selectedCategory,
    bool? isListLoading,
  }) {
    return ExpensesLoadedState(
      expenses: expenses ?? this.expenses,
      totalExpenseAmount: totalExpenseAmount ?? this.totalExpenseAmount,
      meta: meta ?? this.meta,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isListLoading: isListLoading ?? this.isListLoading,
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
        isListLoading,
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
  final List<ExpenseEntity> previousExpenses;
  final double previousTotalAmount;

  const ExpensesErrorState(
    this.message, {
    this.previousExpenses = const [],
    this.previousTotalAmount = 0.0,
  });

  @override
  List<Object?> get props => [message, previousExpenses, previousTotalAmount];
}
