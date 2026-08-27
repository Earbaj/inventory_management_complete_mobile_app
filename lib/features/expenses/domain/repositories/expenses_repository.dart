import '../entities/expense_entity.dart';
import '../entities/paginated_expenses_entity.dart';

/// Abstract contract defining Shop Expenses Repository operations.
abstract class ExpensesRepository {
  /// Fetches paginated shop expenses (GET /api/expenses).
  Future<PaginatedExpensesEntity> getExpenses({
    int page = 1,
    int limit = 10,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  });

  /// Fetches single expense record details (GET /api/expenses/:id).
  Future<ExpenseEntity> getExpenseById(String id);

  /// Creates a new shop expense record (POST /api/expenses).
  Future<ExpenseEntity> createExpense(ExpenseEntity expense);

  /// Updates an existing expense record (PUT /api/expenses/:id).
  Future<ExpenseEntity> updateExpense(ExpenseEntity expense);

  /// Soft-deletes expense record (DELETE /api/expenses/:id).
  Future<void> deleteExpense(String id);
}
