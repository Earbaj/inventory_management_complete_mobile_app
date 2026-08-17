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
  final DateTime createdAt;

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
    required this.createdAt,
  });

  /// Computed property: true if sale has an associated customer.
  bool get hasCustomer => customer != null;
}
