import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/supplier_model.dart';
import '../models/purchase_order_model.dart';

abstract class SupplierRemoteDataSource {
  Future<List<SupplierModel>> getSuppliers({String? search});
  Future<SupplierModel> getSupplierById(String id);
  Future<SupplierModel> createSupplier(SupplierModel supplier);
  Future<SupplierModel> updateSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String id);
  Future<PurchaseOrderModel> createPurchaseOrder(PurchaseOrderModel order);
  Future<List<PurchaseOrderModel>> getPurchaseOrders({String? supplierId});
}

class SupplierRemoteDataSourceImpl implements SupplierRemoteDataSource {
  final ApiClient apiClient;

  SupplierRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<SupplierModel>> getSuppliers({String? search}) async {
    developer.log('🚚 [SupplierRemoteDataSource] Calling GET ${ApiEndpoints.suppliers}...', name: 'SupplierRemoteDataSource');
    try {
      final response = await apiClient.get(
        ApiEndpoints.suppliers,
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      );

      final List list = response is List
          ? response
          : (response['suppliers'] ?? response['data'] ?? []);

      developer.log('✅ [SupplierRemoteDataSource] Loaded ${list.length} suppliers.', name: 'SupplierRemoteDataSource');
      return list.map((json) => SupplierModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('⚠️ [SupplierRemoteDataSource] getSuppliers error: $e', name: 'SupplierRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<SupplierModel> getSupplierById(String id) async {
    final url = ApiEndpoints.supplierById(id);
    developer.log('🚚 [SupplierRemoteDataSource] Calling GET $url...', name: 'SupplierRemoteDataSource');
    try {
      final response = await apiClient.get(url);
      final json = response is Map<String, dynamic>
          ? (response['supplier'] ?? response['data'] ?? response)
          : response;
      return SupplierModel.fromJson(json);
    } catch (e) {
      developer.log('⚠️ [SupplierRemoteDataSource] getSupplierById error: $e', name: 'SupplierRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<SupplierModel> createSupplier(SupplierModel supplier) async {
    developer.log('🚚 [SupplierRemoteDataSource] Calling POST ${ApiEndpoints.suppliers}...', name: 'SupplierRemoteDataSource');
    try {
      final response = await apiClient.post(
        ApiEndpoints.suppliers,
        body: supplier.toJson(),
      );
      final json = response is Map<String, dynamic>
          ? (response['supplier'] ?? response['data'] ?? response)
          : response;
      return SupplierModel.fromJson(json);
    } catch (e) {
      developer.log('⚠️ [SupplierRemoteDataSource] createSupplier error: $e', name: 'SupplierRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<SupplierModel> updateSupplier(SupplierModel supplier) async {
    final url = ApiEndpoints.supplierById(supplier.id);
    developer.log('🚚 [SupplierRemoteDataSource] Calling PUT $url...', name: 'SupplierRemoteDataSource');
    try {
      final response = await apiClient.put(
        url,
        body: supplier.toJson(),
      );
      final json = response is Map<String, dynamic>
          ? (response['supplier'] ?? response['data'] ?? response)
          : response;
      return SupplierModel.fromJson(json);
    } catch (e) {
      developer.log('⚠️ [SupplierRemoteDataSource] updateSupplier error: $e', name: 'SupplierRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    final url = ApiEndpoints.supplierById(id);
    developer.log('🚚 [SupplierRemoteDataSource] Calling DELETE $url...', name: 'SupplierRemoteDataSource');
    try {
      await apiClient.delete(url);
      developer.log('✅ [SupplierRemoteDataSource] Supplier $id deleted.', name: 'SupplierRemoteDataSource');
    } catch (e) {
      developer.log('⚠️ [SupplierRemoteDataSource] deleteSupplier error: $e', name: 'SupplierRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<PurchaseOrderModel> createPurchaseOrder(PurchaseOrderModel order) async {
    developer.log('📦 [SupplierRemoteDataSource] Calling POST ${ApiEndpoints.purchaseOrders}...', name: 'SupplierRemoteDataSource');
    try {
      final response = await apiClient.post(
        ApiEndpoints.purchaseOrders,
        body: order.toJson(),
      );
      final json = response is Map<String, dynamic>
          ? (response['purchaseOrder'] ?? response['order'] ?? response['data'] ?? response)
          : response;
      return PurchaseOrderModel.fromJson(json);
    } catch (e) {
      developer.log('⚠️ [SupplierRemoteDataSource] createPurchaseOrder error: $e', name: 'SupplierRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<List<PurchaseOrderModel>> getPurchaseOrders({String? supplierId}) async {
    developer.log('📦 [SupplierRemoteDataSource] Calling GET ${ApiEndpoints.purchaseOrders}...', name: 'SupplierRemoteDataSource');
    try {
      final response = await apiClient.get(
        ApiEndpoints.purchaseOrders,
        queryParameters: {
          if (supplierId != null && supplierId.isNotEmpty) 'supplierId': supplierId,
        },
      );
      final List list = response is List
          ? response
          : (response['purchaseOrders'] ?? response['orders'] ?? response['data'] ?? []);
      return list.map((json) => PurchaseOrderModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('⚠️ [SupplierRemoteDataSource] getPurchaseOrders error: $e', name: 'SupplierRemoteDataSource');
      rethrow;
    }
  }
}
