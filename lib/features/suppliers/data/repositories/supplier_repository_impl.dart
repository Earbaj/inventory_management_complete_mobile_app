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
  Future<List<SupplierEntity>> getSuppliers({String? search, bool forceRefresh = false}) async {
    try {
      final remoteList = await remoteDataSource.getSuppliers(search: search, forceRefresh: forceRefresh);
      final orders = await getPurchaseOrders(forceRefresh: forceRefresh);

      // Compute totalPurchases and dueAmount dynamically for each supplier from their purchase orders!
      final updatedList = remoteList.map((sup) {
        final supOrders = orders.where((o) => o.supplierId == sup.id).toList();
        if (supOrders.isNotEmpty) {
          final double total = supOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
          final double due = supOrders.fold(0.0, (sum, o) => sum + o.dueAmount);
          return sup.copyWith(
            totalPurchases: total,
            dueAmount: due,
          );
        }
        return sup;
      }).toList();

      for (final s in updatedList) {
        await localDataSource.saveSupplier(s);
      }
      return updatedList.map(SupplierMapper.supplierToEntity).toList();
    } catch (e) {
      developer.log('⚠️ Network failed, fallback to local suppliers: $e', name: 'SupplierRepository');
      final localList = await localDataSource.getSuppliers(search: search);
      final orders = await getPurchaseOrders();

      final updatedLocalList = localList.map((sup) {
        final supOrders = orders.where((o) => o.supplierId == sup.id).toList();
        if (supOrders.isNotEmpty) {
          final double total = supOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
          final double due = supOrders.fold(0.0, (sum, o) => sum + o.dueAmount);
          return sup.copyWith(
            totalPurchases: total,
            dueAmount: due,
          );
        }
        return sup;
      }).toList();

      return updatedLocalList.map(SupplierMapper.supplierToEntity).toList();
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
        poNumber: 'PO-${DateTime.now().millisecondsSinceEpoch % 100000}',
        supplierId: model.supplierId,
        supplierName: model.supplierName,
        items: model.items,
        totalAmount: model.totalAmount,
        paidAmount: model.paidAmount,
        dueAmount: model.dueAmount,
        status: 'received',
        note: model.note,
        createdAt: DateTime.now(),
      );
      await localDataSource.savePurchaseOrder(finalOrder);
    }

    // Auto update supplier's totalPurchases & dueAmount locally
    try {
      final sup = await localDataSource.getSupplierById(finalOrder.supplierId);
      if (sup != null) {
        final updatedSup = sup.copyWith(
          totalPurchases: sup.totalPurchases + finalOrder.totalAmount,
          dueAmount: sup.dueAmount + finalOrder.dueAmount,
        );
        await localDataSource.saveSupplier(updatedSup);
      }
    } catch (_) {}

    // Invalidate local inventory cache so fresh inventory is fetched from backend
    try {
      await inventoryLocalDataSource.clearCache();
    } catch (_) {}

    return SupplierMapper.orderToEntity(finalOrder);
  }

  @override
  Future<List<PurchaseOrderEntity>> getPurchaseOrders({String? supplierId, bool forceRefresh = false}) async {
    try {
      final remoteList = await remoteDataSource.getPurchaseOrders(supplierId: supplierId, forceRefresh: forceRefresh);
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
