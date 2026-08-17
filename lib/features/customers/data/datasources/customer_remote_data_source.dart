import '../../../../core/network/api_client.dart';
import '../../../../core/config/env_config.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers({String? search});
  Future<CustomerModel> addCustomer(CustomerModel customer);
  Future<CustomerModel> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String customerId);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final ApiClient apiClient;

  CustomerRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CustomerModel>> getCustomers({String? search}) async {
    final response = await apiClient.get(
      '${EnvConfig.apiBaseUrl}/api/customers',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final List list = response is List ? response : (response['customers'] ?? response['data'] ?? []);
    return list.map((json) => CustomerModel.fromJson(json)).toList();
  }

  @override
  Future<CustomerModel> addCustomer(CustomerModel customer) async {
    final response = await apiClient.post(
      '${EnvConfig.apiBaseUrl}/api/customers',
      body: customer.toJson(),
    );

    return CustomerModel.fromJson(response is Map<String, dynamic> ? response : customer.toJson());
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    final response = await apiClient.post(
      '${EnvConfig.apiBaseUrl}/api/customers/${customer.id}',
      body: customer.toJson(),
    );

    return CustomerModel.fromJson(response is Map<String, dynamic> ? response : customer.toJson());
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    await apiClient.post(
      '${EnvConfig.apiBaseUrl}/api/customers/$customerId/delete',
    );
  }
}
