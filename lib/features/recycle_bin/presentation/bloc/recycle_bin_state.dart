import '../../domain/entities/trash_item_entity.dart';

abstract class RecycleBinState {
  const RecycleBinState();
}

class RecycleBinInitialState extends RecycleBinState {
  const RecycleBinInitialState();
}

class RecycleBinLoadingState extends RecycleBinState {
  const RecycleBinLoadingState();
}

class RecycleBinLoadedState extends RecycleBinState {
  final List<TrashItemEntity> items;
  final String activeFilter;
  final String searchQuery;

  const RecycleBinLoadedState({
    required this.items,
    this.activeFilter = 'all',
    this.searchQuery = '',
  });

  List<TrashItemEntity> get filteredItems {
    if (activeFilter == 'all') return items;
    return items.where((i) => i.entityType.toLowerCase() == activeFilter.toLowerCase()).toList();
  }
}

class RecycleBinOperationSuccessState extends RecycleBinState {
  final String message;

  const RecycleBinOperationSuccessState(this.message);
}

class RecycleBinErrorState extends RecycleBinState {
  final String message;

  const RecycleBinErrorState(this.message);
}
