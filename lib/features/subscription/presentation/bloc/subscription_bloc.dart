import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/subscription_remote_data_source.dart';
import '../../data/models/payment_info_model.dart';
import '../../data/models/subscription_package_model.dart';
import '../../domain/usecases/get_payment_logs_usecase.dart';
import '../../domain/usecases/submit_payment_usecase.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubmitPaymentUseCase submitPaymentUseCase;
  final GetPaymentLogsUseCase getPaymentLogsUseCase;
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionBloc({
    required this.submitPaymentUseCase,
    required this.getPaymentLogsUseCase,
    required this.remoteDataSource,
  }) : super(const SubscriptionInitialState()) {
    on<SubmitSubscriptionPaymentEvent>(_onSubmitPayment);
    on<FetchPaymentLogsEvent>(_onFetchPaymentLogs);
  }

  Future<List<SubscriptionPackageModel>> getPackages() => remoteDataSource.getPackages();
  Future<PaymentInfoModel> getPaymentInfo() => remoteDataSource.getPaymentInfo();

  Future<void> _onSubmitPayment(
    SubmitSubscriptionPaymentEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoadingState());
    try {
      final payment = await submitPaymentUseCase(
        method: event.method,
        transactionId: event.transactionId,
        amount: event.amount,
        targetTier: event.targetTier,
        accountNumber: event.accountNumber,
      );

      emit(PaymentSubmittedSuccessState(payment: payment));
    } catch (e) {
      emit(SubscriptionErrorState(e.toString()));
    }
  }

  Future<void> _onFetchPaymentLogs(
    FetchPaymentLogsEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoadingState());
    try {
      final logs = await getPaymentLogsUseCase();
      emit(PaymentLogsLoadedState(logs));
    } catch (e) {
      emit(SubscriptionErrorState(e.toString()));
    }
  }
}

