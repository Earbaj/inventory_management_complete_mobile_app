import '../../domain/entities/payment_entity.dart';

abstract class SubscriptionState {
  const SubscriptionState();
}

class SubscriptionInitialState extends SubscriptionState {
  const SubscriptionInitialState();
}

class SubscriptionLoadingState extends SubscriptionState {
  const SubscriptionLoadingState();
}

class PaymentSubmittedSuccessState extends SubscriptionState {
  final PaymentEntity payment;
  final String message;

  const PaymentSubmittedSuccessState({
    required this.payment,
    this.message = 'Payment submitted successfully! Awaiting Super Admin approval.',
  });
}

class SubscriptionErrorState extends SubscriptionState {
  final String message;

  const SubscriptionErrorState(this.message);
}
