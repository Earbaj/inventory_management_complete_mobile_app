abstract class ReportsEvent {
  const ReportsEvent();
}

/// Event: Fetches reports summary metrics and sales invoice logs.
class FetchReportsEvent extends ReportsEvent {
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? branchId;

  const FetchReportsEvent({
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.branchId,
  });
}

/// Event: Filters invoice logs by date range (Today, This Week, This Month).
class FilterReportsByDateRangeEvent extends ReportsEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? branchId;

  const FilterReportsByDateRangeEvent({
    this.startDate,
    this.endDate,
    this.branchId,
  });
}
