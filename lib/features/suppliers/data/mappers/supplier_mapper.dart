import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../models/supplier_model.dart';
import '../models/purchase_order_model.dart';

class SupplierMapper {
  static SupplierEntity supplierToEntity(SupplierModel model) {
    return SupplierEntity(
      id: model.id,
      name: model.name,
      companyName: model.companyName,
      phone: model.phone,
      email: model.email,
      address: model.address,
      totalPurchases: model.totalPurchases,
      dueAmount: model.dueAmount,
      createdAt: model.createdAt,
    );
  }

  static SupplierModel supplierToModel(SupplierEntity entity) {
    return SupplierModel(
      id: entity.id,
      name: entity.name,
      companyName: entity.companyName,
      phone: entity.phone,
      email: entity.email,
      address: entity.address,
      totalPurchases: entity.totalPurchases,
      dueAmount: entity.dueAmount,
      createdAt: entity.createdAt,
    );
  }

  static PurchaseOrderItemEntity itemToEntity(PurchaseOrderItemModel model) {
    return PurchaseOrderItemEntity(
      itemId: model.itemId,
      itemName: model.itemName,
      quantity: model.quantity,
      unitCost: model.unitCost,
      totalPrice: model.totalPrice,
    );
  }

  static PurchaseOrderItemModel itemToModel(PurchaseOrderItemEntity entity) {
    return PurchaseOrderItemModel(
      itemId: entity.itemId,
      itemName: entity.itemName,
      quantity: entity.quantity,
      unitCost: entity.unitCost,
      totalPrice: entity.totalPrice,
    );
  }

  static PurchaseOrderEntity orderToEntity(PurchaseOrderModel model) {
    return PurchaseOrderEntity(
      id: model.id,
      supplierId: model.supplierId,
      supplierName: model.supplierName,
      items: model.items.map(itemToEntity).toList(),
      totalAmount: model.totalAmount,
      paidAmount: model.paidAmount,
      dueAmount: model.dueAmount,
      note: model.note,
      createdAt: model.createdAt,
    );
  }

  static PurchaseOrderModel orderToModel(PurchaseOrderEntity entity) {
    return PurchaseOrderModel(
      id: entity.id,
      supplierId: entity.supplierId,
      supplierName: entity.supplierName,
      items: entity.items.map(itemToModel).toList(),
      totalAmount: entity.totalAmount,
      paidAmount: entity.paidAmount,
      dueAmount: entity.dueAmount,
      note: entity.note,
      createdAt: entity.createdAt,
    );
  }
}
