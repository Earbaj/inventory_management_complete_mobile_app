import '../models/customer_model.dart';

abstract class CustomerLocalDataSource {
  Future<void> cacheCustomers(List<CustomerModel> customers);
  Future<List<CustomerModel>> getCachedCustomers();
  Future<bool> isCacheValid();
  Future<void> clearCache();
}

class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  static List<CustomerModel>? _cachedCustomers;
  static DateTime? _lastCacheTime;

  /// 5 Minutes Time-To-Live (TTL) Cache Expiry Duration
  static const Duration _cacheTtl = Duration(minutes: 5);

  @override
  Future<bool> isCacheValid() async {
    if (_cachedCustomers == null || _lastCacheTime == null) {
      return false;
    }
    final difference = DateTime.now().difference(_lastCacheTime!);
    return difference < _cacheTtl;
  }

  @override
  Future<void> cacheCustomers(List<CustomerModel> customers) async {
    _cachedCustomers = List.from(customers);
    _lastCacheTime = DateTime.now();
  }

  @override
  Future<List<CustomerModel>> getCachedCustomers() async {
    final valid = await isCacheValid();
    if (!valid) {
      // 5 Minutes TTL Expired -> Purge cache to free RAM memory
      _cachedCustomers = null;
      _lastCacheTime = null;
      return [];
    }

    return _cachedCustomers ?? [];
  }

  @override
  Future<void> clearCache() async {
    _cachedCustomers = null;
    _lastCacheTime = null;
  }
}
