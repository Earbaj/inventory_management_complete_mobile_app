import '../../domain/entities/return_item_entity.dart';

abstract class ReturnsEvent {
  const ReturnsEvent();
}

/// Event: Fetches return transaction logs history.
class FetchReturnLogsEvent extends ReturnsEvent {
  final String? searchQuery;

  const FetchReturnLogsEvent([this.searchQuery]);
}

/// Event: Processes a new item return transaction & restocks inventory.
class ProcessReturnItemEvent extends ReturnsEvent {
  final ReturnItemEntity returnItem;

  const ProcessReturnItemEvent(this.returnItem);
}
