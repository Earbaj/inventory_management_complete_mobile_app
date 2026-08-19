class PaymentModel {
  final String id;
  final String shopId;
  final String method;
  final String transactionId;
  final double amount;
  final String targetTier;
  final String status;
  final String? rejectionReason;
  final String? createdAt;

  const PaymentModel({
    required this.id,
    required this.shopId,
    required this.method,
    required this.transactionId,
    required this.amount,
    required this.targetTier,
    required this.status,
    this.rejectionReason,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? json['shop_id']?.toString() ?? '',
      method: json['method']?.toString() ?? json['payment_method']?.toString() ?? json['paymentMethod']?.toString() ?? 'bkash',
      transactionId: json['transactionId']?.toString() ?? json['trxId']?.toString() ?? json['trx_id']?.toString() ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      targetTier: json['targetTier']?.toString() ?? json['tier']?.toString() ?? 'premium',
      status: json['status']?.toString() ?? 'pending',
      rejectionReason: json['rejectionReason']?.toString() ?? json['reason']?.toString(),
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
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
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
