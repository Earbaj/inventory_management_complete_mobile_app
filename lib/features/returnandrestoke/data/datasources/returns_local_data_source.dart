import '../models/return_item_model.dart';

abstract class ReturnsLocalDataSource {
  Future<void> cacheReturnLogs(List<ReturnItemModel> returns);
  Future<List<ReturnItemModel>> getCachedReturnLogs();
  Future<bool> isCacheValid();
  Future<void> clearCache();
}

class ReturnsLocalDataSourceImpl implements ReturnsLocalDataSource {
  static List<ReturnItemModel>? _cachedReturns;
  static DateTime? _lastCacheTime;

  /// 5 Minutes Time-To-Live (TTL) Cache Expiry Duration
  static const Duration _cacheTtl = Duration(minutes: 5);

  @override
  Future<bool> isCacheValid() async {
    if (_cachedReturns == null || _lastCacheTime == null) {
      return false;
    }
    final difference = DateTime.now().difference(_lastCacheTime!);
    return difference < _cacheTtl;
  }

  @override
  Future<void> cacheReturnLogs(List<ReturnItemModel> returns) async {
    _cachedReturns = List.from(returns);
    _lastCacheTime = DateTime.now();
  }

  @override
  Future<List<ReturnItemModel>> getCachedReturnLogs() async {
    final valid = await isCacheValid();
    if (!valid) {
      // 5 Minutes TTL Expired -> Purge cache to free RAM memory
      _cachedReturns = null;
      _lastCacheTime = null;
      return [];
    }

    return _cachedReturns ?? [];
  }

  @override
  Future<void> clearCache() async {
    _cachedReturns = null;
    _lastCacheTime = null;
  }
}
