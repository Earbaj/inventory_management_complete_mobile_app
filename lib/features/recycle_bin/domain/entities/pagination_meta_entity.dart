import 'trash_item_entity.dart';

/// Domain Entity representing backend pagination metadata.
class PaginationMetaEntity {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const PaginationMetaEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationMetaEntity.empty() {
    return const PaginationMetaEntity(
      total: 0,
      page: 1,
      limit: 10,
      totalPages: 1,
      hasNextPage: false,
      hasPrevPage: false,
    );
  }
}

/// Domain Entity wrapper for paginated trash items result.
class PaginatedTrashEntity {
  final List<TrashItemEntity> items;
  final PaginationMetaEntity meta;

  const PaginatedTrashEntity({
    required this.items,
    required this.meta,
  });
}
