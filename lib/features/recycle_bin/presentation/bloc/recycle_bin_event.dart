abstract class RecycleBinEvent {
  const RecycleBinEvent();
}

/// Event: Fetches soft-deleted items list from Recycle Bin.
class FetchTrashItemsEvent extends RecycleBinEvent {
  final String? entityType;
  final String? search;
  final int page;
  final bool isRefresh;

  const FetchTrashItemsEvent({
    this.entityType,
    this.search,
    this.page = 1,
    this.isRefresh = false,
  });
}

/// Event: Triggers loading the next page of soft-deleted items.
class LoadMoreTrashItemsEvent extends RecycleBinEvent {
  const LoadMoreTrashItemsEvent();
}

/// Event: Restores a soft-deleted item.
class RestoreTrashItemEvent extends RecycleBinEvent {
  final String entityType;
  final String id;
  final String title;

  const RestoreTrashItemEvent({
    required this.entityType,
    required this.id,
    required this.title,
  });
}

/// Event: Permanently hard-deletes an item from MongoDB.
class PermanentDeleteTrashItemEvent extends RecycleBinEvent {
  final String entityType;
  final String id;
  final String title;

  const PermanentDeleteTrashItemEvent({
    required this.entityType,
    required this.id,
    required this.title,
  });
}
