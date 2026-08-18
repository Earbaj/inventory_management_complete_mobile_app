abstract class SuperAdminEvent {
  const SuperAdminEvent();
}

class FetchPendingPaymentsEvent extends SuperAdminEvent {
  const FetchPendingPaymentsEvent();
}

class ApprovePaymentEvent extends SuperAdminEvent {
  final String paymentId;
  const ApprovePaymentEvent(this.paymentId);
}

class RejectPaymentEvent extends SuperAdminEvent {
  final String paymentId;
  const RejectPaymentEvent(this.paymentId);
}
