import '../../domain/entities/customer_entity.dart';
import '../models/customer_model.dart';

/// Translator mapping between [CustomerModel] DTO and [CustomerEntity].
class CustomerMapper {
  static CustomerEntity modelToEntity(CustomerModel model) {
    return CustomerEntity(
      id: model.id,
      name: model.name,
      phone: model.phone,
      address: model.address,
      rawBalance: model.closingBalance,
      openingBalance: model.openingBalance,
    );
  }

  static CustomerModel entityToModel(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      openingBalance: entity.openingBalance,
      closingBalance: entity.rawBalance,
    );
  }
}
