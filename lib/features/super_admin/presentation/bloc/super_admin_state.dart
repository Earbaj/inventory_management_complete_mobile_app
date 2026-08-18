import '../../../subscription/domain/entities/payment_entity.dart';
import '../../data/models/super_admin_metrics_model.dart';
import '../../data/models/shop_item_model.dart';

abstract class SuperAdminState {
  const SuperAdminState();
}

class SuperAdminInitialState extends SuperAdminState {
  const SuperAdminInitialState();
}

class SuperAdminLoadingState extends SuperAdminState {
  const SuperAdminLoadingState();
}

class SuperAdminDashboardLoadedState extends SuperAdminState {
  final SuperAdminMetricsModel metrics;
  final List<PaymentEntity> payments;
  final List<ShopItemModel> shops;
  final String? actionMessage;

  const SuperAdminDashboardLoadedState({
    required this.metrics,
    required this.payments,
    required this.shops,
    this.actionMessage,
  });
}

class SuperAdminErrorState extends SuperAdminState {
  final String message;
  const SuperAdminErrorState(this.message);
}
