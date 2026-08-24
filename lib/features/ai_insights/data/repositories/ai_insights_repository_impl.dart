import '../../../../core/error/failures.dart';
import '../../domain/entities/business_advisor_entity.dart';
import '../../domain/entities/customer_credit_score_entity.dart';
import '../../domain/entities/demand_forecast_entity.dart';
import '../../domain/repositories/ai_insights_repository.dart';
import '../datasources/ai_insights_remote_data_source.dart';

class AiInsightsRepositoryImpl implements AiInsightsRepository {
  final AiInsightsRemoteDataSource remoteDataSource;

  AiInsightsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DemandForecastEntity> getPredictDemand() async {
    try {
      final remoteModel = await remoteDataSource.getPredictDemand();
      return remoteModel.toEntity();
    } catch (e) {
      throw ServerFailure(e is Failure ? e.message : e.toString());
    }
  }

  @override
  Future<CustomerCreditScoreEntity> getCustomerCreditScore(String customerId) async {
    try {
      final remoteModel = await remoteDataSource.getCustomerCreditScore(customerId);
      return remoteModel.toEntity();
    } catch (e) {
      throw ServerFailure(e is Failure ? e.message : e.toString());
    }
  }

  @override
  Future<BusinessAdvisorEntity> getBusinessAdvisor() async {
    try {
      final remoteModel = await remoteDataSource.getBusinessAdvisor();
      return remoteModel.toEntity();
    } catch (e) {
      throw ServerFailure(e is Failure ? e.message : e.toString());
    }
  }
}
