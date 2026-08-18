/// Domain Entity representing a Subscription Payment Transaction.
class PaymentEntity {
  final String id;
  final String shopId;
  final String method; // 'bkash', 'nagad', 'rocket', 'bank'
  final String transactionId;
  final double amount;
  final String targetTier; // 'premium'
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  const PaymentEntity({
    required this.id,
    required this.shopId,
    required this.method,
    required this.transactionId,
    required this.amount,
    required this.targetTier,
    required this.status,
    required this.createdAt,
  });
}
