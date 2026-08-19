abstract class SuperAdminEvent {
  const SuperAdminEvent();
}

class FetchSuperAdminDashboardEvent extends SuperAdminEvent {
  const FetchSuperAdminDashboardEvent();
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
  final String? reason;
  const RejectPaymentEvent(this.paymentId, {this.reason});
}

class DeleteShopEvent extends SuperAdminEvent {
  final String shopId;
  const DeleteShopEvent(this.shopId);
}
