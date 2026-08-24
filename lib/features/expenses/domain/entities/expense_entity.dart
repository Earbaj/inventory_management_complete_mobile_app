/// Domain Entity representing a Shop Operational Expense in the Business Logic Layer.
class ExpenseEntity {
  final String id;
  final String category; // 'rent', 'utility', 'salary', 'transport', 'misc'
  final String title;
  final double amount;
  final DateTime date;
  final String? note;

  const ExpenseEntity({
    required this.id,
    required this.category,
    required this.title,
    required this.amount,
    required this.date,
    this.note,
  });

  ExpenseEntity copyWith({
    String? id,
    String? category,
    String? title,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseEntity && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
