abstract class SubscriptionEvent {
  const SubscriptionEvent();
}

class SubmitSubscriptionPaymentEvent extends SubscriptionEvent {
  final String method;
  final String transactionId;
  final double amount;
  final String targetTier;

  const SubmitSubscriptionPaymentEvent({
    required this.method,
    required this.transactionId,
    required this.amount,
    this.targetTier = 'premium',
  });
}
