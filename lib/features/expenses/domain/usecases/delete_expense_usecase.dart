import '../repositories/expenses_repository.dart';

/// UseCase: Soft-deletes shop expense record (Moves to Recycle Bin).
class DeleteExpenseUseCase {
  final ExpensesRepository repository;

  const DeleteExpenseUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteExpense(id);
  }
}
