import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entity.dart';

abstract class ExpensesEvent extends Equatable {
  const ExpensesEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Initial or refreshed fetch of expenses list.
class FetchExpensesEvent extends ExpensesEvent {
  final int page;
  final int limit;
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isRefresh;

  const FetchExpensesEvent({
    this.page = 1,
    this.limit = 10,
    this.category,
    this.startDate,
    this.endDate,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, category, startDate, endDate, isRefresh];
}

/// Event: Infinite scroll loading next page.
class LoadMoreExpensesEvent extends ExpensesEvent {
  const LoadMoreExpensesEvent();
}

/// Event: Filter expenses list by category chip.
class FilterExpensesByCategoryEvent extends ExpensesEvent {
  final String? category; // 'rent', 'utility', 'salary', 'transport', 'misc' or null/all

  const FilterExpensesByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Event: Create a new expense record.
class CreateExpenseEvent extends ExpensesEvent {
  final ExpenseEntity expense;

  const CreateExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

/// Event: Update an existing expense record.
class UpdateExpenseEvent extends ExpensesEvent {
  final ExpenseEntity expense;

  const UpdateExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

/// Event: Delete an expense record (Moves to Recycle Bin).
class DeleteExpenseEvent extends ExpensesEvent {
  final String id;

  const DeleteExpenseEvent(this.id);

  @override
  List<Object?> get props => [id];
}
