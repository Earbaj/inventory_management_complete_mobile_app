import '../models/supplier_model.dart';
import '../models/purchase_order_model.dart';

abstract class SupplierLocalDataSource {
  Future<List<SupplierModel>> getSuppliers({String? search});
  Future<SupplierModel?> getSupplierById(String id);
  Future<SupplierModel> saveSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String id);
  Future<PurchaseOrderModel> savePurchaseOrder(PurchaseOrderModel order);
  Future<List<PurchaseOrderModel>> getPurchaseOrders({String? supplierId});
}

class SupplierLocalDataSourceImpl implements SupplierLocalDataSource {
  final List<SupplierModel> _suppliers = [
    SupplierModel(
      id: 'sup_1',
      name: 'আবুল কাসেম (মেসার্স কাসেম ট্রেডার্স)',
      companyName: 'কাসেম ট্রেডার্স',
      phone: '01711223344',
      email: 'kashem@traders.com',
      address: 'চকবাজার, ঢাকা',
      totalPurchases: 125000.0,
      dueAmount: 15000.0,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    SupplierModel(
      id: 'sup_2',
      name: 'রহিম উল্লাহ (রহিম এন্টারপ্রাইজ)',
      companyName: 'রহিম এন্টারপ্রাইজ',
      phone: '01899887766',
      email: 'rahim@enterprise.com',
      address: 'খাতুনগঞ্জ, চট্টগ্রাম',
      totalPurchases: 84000.0,
      dueAmount: 0.0,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  final List<PurchaseOrderModel> _purchaseOrders = [];

  @override
  Future<List<SupplierModel>> getSuppliers({String? search}) async {
    if (search != null && search.trim().isNotEmpty) {
      final query = search.trim().toLowerCase();
      return _suppliers.where((s) =>
        s.name.toLowerCase().contains(query) ||
        s.companyName.toLowerCase().contains(query) ||
        s.phone.contains(query)
      ).toList();
    }
    return List.from(_suppliers);
  }

  @override
  Future<SupplierModel?> getSupplierById(String id) async {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SupplierModel> saveSupplier(SupplierModel supplier) async {
    final index = _suppliers.indexWhere((s) => s.id == supplier.id);
    if (index >= 0) {
      _suppliers[index] = supplier;
    } else {
      _suppliers.add(supplier);
    }
    return supplier;
  }

  @override
  Future<void> deleteSupplier(String id) async {
    _suppliers.removeWhere((s) => s.id == id);
  }

  @override
  Future<PurchaseOrderModel> savePurchaseOrder(PurchaseOrderModel order) async {
    _purchaseOrders.insert(0, order);
    // Update supplier totalPurchases and dueAmount
    final index = _suppliers.indexWhere((s) => s.id == order.supplierId);
    if (index >= 0) {
      final sup = _suppliers[index];
      _suppliers[index] = sup.copyWith(
        totalPurchases: sup.totalPurchases + order.totalAmount,
        dueAmount: sup.dueAmount + order.dueAmount,
      );
    }
    return order;
  }

  @override
  Future<List<PurchaseOrderModel>> getPurchaseOrders({String? supplierId}) async {
    if (supplierId != null && supplierId.isNotEmpty) {
      return _purchaseOrders.where((po) => po.supplierId == supplierId).toList();
    }
    return List.from(_purchaseOrders);
  }
}
