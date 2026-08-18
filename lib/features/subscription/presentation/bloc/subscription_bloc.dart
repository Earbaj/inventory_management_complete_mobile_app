import 'dart:async';
import '../../domain/usecases/submit_payment_usecase.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc {
  final SubmitPaymentUseCase submitPaymentUseCase;

  SubscriptionState _state = const SubscriptionInitialState();
  final _stateController = StreamController<SubscriptionState>.broadcast();

  SubscriptionState get state => _state;
  Stream<SubscriptionState> get stream => _stateController.stream;

  SubscriptionBloc({required this.submitPaymentUseCase});

  void add(SubscriptionEvent event) {
    _handleEvent(event);
  }

  void _emit(SubscriptionState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _handleEvent(SubscriptionEvent event) async {
    if (event is SubmitSubscriptionPaymentEvent) {
      _emit(const SubscriptionLoadingState());
      try {
        final payment = await submitPaymentUseCase(
          method: event.method,
          transactionId: event.transactionId,
          amount: event.amount,
          targetTier: event.targetTier,
        );

        _emit(PaymentSubmittedSuccessState(payment: payment));
      } catch (e) {
        _emit(SubscriptionErrorState(e.toString()));
      }
    }
  }

  void dispose() {
    _stateController.close();
  }
}
