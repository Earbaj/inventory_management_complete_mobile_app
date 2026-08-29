import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/route/app_route.dart';
import '../../../../core/widgets/global_empty_placeholder.dart';
import '../../../../core/widgets/global_warning_dialog.dart';
import '../bloc/recycle_bin_bloc.dart';
import '../bloc/recycle_bin_event.dart';
import '../bloc/recycle_bin_state.dart';
import '../widget/recycle_bin_shimmer.dart';
import '../widget/trash_item_card.dart';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';

  final List<(String, String)> _filterOptions = [
    ('all', 'All Records'),
    ('item', 'Products'),
    ('customer', 'Customers'),
    ('sale', 'Sales Invoices'),
    ('return', 'Returns'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      context.read<RecycleBinBloc>().add(const LoadMoreTrashItemsEvent());
    }
  }

  void _onSearchChanged(BuildContext context, String query) {
    context.read<RecycleBinBloc>().add(FetchTrashItemsEvent(
      entityType: _selectedFilter,
      search: query,
      page: 1,
    ));
  }

  void _onFilterSelected(BuildContext context, String filterKey) {
    setState(() {
      _selectedFilter = filterKey;
    });
    context.read<RecycleBinBloc>().add(FetchTrashItemsEvent(
      entityType: filterKey,
      search: _searchController.text,
      page: 1,
    ));
  }

  Future<void> _onRefresh(BuildContext context) async {
    context.read<RecycleBinBloc>().add(FetchTrashItemsEvent(
      entityType: _selectedFilter,
      search: _searchController.text,
      page: 1,
      isRefresh: true,
      forceRefresh: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            AppRoute.shellScaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
        ),
        title: const  Text('Recycle Bin'),
        actions: [
          IconButton(
            tooltip: 'Empty Recycle Bin',
            onPressed: () => _confirmEmptyTrash(context),
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
          ),
          IconButton(
            tooltip: 'Clean 90-day Audit Logs',
            onPressed: () => _confirmCleanupLogs(context),
            icon: const Icon(Icons.cleaning_services_rounded),
          ),
          IconButton(
            onPressed: () {
              context.read<RecycleBinBloc>().add(FetchTrashItemsEvent(
                entityType: _selectedFilter,
                search: _searchController.text,
                page: 1,
                isRefresh: true,
                forceRefresh: true,
              ));
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<RecycleBinBloc, RecycleBinState>(
        listener: (context, state) {
          if (state is RecycleBinOperationSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          } else if (state is RecycleBinErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          final loadedState = state is RecycleBinLoadedState ? state : null;
          final isInitialLoading = state is RecycleBinLoadingState;
          final isListLoading = loadedState?.isListLoading == true;

          if (state is RecycleBinErrorState && state.previousItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_off_rounded,
                        color: colorScheme.error,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Failed to Load Recycle Bin',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message.isNotEmpty
                          ? state.message
                          : 'Unable to connect to database or fetch deleted items.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<RecycleBinBloc>().add(FetchTrashItemsEvent(
                          entityType: _selectedFilter,
                          search: _searchController.text,
                          page: 1,
                          forceRefresh: true,
                        ));
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final trashItems = loadedState?.filteredItems ?? [];
          final meta = loadedState?.meta;

          return Column(
            children: [
              // SEARCH HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => _onSearchChanged(context, val),
                  decoration: InputDecoration(
                    hintText: 'Search deleted items, customers or invoices...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged(context, '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // FILTER CHIPS & META COUNTER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filterOptions.map((opt) {
                            final (key, label) = opt;
                            final isSelected = _selectedFilter == key;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(label),
                                selected: isSelected,
                                onSelected: (_) => _onFilterSelected(context, key),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    if (meta != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${meta.total} items',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // RECYCLE BIN LIST WITH SHIMMER & PAGINATION
              Expanded(
                child: (isInitialLoading || isListLoading)
                    ? const RecycleBinShimmerView()
                    : trashItems.isEmpty
                        ? const GlobalEmptyPlaceholder(
                            title: 'Recycle Bin is Empty',
                            subtitle: 'No soft-deleted records match your search or filter.',
                          )
                        : RefreshIndicator(
                            onRefresh: () => _onRefresh(context),
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: trashItems.length + (loadedState?.isLoadingMore == true ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == trashItems.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2.5),
                                      ),
                                    ),
                                  );
                                }

                                final item = trashItems[index];
                                return TrashItemCard(
                                  item: item,
                                  onRestore: () {
                                    context.read<RecycleBinBloc>().add(
                                      RestoreTrashItemEvent(
                                        entityType: item.entityType,
                                        id: item.id,
                                        title: item.title,
                                      ),
                                    );
                                  },
                                  onPermanentDelete: () {
                                    context.read<RecycleBinBloc>().add(
                                      PermanentDeleteTrashItemEvent(
                                        entityType: item.entityType,
                                        id: item.id,
                                        title: item.title,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmEmptyTrash(BuildContext context) {
    GlobalWarningDialog.show(
      context,
      title: 'Empty Recycle Bin?',
      message: 'Are you sure you want to permanently delete all items in the Recycle Bin?\n\n⚠️ WARNING: This action cannot be undone.',
      confirmText: 'Empty Bin',
      cancelText: 'Cancel',
      confirmColor: Colors.red.shade700,
      icon: Icons.delete_sweep_rounded,
      onConfirm: () async {
        final bloc = context.read<RecycleBinBloc>();
        bloc.add(const EmptyTrashEvent());
      },
    );
  }

  void _confirmCleanupLogs(BuildContext context) {
    GlobalWarningDialog.show(
      context,
      title: 'Cleanup Old Audit Logs?',
      message: 'Are you sure you want to purge audit activity logs older than 90 days to free up database storage?',
      confirmText: 'Purge Logs',
      cancelText: 'Cancel',
      confirmColor: Colors.orange.shade800,
      icon: Icons.cleaning_services_rounded,
      onConfirm: () async {
        final bloc = context.read<RecycleBinBloc>();
        bloc.add(const CleanupAuditLogsEvent(days: 90));
      },
    );
  }
}
