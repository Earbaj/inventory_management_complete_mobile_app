abstract class ReportsEvent {
  const ReportsEvent();
}

/// Event: Fetches reports summary metrics and sales invoice logs.
class FetchReportsEvent extends ReportsEvent {
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const FetchReportsEvent({
    this.searchQuery,
    this.startDate,
    this.endDate,
  });
}

/// Event: Filters invoice logs by date range (Today, This Week, This Month).
class FilterReportsByDateRangeEvent extends ReportsEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterReportsByDateRangeEvent({
    this.startDate,
    this.endDate,
  });
}
