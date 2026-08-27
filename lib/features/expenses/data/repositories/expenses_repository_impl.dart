import '../../../../core/error/failures.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/paginated_expenses_entity.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../datasources/expenses_remote_data_source.dart';
import '../models/expense_model.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesRemoteDataSource remoteDataSource;

  ExpensesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PaginatedExpensesEntity> getExpenses({
    int page = 1,
    int limit = 10,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      final remoteModel = await remoteDataSource.getExpenses(
        page: page,
        limit: limit,
        category: category,
        startDate: startDate,
        endDate: endDate,
        forceRefresh: forceRefresh,
      );
      return remoteModel.toEntity();
    } catch (e) {
      throw ServerFailure(e is Failure ? e.message : e.toString());
    }
  }

  @override
  Future<ExpenseEntity> getExpenseById(String id) async {
    try {
      final remoteModel = await remoteDataSource.getExpenseById(id);
      return remoteModel.toEntity();
    } catch (e) {
      throw ServerFailure(e is Failure ? e.message : e.toString());
    }
  }

  @override
  Future<ExpenseEntity> createExpense(ExpenseEntity expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      final remoteModel = await remoteDataSource.createExpense(model);
      return remoteModel.toEntity();
    } catch (e) {
      throw ServerFailure(e is Failure ? e.message : e.toString());
    }
  }

  @override
  Future<ExpenseEntity> updateExpense(ExpenseEntity expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      final remoteModel = await remoteDataSource.updateExpense(model);
      return remoteModel.toEntity();
    } catch (e) {
      throw ServerFailure(e is Failure ? e.message : e.toString());
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await remoteDataSource.deleteExpense(id);
    } catch (e) {
      throw ServerFailure(e is Failure ? e.message : e.toString());
    }
  }
}
