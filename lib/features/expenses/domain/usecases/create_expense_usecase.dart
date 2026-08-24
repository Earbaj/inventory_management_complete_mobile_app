import '../entities/expense_entity.dart';
import '../repositories/expenses_repository.dart';

/// UseCase: Creates a new shop operational expense record.
class CreateExpenseUseCase {
  final ExpensesRepository repository;

  const CreateExpenseUseCase(this.repository);

  Future<ExpenseEntity> call(ExpenseEntity expense) {
    return repository.createExpense(expense);
  }
}
