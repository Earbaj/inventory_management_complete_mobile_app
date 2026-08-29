import 'dart:developer' as developer;
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/expense_model.dart';
import '../models/paginated_expenses_model.dart';

abstract class ExpensesRemoteDataSource {
  Future<PaginatedExpensesModel> getExpenses({
    int page = 1,
    int limit = 10,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  });

  Future<ExpenseModel> getExpenseById(String id);
  Future<ExpenseModel> createExpense(ExpenseModel expense);
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
}

class ExpensesRemoteDataSourceImpl implements ExpensesRemoteDataSource {
  final ApiClient apiClient;

  ExpensesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedExpensesModel> getExpenses({
    int page = 1,
    int limit = 10,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    developer.log(
      '💸 [ExpensesRemoteDataSource] getExpenses() page: $page, limit: $limit, category: "$category", startDate: $startDate, endDate: $endDate, forceRefresh: $forceRefresh',
      name: 'ExpensesRemoteDataSource',
    );
    try {
      final response = await apiClient.get(
        ApiEndpoints.expenses,
        cache: true,
        cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.forceCache,
        maxStale: const Duration(minutes: 30),
        queryParameters: {
          'page': page,
          'limit': limit,
          if (category != null && category.isNotEmpty && category.toLowerCase() != 'all')
            'category': category,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );

      developer.log(
        '✅ [ExpensesRemoteDataSource] getExpenses() success from ${ApiEndpoints.expenses}. Response type: ${response.runtimeType}',
        name: 'ExpensesRemoteDataSource',
      );

      final Map<String, dynamic> jsonResponse = response is Map<String, dynamic>
          ? response
          : {'data': response};

      return PaginatedExpensesModel.fromJson(jsonResponse);
    } catch (e, stackTrace) {
      developer.log(
        '❌ [ExpensesRemoteDataSource] getExpenses() API Error: $e',
        name: 'ExpensesRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<ExpenseModel> getExpenseById(String id) async {
    developer.log(
      '💸 [ExpensesRemoteDataSource] getExpenseById() id: "$id"',
      name: 'ExpensesRemoteDataSource',
    );
    try {
      final response = await apiClient.get(
        ApiEndpoints.expenseById(id),
      );

      developer.log(
        '✅ [ExpensesRemoteDataSource] getExpenseById() success for ID: "$id"',
        name: 'ExpensesRemoteDataSource',
      );

      final Map<String, dynamic> jsonResponse = response is Map<String, dynamic>
          ? response
          : {};
      return ExpenseModel.fromJson(jsonResponse);
    } catch (e, stackTrace) {
      developer.log(
        '❌ [ExpensesRemoteDataSource] getExpenseById() API Error for ID "$id": $e',
        name: 'ExpensesRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    developer.log(
      '💸 [ExpensesRemoteDataSource] createExpense() title: "${expense.title}", amount: ${expense.amount}, category: "${expense.category}"',
      name: 'ExpensesRemoteDataSource',
    );
    try {
      final response = await apiClient.post(
        ApiEndpoints.expenses,
        body: expense.toJson(),
      );

      developer.log(
        '✅ [ExpensesRemoteDataSource] createExpense() success. Created ID: "${response is Map ? response['id'] : 'N/A'}"',
        name: 'ExpensesRemoteDataSource',
      );

      final Map<String, dynamic> jsonResponse = response is Map<String, dynamic>
          ? response
          : expense.toJson();
      return ExpenseModel.fromJson(jsonResponse);
    } catch (e, stackTrace) {
      developer.log(
        '❌ [ExpensesRemoteDataSource] createExpense() API Error: $e',
        name: 'ExpensesRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    developer.log(
      '💸 [ExpensesRemoteDataSource] updateExpense() ID: "${expense.id}", title: "${expense.title}", amount: ${expense.amount}',
      name: 'ExpensesRemoteDataSource',
    );
    try {
      final response = await apiClient.put(
        ApiEndpoints.expenseById(expense.id),
        body: expense.toJson(),
      );

      developer.log(
        '✅ [ExpensesRemoteDataSource] updateExpense() success for ID: "${expense.id}"',
        name: 'ExpensesRemoteDataSource',
      );

      final Map<String, dynamic> jsonResponse = response is Map<String, dynamic>
          ? response
          : expense.toJson();
      return ExpenseModel.fromJson(jsonResponse);
    } catch (e, stackTrace) {
      developer.log(
        '❌ [ExpensesRemoteDataSource] updateExpense() API Error for ID "${expense.id}": $e',
        name: 'ExpensesRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    developer.log(
      '💸 [ExpensesRemoteDataSource] deleteExpense() soft-deleting expense ID: "$id"',
      name: 'ExpensesRemoteDataSource',
    );
    try {
      await apiClient.delete(
        ApiEndpoints.expenseById(id),
      );

      developer.log(
        '✅ [ExpensesRemoteDataSource] deleteExpense() success. Expense ID "$id" moved to trash.',
        name: 'ExpensesRemoteDataSource',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ [ExpensesRemoteDataSource] deleteExpense() API Error for ID "$id": $e',
        name: 'ExpensesRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
