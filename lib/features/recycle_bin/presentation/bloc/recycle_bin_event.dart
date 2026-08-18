abstract class RecycleBinEvent {
  const RecycleBinEvent();
}

/// Event: Fetches soft-deleted items list from Recycle Bin.
class FetchTrashItemsEvent extends RecycleBinEvent {
  final String? entityType;
  final String? search;

  const FetchTrashItemsEvent({
    this.entityType,
    this.search,
  });
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
