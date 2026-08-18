
import '../../../subscription/domain/entities/payment_entity.dart';

abstract class SuperAdminState {
  const SuperAdminState();
}

class SuperAdminInitialState extends SuperAdminState {
  const SuperAdminInitialState();
}

class SuperAdminLoadingState extends SuperAdminState {
  const SuperAdminLoadingState();
}

class SuperAdminLoadedState extends SuperAdminState {
  final List<PaymentEntity> payments;
  const SuperAdminLoadedState(this.payments);
}

class SuperAdminErrorState extends SuperAdminState {
  final String message;
  const SuperAdminErrorState(this.message);
}
