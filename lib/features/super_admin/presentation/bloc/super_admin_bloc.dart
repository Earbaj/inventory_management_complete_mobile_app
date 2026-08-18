import 'dart:async';
import '../../data/datasources/super_admin_remote_data_source.dart';
import '../../subscription/data/mappers/subscription_mapper.dart';
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
    if (event is FetchPendingPaymentsEvent) {
      _emit(const SuperAdminLoadingState());
      try {
        final models = await remoteDataSource.getPendingPayments();
        final entities = models.map(SubscriptionMapper.paymentModelToEntity).toList();
        _emit(SuperAdminLoadedState(entities));
      } catch (e) {
        _emit(SuperAdminErrorState(e.toString()));
      }
    } else if (event is ApprovePaymentEvent) {
      try {
        await remoteDataSource.approvePayment(event.paymentId);
        add(const FetchPendingPaymentsEvent());
      } catch (e) {
        _emit(SuperAdminErrorState(e.toString()));
      }
    } else if (event is RejectPaymentEvent) {
      try {
        await remoteDataSource.rejectPayment(event.paymentId);
        add(const FetchPendingPaymentsEvent());
      } catch (e) {
        _emit(SuperAdminErrorState(e.toString()));
      }
    }
  }

  void dispose() {
    _stateController.close();
  }
}
