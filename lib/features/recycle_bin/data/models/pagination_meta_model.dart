import '../../domain/entities/pagination_meta_entity.dart';
import 'trash_item_model.dart';

/// DTO Model for backend pagination metadata.
class PaginationMetaModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const PaginationMetaModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationMetaModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaginationMetaModel(
        total: 0,
        page: 1,
        limit: 10,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    }

    final page = (json['page'] as num?)?.toInt() ?? 1;
    final limit = (json['limit'] as num?)?.toInt() ?? 10;
    final total = (json['total'] as num?)?.toInt() ?? 0;
    final totalPages = (json['totalPages'] as num?)?.toInt() ?? (total > 0 ? (total / limit).ceil() : 1);
    final hasNextPage = json['hasNextPage'] as bool? ?? (page < totalPages);
    final hasPrevPage = json['hasPrevPage'] as bool? ?? (page > 1);

    return PaginationMetaModel(
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
      hasNextPage: hasNextPage,
      hasPrevPage: hasPrevPage,
    );
  }

  PaginationMetaEntity toEntity() {
    return PaginationMetaEntity(
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
      hasNextPage: hasNextPage,
      hasPrevPage: hasPrevPage,
    );
  }
}

/// DTO Model for paginated trash items response.
class PaginatedTrashModel {
  final List<TrashItemModel> items;
  final PaginationMetaModel meta;

  const PaginatedTrashModel({
    required this.items,
    required this.meta,
  });

  factory PaginatedTrashModel.fromJson(dynamic response) {
    if (response is List) {
      final items = response.map((e) => TrashItemModel.fromJson(e as Map<String, dynamic>)).toList();
      return PaginatedTrashModel(
        items: items,
        meta: PaginationMetaModel(
          total: items.length,
          page: 1,
          limit: items.isEmpty ? 10 : items.length,
          totalPages: 1,
          hasNextPage: false,
          hasPrevPage: false,
        ),
      );
    }

    if (response is Map<String, dynamic>) {
      final List rawData = response['data'] ?? response['items'] ?? [];
      final items = rawData.map((e) => TrashItemModel.fromJson(e as Map<String, dynamic>)).toList();
      final meta = PaginationMetaModel.fromJson(response['meta'] as Map<String, dynamic>?);
      return PaginatedTrashModel(
        items: items,
        meta: meta,
      );
    }

    return PaginatedTrashModel(
      items: const [],
      meta: PaginationMetaModel.fromJson(null),
    );
  }

  PaginatedTrashEntity toEntity() {
    return PaginatedTrashEntity(
      items: items.map((m) => m.toEntity()).toList(),
      meta: meta.toEntity(),
    );
  }
}
