import '../models/report_summary_model.dart';

abstract class ReportsLocalDataSource {
  Future<void> cacheSummary(ReportSummaryModel summary);
  Future<ReportSummaryModel?> getCachedSummary();
  Future<bool> isCacheValid();
  Future<void> clearCache();
}

class ReportsLocalDataSourceImpl implements ReportsLocalDataSource {
  static ReportSummaryModel? _cachedSummary;
  static DateTime? _lastCacheTime;

  /// 5 Minutes Time-To-Live (TTL) Cache Expiry Duration
  static const Duration _cacheTtl = Duration(minutes: 5);

  @override
  Future<bool> isCacheValid() async {
    if (_cachedSummary == null || _lastCacheTime == null) {
      return false;
    }
    final difference = DateTime.now().difference(_lastCacheTime!);
    return difference < _cacheTtl;
  }

  @override
  Future<void> cacheSummary(ReportSummaryModel summary) async {
    _cachedSummary = summary;
    _lastCacheTime = DateTime.now();
  }

  @override
  Future<ReportSummaryModel?> getCachedSummary() async {
    final valid = await isCacheValid();
    if (!valid) {
      // 5 Minutes TTL Expired -> Purge cache to free RAM memory
      _cachedSummary = null;
      _lastCacheTime = null;
      return null;
    }

    return _cachedSummary;
  }

  @override
  Future<void> clearCache() async {
    _cachedSummary = null;
    _lastCacheTime = null;
  }
}
