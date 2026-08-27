import '../models/inventory_item_model.dart';

abstract class InventoryLocalDataSource {
  Future<void> cacheItems(List<InventoryItemModel> items);
  Future<List<InventoryItemModel>> getCachedItems();
  Future<List<InventoryItemModel>> getItems();
  Future<bool> isCacheValid();
  Future<void> clearCache();
  Future<InventoryItemModel?> getItemById(String id);
  Future<void> updateItem(InventoryItemModel item);
}

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  static List<InventoryItemModel>? _cachedItems;
  static DateTime? _lastCacheTime;

  /// 5 Minutes Time-To-Live (TTL) Cache Expiry Duration
  static const Duration _cacheTtl = Duration(minutes: 5);

  @override
  Future<bool> isCacheValid() async {
    if (_cachedItems == null || _lastCacheTime == null) {
      return false;
    }
    final difference = DateTime.now().difference(_lastCacheTime!);
    return difference < _cacheTtl;
  }

  @override
  Future<void> cacheItems(List<InventoryItemModel> items) async {
    _cachedItems = List.from(items);
    _lastCacheTime = DateTime.now();
  }

  @override
  Future<List<InventoryItemModel>> getCachedItems() async {
    final valid = await isCacheValid();
    if (!valid) {
      // 5 Minutes TTL Expired -> Purge cache to free RAM memory
      _cachedItems = null;
      _lastCacheTime = null;
      return [];
    }

    return _cachedItems ?? [];
  }

  @override
  Future<List<InventoryItemModel>> getItems() => getCachedItems();

  @override
  Future<void> clearCache() async {
    _cachedItems = null;
    _lastCacheTime = null;
  }

  @override
  Future<InventoryItemModel?> getItemById(String id) async {
    if (_cachedItems == null) return null;
    final index = _cachedItems!.indexWhere((item) => item.id == id);
    if (index != -1) {
      return _cachedItems![index];
    }
    return null;
  }

  @override
  Future<void> updateItem(InventoryItemModel item) async {
    if (_cachedItems == null) {
      _cachedItems = [item];
      _lastCacheTime = DateTime.now();
      return;
    }
    final index = _cachedItems!.indexWhere((el) => el.id == item.id);
    if (index != -1) {
      _cachedItems![index] = item;
    } else {
      _cachedItems!.add(item);
    }
  }
}
