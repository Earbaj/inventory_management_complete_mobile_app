import '../../../customers/data/mappers/customer_mapper.dart';
import '../../../inventory/data/mappers/inventory_mapper.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/sale_entity.dart';
import '../models/cart_item_model.dart';
import '../models/sale_model.dart';

/// Translator mapping between POS DTO Models and Domain Entities.
class PosMapper {
  static CartItemEntity cartItemModelToEntity(CartItemModel model) {
    return CartItemEntity(
      item: InventoryMapper.modelToEntity(model.item),
      quantity: model.quantity,
      discount: model.discount,
      discountType: model.discountType,
    );
  }

  static CartItemModel cartItemEntityToModel(CartItemEntity entity) {
    return CartItemModel(
      item: InventoryMapper.entityToModel(entity.item),
      quantity: entity.quantity,
      discount: entity.discount,
      discountType: entity.discountType,
    );
  }

  static SaleEntity saleModelToEntity(SaleModel model) {
    return SaleEntity(
      id: model.id,
      invoiceNo: model.invoiceNo,
      customer: model.customer != null ? CustomerMapper.modelToEntity(model.customer!) : null,
      items: model.items.map(cartItemModelToEntity).toList(),
      subtotal: model.subtotal,
      discountAmount: model.discountAmount,
      vatAmount: model.vatAmount,
      netTotal: model.netTotal,
      paidAmount: model.paidAmount,
      dueAmount: model.dueAmount,
      paymentMethod: model.paymentMethod,
      isReturned: model.isReturned,
      createdAt: model.createdAt != null ? DateTime.tryParse(model.createdAt!) ?? DateTime.now() : DateTime.now(),
      servedBy: model.servedBy,
    );
  }

  static SaleModel saleEntityToModel(SaleEntity entity) {
    return SaleModel(
      id: entity.id,
      invoiceNo: entity.invoiceNo,
      customer: entity.customer != null ? CustomerMapper.entityToModel(entity.customer!) : null,
      items: entity.items.map(cartItemEntityToModel).toList(),
      subtotal: entity.subtotal,
      discountAmount: entity.discountAmount,
      vatAmount: entity.vatAmount,
      netTotal: entity.netTotal,
      paidAmount: entity.paidAmount,
      dueAmount: entity.dueAmount,
      paymentMethod: entity.paymentMethod,
      isReturned: entity.isReturned,
      createdAt: entity.createdAt.toIso8601String(),
      servedBy: entity.servedBy,
    );
  }
}
