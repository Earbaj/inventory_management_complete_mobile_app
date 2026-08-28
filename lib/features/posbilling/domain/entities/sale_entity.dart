import '../../../customers/domain/entities/customer_entity.dart';
import 'cart_item_entity.dart';

/// Domain Entity representing a completed POS Sale Transaction.
class SaleEntity {
  final String id;
  final String invoiceNo;
  final CustomerEntity? customer;
  final List<CartItemEntity> items;
  final double subtotal;
  final double discountAmount;
  final double vatAmount;
  final double netTotal;
  final double paidAmount;
  final double dueAmount;
  final String paymentMethod; // 'cash', 'bkash', 'card', 'due'
  final String isReturned; // 'none', 'partially_returned', 'full' / 'returned'
  final DateTime createdAt;
  final String servedBy;

  const SaleEntity({
    required this.id,
    required this.invoiceNo,
    this.customer,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.vatAmount,
    required this.netTotal,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentMethod,
    this.isReturned = 'none',
    required this.createdAt,
    this.servedBy = 'Cashier',
  });

  /// Computed property: true if sale has an associated customer.
  bool get hasCustomer => customer != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleEntity &&
        (id.isNotEmpty && other.id.isNotEmpty
            ? id == other.id
            : invoiceNo == other.invoiceNo);
  }

  @override
  int get hashCode => id.isNotEmpty ? id.hashCode : invoiceNo.hashCode;
}
