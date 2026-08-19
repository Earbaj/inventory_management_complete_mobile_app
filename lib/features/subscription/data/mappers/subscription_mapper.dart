import '../../domain/entities/payment_entity.dart';
import '../models/payment_model.dart';

class SubscriptionMapper {
  static PaymentEntity paymentModelToEntity(PaymentModel model) {
    return PaymentEntity(
      id: model.id,
      shopId: model.shopId,
      method: model.method,
      transactionId: model.transactionId,
      amount: model.amount,
      targetTier: model.targetTier,
      status: model.status,
      rejectionReason: model.rejectionReason,
      createdAt: model.createdAt != null ? DateTime.tryParse(model.createdAt!) ?? DateTime.now() : DateTime.now(),
    );
  }

  static PaymentModel paymentEntityToModel(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      shopId: entity.shopId,
      method: entity.method,
      transactionId: entity.transactionId,
      amount: entity.amount,
      targetTier: entity.targetTier,
      status: entity.status,
      rejectionReason: entity.rejectionReason,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
