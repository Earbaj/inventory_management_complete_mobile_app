import '../../../recycle_bin/domain/entities/pagination_meta_entity.dart';
import 'expense_entity.dart';

/// Domain Entity encapsulating paginated shop expenses response.
class PaginatedExpensesEntity {
  final List<ExpenseEntity> data;
  final double totalExpenseAmount;
  final PaginationMetaEntity meta;

  const PaginatedExpensesEntity({
    required this.data,
    required this.totalExpenseAmount,
    required this.meta,
  });
}
