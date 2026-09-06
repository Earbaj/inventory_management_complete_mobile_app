import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../subscription/data/mappers/subscription_mapper.dart';
import '../../data/datasources/super_admin_remote_data_source.dart';
import '../../data/models/super_admin_metrics_model.dart';
import '../../data/models/shop_item_model.dart';
import '../../data/models/shop_detail_model.dart';
import 'super_admin_event.dart';
import 'super_admin_state.dart';

class SuperAdminBloc extends Bloc<SuperAdminEvent, SuperAdminState> {
  final SuperAdminRemoteDataSource remoteDataSource;

  SuperAdminBloc({required this.remoteDataSource})
      : super(const SuperAdminInitialState()) {
    on<FetchSuperAdminDashboardEvent>(_onFetchDashboard);
    on<FetchPendingPaymentsEvent>(_onFetchPendingPayments);
    on<ApprovePaymentEvent>(_onApprovePayment);
    on<RejectPaymentEvent>(_onRejectPayment);
    on<DeleteShopEvent>(_onDeleteShop);
  }

  Future<void> _onFetchDashboard(
    FetchSuperAdminDashboardEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    emit(const SuperAdminLoadingState());
    await _loadDashboardData(emit);
  }

  Future<void> _onFetchPendingPayments(
    FetchPendingPaymentsEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    emit(const SuperAdminLoadingState());
    await _loadDashboardData(emit);
  }

  Future<void> _onApprovePayment(
    ApprovePaymentEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      await remoteDataSource.approvePayment(event.paymentId);
      await _loadDashboardData(emit, actionMessage: 'Payment #${event.paymentId} successfully approved!');
    } catch (e) {
      emit(SuperAdminErrorState(e.toString()));
    }
  }

  Future<void> _onRejectPayment(
    RejectPaymentEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      await remoteDataSource.rejectPayment(event.paymentId, reason: event.reason);
      await _loadDashboardData(emit, actionMessage: 'Payment #${event.paymentId} rejected.');
    } catch (e) {
      emit(SuperAdminErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteShop(
    DeleteShopEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      await remoteDataSource.deleteShop(event.shopId);
      await _loadDashboardData(emit, actionMessage: 'Shop #${event.shopId} deletion requested.');
    } catch (e) {
      emit(SuperAdminErrorState(e.toString()));
    }
  }

  Future<void> _loadDashboardData(
    Emitter<SuperAdminState> emit, {
    String? actionMessage,
  }) async {
    try {
      final metrics = await remoteDataSource.getSuperAdminMetrics();
      final paymentModels = await remoteDataSource.getPendingPayments();
      final paymentEntities = paymentModels.map(SubscriptionMapper.paymentModelToEntity).toList();
      final shops = await remoteDataSource.getShopsList();

      emit(
        SuperAdminDashboardLoadedState(
          metrics: metrics,
          payments: paymentEntities,
          shops: shops,
          actionMessage: actionMessage,
        ),
      );
    } catch (e) {
      emit(SuperAdminErrorState(e.toString()));
    }
  }

  Future<ShopDetailModel> getShopDetails(String shopId) {
    return remoteDataSource.getShopDetails(shopId);
  }
}

