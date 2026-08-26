import 'dart:developer' as developer;
import '../datasources/supplier_remote_data_source.dart';
import '../datasources/supplier_local_data_source.dart';
import '../models/supplier_model.dart';
import '../models/purchase_order_model.dart';
import '../../../inventory/data/datasources/inventory_local_data_source.dart';

abstract class SupplierRepository {
  Future<List<SupplierModel>> getSuppliers({String? search});
  Future<SupplierModel> getSupplierById(String id);
  Future<SupplierModel> createSupplier(SupplierModel supplier);
  Future<SupplierModel> updateSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String id);
  Future<PurchaseOrderModel> createPurchaseOrder(PurchaseOrderModel order);
  Future<List<PurchaseOrderModel>> getPurchaseOrders({String? supplierId});
}

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
  Future<List<SupplierModel>> getSuppliers({String? search}) async {
    try {
      final remoteList = await remoteDataSource.getSuppliers(search: search);
      for (final s in remoteList) {
        await localDataSource.saveSupplier(s);
      }
      return remoteList;
    } catch (e) {
      developer.log('⚠️ Network failed, fallback to local suppliers: $e', name: 'SupplierRepository');
      return localDataSource.getSuppliers(search: search);
    }
  }

  @override
  Future<SupplierModel> getSupplierById(String id) async {
    try {
      final remote = await remoteDataSource.getSupplierById(id);
      await localDataSource.saveSupplier(remote);
      return remote;
    } catch (e) {
      final local = await localDataSource.getSupplierById(id);
      if (local != null) return local;
      throw Exception('Supplier not found.');
    }
  }

  @override
  Future<SupplierModel> createSupplier(SupplierModel supplier) async {
    try {
      final created = await remoteDataSource.createSupplier(supplier);
      await localDataSource.saveSupplier(created);
      return created;
    } catch (e) {
      developer.log('⚠️ Network failed creating supplier, saving locally: $e', name: 'SupplierRepository');
      final newId = 'sup_${DateTime.now().millisecondsSinceEpoch}';
      final localSup = supplier.copyWith(id: newId);
      await localDataSource.saveSupplier(localSup);
      return localSup;
    }
  }

  @override
  Future<SupplierModel> updateSupplier(SupplierModel supplier) async {
    try {
      final updated = await remoteDataSource.updateSupplier(supplier);
      await localDataSource.saveSupplier(updated);
      return updated;
    } catch (e) {
      developer.log('⚠️ Network failed updating supplier, updating locally: $e', name: 'SupplierRepository');
      await localDataSource.saveSupplier(supplier);
      return supplier;
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
  Future<PurchaseOrderModel> createPurchaseOrder(PurchaseOrderModel order) async {
    PurchaseOrderModel finalOrder;
    try {
      finalOrder = await remoteDataSource.createPurchaseOrder(order);
      await localDataSource.savePurchaseOrder(finalOrder);
    } catch (e) {
      developer.log('⚠️ Network failed creating purchase order, saving locally: $e', name: 'SupplierRepository');
      final newId = 'po_${DateTime.now().millisecondsSinceEpoch}';
      finalOrder = PurchaseOrderModel(
        id: newId,
        supplierId: order.supplierId,
        supplierName: order.supplierName,
        items: order.items,
        totalAmount: order.totalAmount,
        paidAmount: order.paidAmount,
        dueAmount: order.dueAmount,
        note: order.note,
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

    return finalOrder;
  }

  @override
  Future<List<PurchaseOrderModel>> getPurchaseOrders({String? supplierId}) async {
    try {
      final remoteList = await remoteDataSource.getPurchaseOrders(supplierId: supplierId);
      for (final po in remoteList) {
        await localDataSource.savePurchaseOrder(po);
      }
      return remoteList;
    } catch (e) {
      return localDataSource.getPurchaseOrders(supplierId: supplierId);
    }
  }
}
