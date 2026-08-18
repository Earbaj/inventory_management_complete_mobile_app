/// Domain Entity representing a soft-deleted record in the Recycle Bin.
class TrashItemEntity {
  final String id;
  final String entityType; // 'item', 'customer', 'sale', 'return'
  final String title;
  final String subtitle;
  final double? amount;
  final DateTime? deletedAt;
  final String? deletedBy;

  const TrashItemEntity({
    required this.id,
    required this.entityType,
    required this.title,
    required this.subtitle,
    this.amount,
    this.deletedAt,
    this.deletedBy,
  });
}
