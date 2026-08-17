import '../models/staff_model.dart';

abstract class StaffLocalDataSource {
  Future<void> cacheStaffMembers(List<StaffModel> staffList);
  Future<List<StaffModel>> getCachedStaffMembers();
  Future<bool> isCacheValid();
  Future<void> clearCache();
}

class StaffLocalDataSourceImpl implements StaffLocalDataSource {
  static List<StaffModel>? _cachedStaff;
  static DateTime? _lastCacheTime;

  /// 5 Minutes Time-To-Live (TTL) Cache Expiry Duration
  static const Duration _cacheTtl = Duration(minutes: 5);

  @override
  Future<bool> isCacheValid() async {
    if (_cachedStaff == null || _lastCacheTime == null) {
      return false;
    }
    final difference = DateTime.now().difference(_lastCacheTime!);
    return difference < _cacheTtl;
  }

  @override
  Future<void> cacheStaffMembers(List<StaffModel> staffList) async {
    _cachedStaff = List.from(staffList);
    _lastCacheTime = DateTime.now();
  }

  @override
  Future<List<StaffModel>> getCachedStaffMembers() async {
    final valid = await isCacheValid();
    if (!valid) {
      // 5 Minutes TTL Expired -> Purge cache to free RAM memory
      _cachedStaff = null;
      _lastCacheTime = null;
      return [];
    }

    return _cachedStaff ?? [];
  }

  @override
  Future<void> clearCache() async {
    _cachedStaff = null;
    _lastCacheTime = null;
  }
}
