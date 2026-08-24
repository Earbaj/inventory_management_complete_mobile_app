import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/expense_entity.dart';
import '../../domain/usecases/create_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';
import 'expenses_event.dart';
import 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final GetExpensesUseCase getExpensesUseCase;
  final CreateExpenseUseCase createExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  String? _currentCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  ExpensesBloc({
    required this.getExpensesUseCase,
    required this.createExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
  }) : super(const ExpensesInitialState()) {
    on<FetchExpensesEvent>(_onFetchExpenses);
    on<LoadMoreExpensesEvent>(_onLoadMoreExpenses);
    on<FilterExpensesByCategoryEvent>(_onFilterByCategory);
    on<CreateExpenseEvent>(_onCreateExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
  }

  Future<void> _onFetchExpenses(
    FetchExpensesEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    _currentCategory = event.category ?? _currentCategory;
    _startDate = event.startDate ?? _startDate;
    _endDate = event.endDate ?? _endDate;

    if (state is! ExpensesLoadedState || event.isRefresh) {
      emit(const ExpensesLoadingState());
    }

    try {
      final res = await getExpensesUseCase(
        page: event.page,
        limit: event.limit,
        category: _currentCategory,
        startDate: _startDate,
        endDate: _endDate,
      );

      emit(ExpensesLoadedState(
        expenses: res.data,
        totalExpenseAmount: res.totalExpenseAmount,
        meta: res.meta,
        hasReachedMax: !res.meta.hasNextPage,
        selectedCategory: _currentCategory,
      ));
    } catch (e) {
      emit(ExpensesErrorState(e.toString()));
    }
  }

  Future<void> _onLoadMoreExpenses(
    LoadMoreExpensesEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ExpensesLoadedState ||
        currentState.isLoadingMore ||
        currentState.hasReachedMax) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.meta.page + 1;
      final res = await getExpensesUseCase(
        page: nextPage,
        limit: currentState.meta.limit,
        category: _currentCategory,
        startDate: _startDate,
        endDate: _endDate,
      );

      final updatedList = List<ExpenseEntity>.from(currentState.expenses)..addAll(res.data);

      emit(currentState.copyWith(
        expenses: updatedList,
        totalExpenseAmount: res.totalExpenseAmount > 0 ? res.totalExpenseAmount : currentState.totalExpenseAmount,
        meta: res.meta,
        isLoadingMore: false,
        hasReachedMax: !res.meta.hasNextPage,
      ));
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onFilterByCategory(
    FilterExpensesByCategoryEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    _currentCategory = event.category;
    add(FetchExpensesEvent(page: 1, category: _currentCategory, isRefresh: true));
  }

  Future<void> _onCreateExpense(
    CreateExpenseEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      final created = await createExpenseUseCase(event.expense);
      emit(const ExpensesOperationSuccessState('Expense created successfully!'));

      // Re-fetch expenses
      add(FetchExpensesEvent(page: 1, category: _currentCategory, isRefresh: true));
    } catch (e) {
      emit(ExpensesErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      await updateExpenseUseCase(event.expense);
      emit(const ExpensesOperationSuccessState('Expense updated successfully!'));

      // Re-fetch expenses
      add(FetchExpensesEvent(page: 1, category: _currentCategory, isRefresh: true));
    } catch (e) {
      emit(ExpensesErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      await deleteExpenseUseCase(event.id);
      emit(const ExpensesOperationSuccessState('Expense moved to Recycle Bin (Soft deleted).'));

      // Re-fetch expenses
      add(FetchExpensesEvent(page: 1, category: _currentCategory, isRefresh: true));
    } catch (e) {
      emit(ExpensesErrorState(e.toString()));
    }
  }
}
