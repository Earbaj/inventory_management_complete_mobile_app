import 'dart:developer' as developer;
import '../../domain/repositories/supplier_repository.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../datasources/supplier_remote_data_source.dart';
import '../datasources/supplier_local_data_source.dart';
import '../models/purchase_order_model.dart';
import '../mappers/supplier_mapper.dart';
import '../../../inventory/data/datasources/inventory_local_data_source.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDataSource remoteDataSource;
  final SupplierLocalDataSource localDataSource;
  final InventoryLocalDataSource inventoryLocalDataSource;

  SupplierRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.inventoryLocalDataSource,
  });

  @override
  Future<List<SupplierEntity>> getSuppliers({String? search}) async {
    try {
      final remoteList = await remoteDataSource.getSuppliers(search: search);
      for (final s in remoteList) {
        await localDataSource.saveSupplier(s);
      }
      return remoteList.map(SupplierMapper.supplierToEntity).toList();
    } catch (e) {
      developer.log('⚠️ Network failed, fallback to local suppliers: $e', name: 'SupplierRepository');
      final localList = await localDataSource.getSuppliers(search: search);
      return localList.map(SupplierMapper.supplierToEntity).toList();
    }
  }

  @override
  Future<SupplierEntity> getSupplierById(String id) async {
    try {
      final remote = await remoteDataSource.getSupplierById(id);
      await localDataSource.saveSupplier(remote);
      return SupplierMapper.supplierToEntity(remote);
    } catch (e) {
      final local = await localDataSource.getSupplierById(id);
      if (local != null) return SupplierMapper.supplierToEntity(local);
      throw Exception('Supplier not found.');
    }
  }

  @override
  Future<SupplierEntity> createSupplier(SupplierEntity supplier) async {
    final model = SupplierMapper.supplierToModel(supplier);
    try {
      final created = await remoteDataSource.createSupplier(model);
      await localDataSource.saveSupplier(created);
      return SupplierMapper.supplierToEntity(created);
    } catch (e) {
      developer.log('⚠️ Network failed creating supplier, saving locally: $e', name: 'SupplierRepository');
      final newId = 'sup_${DateTime.now().millisecondsSinceEpoch}';
      final localSup = model.copyWith(id: newId);
      await localDataSource.saveSupplier(localSup);
      return SupplierMapper.supplierToEntity(localSup);
    }
  }

  @override
  Future<SupplierEntity> updateSupplier(SupplierEntity supplier) async {
    final model = SupplierMapper.supplierToModel(supplier);
    try {
      final updated = await remoteDataSource.updateSupplier(model);
      await localDataSource.saveSupplier(updated);
      return SupplierMapper.supplierToEntity(updated);
    } catch (e) {
      developer.log('⚠️ Network failed updating supplier, updating locally: $e', name: 'SupplierRepository');
      await localDataSource.saveSupplier(model);
      return SupplierMapper.supplierToEntity(model);
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      await remoteDataSource.deleteSupplier(id);
    } catch (e) {
      developer.log('⚠️ Network failed deleting supplier: $e', name: 'SupplierRepository');
    } finally {
      await localDataSource.deleteSupplier(id);
    }
  }

  @override
  Future<PurchaseOrderEntity> createPurchaseOrder(PurchaseOrderEntity order) async {
    final model = SupplierMapper.orderToModel(order);
    PurchaseOrderModel finalOrder;
    try {
      finalOrder = await remoteDataSource.createPurchaseOrder(model);
      await localDataSource.savePurchaseOrder(finalOrder);
    } catch (e) {
      developer.log('⚠️ Network failed creating purchase order, saving locally: $e', name: 'SupplierRepository');
      final newId = 'po_${DateTime.now().millisecondsSinceEpoch}';
      finalOrder = PurchaseOrderModel(
        id: newId,
        supplierId: model.supplierId,
        supplierName: model.supplierName,
        items: model.items,
        totalAmount: model.totalAmount,
        paidAmount: model.paidAmount,
        dueAmount: model.dueAmount,
        note: model.note,
        createdAt: DateTime.now(),
      );
      await localDataSource.savePurchaseOrder(finalOrder);
    }

    // Auto-restock inventory items stock quantity!
    for (final item in finalOrder.items) {
      try {
        final existingItem = await inventoryLocalDataSource.getItemById(item.itemId);
        if (existingItem != null) {
          final updatedItem = existingItem.copyWith(
            quantity: existingItem.quantity + item.quantity,
            costPrice: item.unitCost > 0 ? item.unitCost : existingItem.costPrice,
          );
          await inventoryLocalDataSource.updateItem(updatedItem);
          developer.log('✅ Auto-restocked ${item.itemName}: +${item.quantity} (New Qty: ${updatedItem.quantity})', name: 'SupplierRepository');
        }
      } catch (err) {
        developer.log('⚠️ Error restocking item ${item.itemId}: $err', name: 'SupplierRepository');
      }
    }

    return SupplierMapper.orderToEntity(finalOrder);
  }

  @override
  Future<List<PurchaseOrderEntity>> getPurchaseOrders({String? supplierId}) async {
    try {
      final remoteList = await remoteDataSource.getPurchaseOrders(supplierId: supplierId);
      for (final po in remoteList) {
        await localDataSource.savePurchaseOrder(po);
      }
      return remoteList.map(SupplierMapper.orderToEntity).toList();
    } catch (e) {
      final localList = await localDataSource.getPurchaseOrders(supplierId: supplierId);
      return localList.map(SupplierMapper.orderToEntity).toList();
    }
  }
}
