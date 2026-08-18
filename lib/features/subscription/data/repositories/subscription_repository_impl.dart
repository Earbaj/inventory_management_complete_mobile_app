import '../../../../core/error/failures.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_data_source.dart';
import '../mappers/subscription_mapper.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PaymentEntity> submitPayment({
    required String method,
    required String transactionId,
    required double amount,
    required String targetTier,
  }) async {
    try {
      final model = await remoteDataSource.submitPayment(
        method: method,
        transactionId: transactionId,
        amount: amount,
        targetTier: targetTier,
      );
      return SubscriptionMapper.paymentModelToEntity(model);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to submit subscription payment. Please check your connection.');
    }
  }

  @override
  Future<List<PaymentEntity>> getPaymentLogs() async {
    try {
      final models = await remoteDataSource.getPaymentLogs();
      return models.map(SubscriptionMapper.paymentModelToEntity).toList();
    } catch (_) {
      return [];
    }
  }
}
