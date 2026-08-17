import '../models/sale_model.dart';

abstract class PosLocalDataSource {
  Future<void> cacheSales(List<SaleModel> sales);
  Future<List<SaleModel>> getCachedSales();
  Future<bool> isCacheValid();
  Future<void> clearCache();
}

class PosLocalDataSourceImpl implements PosLocalDataSource {
  static List<SaleModel>? _cachedSales;
  static DateTime? _lastCacheTime;

  /// 5 Minutes Time-To-Live (TTL) Cache Expiry Duration
  static const Duration _cacheTtl = Duration(minutes: 5);

  @override
  Future<bool> isCacheValid() async {
    if (_cachedSales == null || _lastCacheTime == null) {
      return false;
    }
    final difference = DateTime.now().difference(_lastCacheTime!);
    return difference < _cacheTtl;
  }

  @override
  Future<void> cacheSales(List<SaleModel> sales) async {
    _cachedSales = List.from(sales);
    _lastCacheTime = DateTime.now();
  }

  @override
  Future<List<SaleModel>> getCachedSales() async {
    final valid = await isCacheValid();
    if (!valid) {
      // 5 Minutes TTL Expired -> Purge cache to free RAM memory
      _cachedSales = null;
      _lastCacheTime = null;
      return [];
    }

    return _cachedSales ?? [];
  }

  @override
  Future<void> clearCache() async {
    _cachedSales = null;
    _lastCacheTime = null;
  }
}
