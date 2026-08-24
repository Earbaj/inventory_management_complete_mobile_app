import '../entities/expense_entity.dart';
import '../repositories/expenses_repository.dart';

/// UseCase: Updates an existing shop operational expense record.
class UpdateExpenseUseCase {
  final ExpensesRepository repository;

  const UpdateExpenseUseCase(this.repository);

  Future<ExpenseEntity> call(ExpenseEntity expense) {
    return repository.updateExpense(expense);
  }
}
