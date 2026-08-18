class PaymentModel {
  final String id;
  final String shopId;
  final String method;
  final String transactionId;
  final double amount;
  final String targetTier;
  final String status;
  final String? createdAt;

  const PaymentModel({
    required this.id,
    required this.shopId,
    required this.method,
    required this.transactionId,
    required this.amount,
    required this.targetTier,
    required this.status,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      shopId: json['shopId'] ?? json['shop_id'] ?? '',
      method: json['method'] ?? json['payment_method'] ?? 'bkash',
      transactionId: json['transactionId'] ?? json['trxId'] ?? json['trx_id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      targetTier: json['targetTier'] ?? json['tier'] ?? 'premium',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'method': method,
      'transactionId': transactionId,
      'amount': amount,
      'targetTier': targetTier,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
