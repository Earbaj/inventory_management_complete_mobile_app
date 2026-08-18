import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../bloc/recycle_bin_bloc.dart';
import '../bloc/recycle_bin_event.dart';
import '../bloc/recycle_bin_state.dart';
import '../widget/trash_item_card.dart';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  StreamSubscription<RecycleBinState>? _blocSubscription;

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
    _blocSubscription = InjectionContainer.recycleBinBloc.stream.listen((state) {
      if (!mounted) return;
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
    });

    InjectionContainer.recycleBinBloc.add(const FetchTrashItemsEvent());
  }

  @override
  void dispose() {
    _blocSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    InjectionContainer.recycleBinBloc.add(FetchTrashItemsEvent(
      entityType: _selectedFilter,
      search: query,
    ));
  }

  void _onFilterSelected(String filterKey) {
    setState(() {
      _selectedFilter = filterKey;
    });
    InjectionContainer.recycleBinBloc.add(FetchTrashItemsEvent(
      entityType: filterKey,
      search: _searchController.text,
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
        title: const Row(
          children: [
            Icon(Icons.delete_sweep_rounded, size: 24),
            SizedBox(width: 8),
            Text('Recycle Bin'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              InjectionContainer.recycleBinBloc.add(FetchTrashItemsEvent(
                entityType: _selectedFilter,
                search: _searchController.text,
              ));
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Recycle Bin',
          ),
        ],
      ),
      body: StreamBuilder<RecycleBinState>(
        stream: InjectionContainer.recycleBinBloc.stream,
        initialData: InjectionContainer.recycleBinBloc.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is RecycleBinLoadingState && state is! RecycleBinLoadedState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RecycleBinErrorState) {
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
                          : 'Unable to connect to database or fetch trash items.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        InjectionContainer.recycleBinBloc.add(FetchTrashItemsEvent(
                          entityType: _selectedFilter,
                          search: _searchController.text,
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

          final loadedState = state is RecycleBinLoadedState ? state : null;
          final trashItems = loadedState?.filteredItems ?? [];

          return Column(
            children: [
              // SEARCH HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search deleted items, customers or invoices',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
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

              // FILTER CHIPS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: _filterOptions.map((opt) {
                    final (key, label) = opt;
                    final isSelected = _selectedFilter == key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) => _onFilterSelected(key),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),

              // RECYCLE BIN LIST
              Expanded(
                child: trashItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restore_from_trash_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Recycle Bin is Empty',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'No soft-deleted records match your filter criteria.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: trashItems.length,
                        itemBuilder: (context, index) {
                          final item = trashItems[index];
                          return TrashItemCard(
                            item: item,
                            onRestore: () {
                              InjectionContainer.recycleBinBloc.add(
                                RestoreTrashItemEvent(
                                  entityType: item.entityType,
                                  id: item.id,
                                  title: item.title,
                                ),
                              );
                            },
                            onPermanentDelete: () {
                              InjectionContainer.recycleBinBloc.add(
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
            ],
          );
        },
      ),
    );
  }
}
