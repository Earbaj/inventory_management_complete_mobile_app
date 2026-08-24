import '../entities/paginated_expenses_entity.dart';
import '../repositories/expenses_repository.dart';

/// UseCase: Fetches paginated shop operational expenses.
class GetExpensesUseCase {
  final ExpensesRepository repository;

  const GetExpensesUseCase(this.repository);

  Future<PaginatedExpensesEntity> call({
    int page = 1,
    int limit = 10,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return repository.getExpenses(
      page: page,
      limit: limit,
      category: category,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
