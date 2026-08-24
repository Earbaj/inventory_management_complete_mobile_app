import '../../../../core/utils/money_util.dart';
import '../../domain/entities/expense_entity.dart';

/// Data Transfer Object (DTO) for Expense JSON payloads.
class ExpenseModel {
  final String id;
  final String category;
  final String title;
  final double amount;
  final String date;
  final String? note;

  const ExpenseModel({
    required this.id,
    required this.category,
    required this.title,
    required this.amount,
    required this.date,
    this.note,
  });

  static double _parseDouble(dynamic val) => MoneyUtil.parseMoney(val);

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      category: json['category']?.toString() ?? 'misc',
      title: json['title']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
      date: json['date']?.toString() ?? json['createdAt']?.toString() ?? '',
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'category': category,
      'title': title,
      'amount': amount,
      'date': date,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }

  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      category: category,
      title: title,
      amount: amount,
      date: DateTime.tryParse(date) ?? DateTime.now(),
      note: note,
    );
  }

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      category: entity.category,
      title: entity.title,
      amount: entity.amount,
      date: entity.date.toIso8601String().split('T').first,
      note: entity.note,
    );
  }
}
