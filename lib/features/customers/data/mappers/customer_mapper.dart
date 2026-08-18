import '../../domain/entities/customer_entity.dart';
import '../models/customer_model.dart';

/// Translator mapping between [CustomerModel] DTO and [CustomerEntity].
class CustomerMapper {
  static CustomerEntity modelToEntity(CustomerModel model) {
    final double due = model.totalDue.abs() > 0
        ? model.totalDue.abs()
        : model.openingBalance.abs();

    return CustomerEntity(
      id: model.id,
      name: model.name,
      phone: model.phone,
      email: model.email,
      address: model.address,
      totalDue: due,
      notes: model.notes,
      createdAt: model.createdAt != null
          ? DateTime.tryParse(model.createdAt!)
          : null,
      updatedAt: model.updatedAt != null
          ? DateTime.tryParse(model.updatedAt!)
          : null,
      openingBalance: model.openingBalance.abs(),
    );
  }

  static CustomerModel entityToModel(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      address: entity.address,
      totalDue: entity.totalDue,
      openingBalance: entity.openingBalance,
      notes: entity.notes,
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}
