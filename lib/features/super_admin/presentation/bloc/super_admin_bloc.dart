import 'dart:async';
import '../../../subscription/data/mappers/subscription_mapper.dart';
import '../../data/datasources/super_admin_remote_data_source.dart';
import 'super_admin_event.dart';
import 'super_admin_state.dart';

class SuperAdminBloc {
  final SuperAdminRemoteDataSource remoteDataSource;

  SuperAdminState _state = const SuperAdminInitialState();
  final _stateController = StreamController<SuperAdminState>.broadcast();

  SuperAdminState get state => _state;
  Stream<SuperAdminState> get stream => _stateController.stream;

  SuperAdminBloc({required this.remoteDataSource});

  void add(SuperAdminEvent event) {
    _handleEvent(event);
  }

  void _emit(SuperAdminState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _handleEvent(SuperAdminEvent event) async {
    if (event is FetchSuperAdminDashboardEvent || event is FetchPendingPaymentsEvent) {
      _emit(const SuperAdminLoadingState());
      await _loadDashboardData();
    } else if (event is ApprovePaymentEvent) {
      try {
        await remoteDataSource.approvePayment(event.paymentId);
        await _loadDashboardData(actionMessage: 'Payment #${event.paymentId} successfully approved!');
      } catch (e) {
        _emit(SuperAdminErrorState(e.toString()));
      }
    } else if (event is RejectPaymentEvent) {
      try {
        await remoteDataSource.rejectPayment(event.paymentId, reason: event.reason);
        await _loadDashboardData(actionMessage: 'Payment #${event.paymentId} rejected.');
      } catch (e) {
        _emit(SuperAdminErrorState(e.toString()));
      }
    } else if (event is DeleteShopEvent) {
      try {
        await remoteDataSource.deleteShop(event.shopId);
        await _loadDashboardData(actionMessage: 'Shop #${event.shopId} deletion requested.');
      } catch (e) {
        _emit(SuperAdminErrorState(e.toString()));
      }
    }
  }

  Future<void> _loadDashboardData({String? actionMessage}) async {
    try {
      final metrics = await remoteDataSource.getSuperAdminMetrics();
      final paymentModels = await remoteDataSource.getPendingPayments();
      final paymentEntities = paymentModels.map(SubscriptionMapper.paymentModelToEntity).toList();
      final shops = await remoteDataSource.getShopsList();

      _emit(
        SuperAdminDashboardLoadedState(
          metrics: metrics,
          payments: paymentEntities,
          shops: shops,
          actionMessage: actionMessage,
        ),
      );
    } catch (e) {
      _emit(SuperAdminErrorState(e.toString()));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
