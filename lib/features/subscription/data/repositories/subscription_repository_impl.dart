import 'dart:developer' as developer;
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
    required String accountNumber
  }) async {
    developer.log('🏛️ [SubscriptionRepository] Processing submitPayment for method: $method, trxId: $transactionId', name: 'SubscriptionRepository');
    try {
      final model = await remoteDataSource.submitPayment(
        method: method,
        transactionId: transactionId,
        amount: amount,
        targetTier: targetTier,
        accountNumber: accountNumber
      );
      final entity = SubscriptionMapper.paymentModelToEntity(model);
      developer.log('✅ [SubscriptionRepository] Mapped PaymentEntity: ID=${entity.id}, Status=${entity.status}', name: 'SubscriptionRepository');
      return entity;
    } catch (e, stackTrace) {
      developer.log('❌ [SubscriptionRepository] submitPayment Error: $e', name: 'SubscriptionRepository', error: e, stackTrace: stackTrace);
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to submit subscription payment. Details: ${e.toString()}');
    }
  }

  @override
  Future<List<PaymentEntity>> getPaymentLogs() async {
    developer.log('🏛️ [SubscriptionRepository] Fetching payment logs...', name: 'SubscriptionRepository');
    try {
      final models = await remoteDataSource.getPaymentLogs();
      final entities = models.map(SubscriptionMapper.paymentModelToEntity).toList();
      developer.log('✅ [SubscriptionRepository] Successfully fetched ${entities.length} payment log entities.', name: 'SubscriptionRepository');
      return entities;
    } catch (e, stackTrace) {
      developer.log('❌ [SubscriptionRepository] getPaymentLogs Error: $e', name: 'SubscriptionRepository', error: e, stackTrace: stackTrace);
      return [];
    }
  }
}
