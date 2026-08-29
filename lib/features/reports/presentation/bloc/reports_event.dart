import '../../reports_models.dart';

abstract class ReportsEvent {
  const ReportsEvent();
}

/// Event: Fetches reports summary metrics and sales invoice logs.
class FetchReportsEvent extends ReportsEvent {
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? branchId;
  final DateFilterType? dateFilterType;
  final bool forceRefresh;

  const FetchReportsEvent({
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.branchId,
    this.dateFilterType,
    this.forceRefresh = false,
  });
}

/// Event: Filters invoice logs by date range (Today, Yesterday, Last 7 Days, Last 30 Days, Custom Range).
class FilterReportsByDateRangeEvent extends ReportsEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? branchId;
  final DateFilterType dateFilterType;

  const FilterReportsByDateRangeEvent({
    this.startDate,
    this.endDate,
    this.branchId,
    this.dateFilterType = DateFilterType.allTime,
  });
}

/// Event: Dispatches instant in-memory search or server-side search.
class SearchReportsEvent extends ReportsEvent {
  final String query;

  const SearchReportsEvent(this.query);
}
