import '../../../../core/utils/money_util.dart';
import '../../../recycle_bin/data/models/pagination_meta_model.dart';
import '../../domain/entities/paginated_expenses_entity.dart';
import 'expense_model.dart';

/// Data Transfer Object (DTO) for Paginated Expenses JSON API Response.
class PaginatedExpensesModel {
  final List<ExpenseModel> data;
  final double totalExpenseAmount;
  final PaginationMetaModel meta;

  const PaginatedExpensesModel({
    required this.data,
    required this.totalExpenseAmount,
    required this.meta,
  });

  static double _parseDouble(dynamic val) => MoneyUtil.parseMoney(val);

  factory PaginatedExpensesModel.fromJson(Map<String, dynamic> json) {
    final List rawList = json['data'] is List ? json['data'] : (json['expenses'] is List ? json['expenses'] : []);
    final List<ExpenseModel> items = rawList
        .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final double totalAmt = _parseDouble(json['totalExpenseAmount'] ?? json['total_expense_amount'] ?? json['totalAmount']);
    final PaginationMetaModel metaModel = json['meta'] is Map<String, dynamic>
        ? PaginationMetaModel.fromJson(json['meta'] as Map<String, dynamic>)
        : PaginationMetaModel(
            total: items.length,
            page: 1,
            limit: items.length > 0 ? items.length : 10,
            totalPages: 1,
            hasNextPage: false,
            hasPrevPage: false,
          );

    return PaginatedExpensesModel(
      data: items,
      totalExpenseAmount: totalAmt,
      meta: metaModel,
    );
  }

  PaginatedExpensesEntity toEntity() {
    return PaginatedExpensesEntity(
      data: data.map((e) => e.toEntity()).toList(),
      totalExpenseAmount: totalExpenseAmount,
      meta: meta.toEntity(),
    );
  }
}
