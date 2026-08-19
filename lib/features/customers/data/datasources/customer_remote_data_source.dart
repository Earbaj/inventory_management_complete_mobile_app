import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/config/env_config.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
  });
  Future<CustomerModel> getCustomerDetails(String customerId);
  Future<CustomerModel> addCustomer(CustomerModel customer);
  Future<CustomerModel> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String customerId);
  Future<void> collectCustomerPayment({
    required String customerId,
    required double amount,
    String paymentMethod = 'cash',
    String? note,
  });
  Future<Map<String, dynamic>> getCustomerLedger({
    required String customerId,
    int page = 1,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Map<String, dynamic>> getDueReminderLink(String customerId);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final ApiClient apiClient;

  CustomerRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CustomerModel>> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    developer.log('👥 [CustomerRemoteDataSource] getCustomers() page: $page, limit: $limit, search: "$search"', name: 'CustomerRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/customers',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      final List list = response is List ? response : (response['customers'] ?? response['data'] ?? []);
      developer.log('✅ [CustomerRemoteDataSource] getCustomers() success. Parsed ${list.length} customers.', name: 'CustomerRemoteDataSource');
      return list.map((json) => CustomerModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('❌ [CustomerRemoteDataSource] getCustomers() API Error: $e', name: 'CustomerRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<CustomerModel> getCustomerDetails(String customerId) async {
    developer.log('👥 [CustomerRemoteDataSource] getCustomerDetails() customerId: "$customerId"', name: 'CustomerRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/customers/$customerId',
      );
      developer.log('✅ [CustomerRemoteDataSource] getCustomerDetails() success.', name: 'CustomerRemoteDataSource');
      return CustomerModel.fromJson(response is Map<String, dynamic> ? response : {});
    } catch (e, stackTrace) {
      developer.log('❌ [CustomerRemoteDataSource] getCustomerDetails() API Error: $e', name: 'CustomerRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<CustomerModel> addCustomer(CustomerModel customer) async {
    developer.log('👥 [CustomerRemoteDataSource] addCustomer() called for customer: "${customer.name}" (Phone: ${customer.phone})', name: 'CustomerRemoteDataSource');
    try {
      final response = await apiClient.post(
        '${EnvConfig.apiBaseUrl}/api/customers',
        body: customer.toJson(),
      );

      developer.log('✅ [CustomerRemoteDataSource] addCustomer() success.', name: 'CustomerRemoteDataSource');
      return CustomerModel.fromJson(response is Map<String, dynamic> ? response : customer.toJson());
    } catch (e, stackTrace) {
      developer.log('❌ [CustomerRemoteDataSource] addCustomer() API Error: $e', name: 'CustomerRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    developer.log('👥 [CustomerRemoteDataSource] updateCustomer() called for customerId: "${customer.id}"', name: 'CustomerRemoteDataSource');
    try {
      final response = await apiClient.put(
        '${EnvConfig.apiBaseUrl}/api/customers/${customer.id}',
        body: customer.toJson(),
      );

      developer.log('✅ [CustomerRemoteDataSource] updateCustomer() success.', name: 'CustomerRemoteDataSource');
      return CustomerModel.fromJson(response is Map<String, dynamic> ? response : customer.toJson());
    } catch (e, stackTrace) {
      developer.log('❌ [CustomerRemoteDataSource] updateCustomer() API Error: $e', name: 'CustomerRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    developer.log('👥 [CustomerRemoteDataSource] deleteCustomer() called for customerId: "$customerId"', name: 'CustomerRemoteDataSource');
    try {
      await apiClient.delete(
        '${EnvConfig.apiBaseUrl}/api/customers/$customerId',
      );
      developer.log('✅ [CustomerRemoteDataSource] deleteCustomer() success.', name: 'CustomerRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [CustomerRemoteDataSource] deleteCustomer() API Error: $e', name: 'CustomerRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> collectCustomerPayment({
    required String customerId,
    required double amount,
    String paymentMethod = 'cash',
    String? note,
  }) async {
    developer.log('👥 [CustomerRemoteDataSource] collectCustomerPayment() called for customerId: "$customerId", amount: ৳$amount', name: 'CustomerRemoteDataSource');
    try {
      await apiClient.post(
        '${EnvConfig.apiBaseUrl}/api/payments',
        body: {
          'customerId': customerId,
          'amount': amount,
          'paymentMethod': paymentMethod,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      developer.log('✅ [CustomerRemoteDataSource] collectCustomerPayment() success.', name: 'CustomerRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [CustomerRemoteDataSource] collectCustomerPayment() API Error: $e', name: 'CustomerRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getCustomerLedger({
    required String customerId,
    int page = 1,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    developer.log('👥 [CustomerRemoteDataSource] getCustomerLedger() customerId: "$customerId"', name: 'CustomerRemoteDataSource');
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/customers/$customerId/ledger',
        queryParameters: queryParams,
      );
      developer.log('✅ [CustomerRemoteDataSource] getCustomerLedger() success.', name: 'CustomerRemoteDataSource');
      return response is Map<String, dynamic> ? response : {'data': response};
    } catch (e, stackTrace) {
      developer.log('❌ [CustomerRemoteDataSource] getCustomerLedger() API Error: $e', name: 'CustomerRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getDueReminderLink(String customerId) async {
    developer.log('👥 [CustomerRemoteDataSource] getDueReminderLink() customerId: "$customerId"', name: 'CustomerRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/customers/$customerId/due-reminder-link',
      );
      developer.log('✅ [CustomerRemoteDataSource] getDueReminderLink() success.', name: 'CustomerRemoteDataSource');
      return response is Map<String, dynamic> ? response : {};
    } catch (e, stackTrace) {
      developer.log('❌ [CustomerRemoteDataSource] getDueReminderLink() API Error: $e', name: 'CustomerRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
