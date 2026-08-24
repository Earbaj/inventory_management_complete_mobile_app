import '../../domain/entities/staff_entity.dart';
import '../models/staff_model.dart';

/// Translator mapping between Staff DTO Model and Domain Entity.
class StaffMapper {
  static StaffEntity modelToEntity(StaffModel model) {
    return StaffEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      phone: model.phone,
      role: model.role,
      isActive: model.isActive,
      createdAt: model.createdAt != null ? DateTime.tryParse(model.createdAt!) ?? DateTime.now() : DateTime.now(),
      password: model.password,
      branchId: model.branchId,
      permissions: model.permissions,
    );
  }

  static StaffModel entityToModel(StaffEntity entity) {
    return StaffModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      role: entity.role,
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
      password: entity.password,
      branchId: entity.branchId,
      permissions: entity.permissions,
    );
  }
}
