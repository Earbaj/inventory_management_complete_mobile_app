import '../../domain/entities/return_item_entity.dart';
import '../models/return_item_model.dart';

/// Translator mapping between Return DTO Model and Domain Entity.
class ReturnsMapper {
  static ReturnItemEntity modelToEntity(ReturnItemModel model) {
    return ReturnItemEntity(
      id: model.id,
      invoiceNo: model.invoiceNo,
      itemId: model.itemId,
      itemName: model.itemName,
      customerName: model.customerName,
      returnQuantity: model.returnQuantity,
      unitPrice: model.unitPrice,
      totalRefundAmount: model.totalRefundAmount,
      refundMethod: model.refundMethod,
      isRestocked: model.isRestocked,
      reason: model.reason,
      createdAt: model.createdAt != null ? DateTime.tryParse(model.createdAt!) ?? DateTime.now() : DateTime.now(),
    );
  }

  static ReturnItemModel entityToModel(ReturnItemEntity entity) {
    return ReturnItemModel(
      id: entity.id,
      invoiceNo: entity.invoiceNo,
      itemId: entity.itemId,
      itemName: entity.itemName,
      customerName: entity.customerName,
      returnQuantity: entity.returnQuantity,
      unitPrice: entity.unitPrice,
      totalRefundAmount: entity.totalRefundAmount,
      refundMethod: entity.refundMethod,
      isRestocked: entity.isRestocked,
      reason: entity.reason,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
