import '../../domain/entities/trash_item_entity.dart';

/// DTO Model for soft-deleted items returned by GET /api/trash.
class TrashItemModel {
  final String id;
  final String entityType;
  final String title;
  final String subtitle;
  final double? amount;
  final String? deletedAt;
  final String? deletedBy;

  const TrashItemModel({
    required this.id,
    required this.entityType,
    required this.title,
    required this.subtitle,
    this.amount,
    this.deletedAt,
    this.deletedBy,
  });

  factory TrashItemModel.fromJson(Map<String, dynamic> json) {
    final type = (json['entityType'] ?? json['type'] ?? 'item').toString().toLowerCase();
    String title = '';
    String subtitle = '';
    double? amt;

    if (type == 'item' || type == 'inventory') {
      title = json['name']?.toString() ?? 'Unnamed Product';
      subtitle = 'SKU: ${json['sku'] ?? 'N/A'} • Stock: ${json['stockQuantity'] ?? 0}';
      amt = (json['sellPrice'] as num?)?.toDouble();
    } else if (type == 'customer') {
      title = json['name']?.toString() ?? 'Unnamed Customer';
      subtitle = 'Phone: ${json['phone'] ?? 'N/A'}';
      amt = (json['closingBalance'] as num?)?.toDouble();
    } else if (type == 'sale') {
      title = json['invoiceNumber']?.toString() ?? 'Invoice #N/A';
      subtitle = 'Customer: ${json['customerName'] ?? 'Guest'}';
      amt = (json['grandTotal'] as num?)?.toDouble();
    } else if (type == 'return') {
      title = json['invoiceNumber']?.toString() ?? 'Return #N/A';
      subtitle = json['reason']?.toString() ?? 'Sales Return Record';
      amt = (json['refundAmount'] as num?)?.toDouble();
    } else {
      title = json['name']?.toString() ?? json['title']?.toString() ?? 'Deleted Record';
      subtitle = json['details']?.toString() ?? json['description']?.toString() ?? '';
    }

    return TrashItemModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      entityType: type,
      title: title,
      subtitle: subtitle,
      amount: amt,
      deletedAt: json['deletedAt']?.toString(),
      deletedBy: json['deletedBy'] is Map
          ? (json['deletedBy']['name'] ?? json['deletedBy']['email'] ?? '').toString()
          : json['deletedBy']?.toString(),
    );
  }

  TrashItemEntity toEntity() {
    return TrashItemEntity(
      id: id,
      entityType: entityType,
      title: title,
      subtitle: subtitle,
      amount: amount,
      deletedAt: deletedAt != null ? DateTime.tryParse(deletedAt!) : null,
      deletedBy: deletedBy,
    );
  }
}
