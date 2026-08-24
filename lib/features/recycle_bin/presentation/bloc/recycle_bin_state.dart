import '../../domain/entities/pagination_meta_entity.dart';
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
  final PaginationMetaEntity meta;
  final String activeFilter;
  final String searchQuery;
  final bool isLoadingMore;
  final bool hasReachedMax;

  const RecycleBinLoadedState({
    required this.items,
    required this.meta,
    this.activeFilter = 'all',
    this.searchQuery = '',
    this.isLoadingMore = false,
    this.hasReachedMax = false,
  });

  List<TrashItemEntity> get filteredItems {
    if (activeFilter == 'all') return items;
    return items.where((i) => i.entityType.toLowerCase() == activeFilter.toLowerCase()).toList();
  }

  RecycleBinLoadedState copyWith({
    List<TrashItemEntity>? items,
    PaginationMetaEntity? meta,
    String? activeFilter,
    String? searchQuery,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return RecycleBinLoadedState(
      items: items ?? this.items,
      meta: meta ?? this.meta,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
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
