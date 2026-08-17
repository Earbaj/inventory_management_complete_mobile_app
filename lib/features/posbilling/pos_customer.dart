import '../customers/domain/entities/customer_entity.dart';

/// Legacy alias connecting to Clean Architecture [CustomerEntity]
typedef PosCustomer = CustomerEntity;

extension PosCustomerExt on CustomerEntity {
  double get due => totalDue;
}