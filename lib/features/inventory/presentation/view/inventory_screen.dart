import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../inventory_item.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../widget/inventory_add_item_bottom_sheet.dart';
import '../widget/inventory_empty_state.dart';
import '../widget/inventory_item_card.dart';
import '../widget/inventory_summery.dart';

enum InventoryFilter {
  all,
  lowStock,
  outOfStock,
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController searchController = TextEditingController();
  InventoryFilter selectedFilter = InventoryFilter.all;
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch event to InventoryBloc
    InjectionContainer.inventoryBloc.add(
      FetchInventoryItemsEvent(
        searchQuery: '',
        category: selectedCategory,
        filter: selectedFilter,
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    InjectionContainer.inventoryBloc.add(
      FetchInventoryItemsEvent(
        searchQuery: query,
        category: selectedCategory,
        filter: selectedFilter,
      ),
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
    InjectionContainer.inventoryBloc.add(
      FetchInventoryItemsEvent(
        searchQuery: searchController.text,
        category: category,
        filter: selectedFilter,
      ),
    );
  }

  void _onFilterChanged(InventoryFilter filter) {
    setState(() {
      selectedFilter = filter;
    });
    InjectionContainer.inventoryBloc.add(
      FetchInventoryItemsEvent(
        searchQuery: searchController.text,
        category: selectedCategory,
        filter: filter,
      ),
    );
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
        title: const Text('Inventory'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              InjectionContainer.inventoryBloc.add(
                FetchInventoryItemsEvent(
                  searchQuery: searchController.text,
                  category: selectedCategory,
                  filter: selectedFilter,
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openAddItemSheet();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item'),
      ),
      body: StreamBuilder<InventoryState>(
        stream: InjectionContainer.inventoryBloc.stream,
        initialData: InjectionContainer.inventoryBloc.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is InventoryLoadingState && state is! InventoryLoadedState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InventoryErrorState) {
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
                      'Something Went Wrong',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message.isNotEmpty
                          ? state.message
                          : 'Unable to load data. Cache expired or network connection failed.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        InjectionContainer.inventoryBloc.add(
                          FetchInventoryItemsEvent(
                            searchQuery: searchController.text,
                            category: selectedCategory,
                            filter: selectedFilter,
                          ),
                        );
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

          final loadedState = state is InventoryLoadedState ? state : null;
          final totalItems = loadedState?.items.length ?? 0;
          final lowStockCount = loadedState?.lowStockCount ?? 0;
          final outOfStockCount = loadedState?.outOfStockCount ?? 0;
          final categories = loadedState?.categories ?? ['All'];
          final filteredItems = loadedState?.filteredItems ?? [];

          return Column(
            children: [
              // SUMMARY
              InventorySummary(
                totalItems: totalItems,
                lowStock: lowStockCount,
                outOfStock: outOfStockCount,
                selectedFilter: selectedFilter,
                onFilterChanged: _onFilterChanged,
              ),

              // SEARCH
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: TextField(
                  controller: searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search item name, SKU or barcode',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
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

              // CATEGORY CHIPS
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final selected = selectedCategory == category;

                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) => _onCategorySelected(category),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // ITEM LIST
              Expanded(
                child: filteredItems.isEmpty
                    ? const EmptyInventory()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];

                          return InventoryItemCard(
                            item: item,
                            onEdit: () {
                              _openAddItemSheet(existingItem: item);
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

  // ADD / EDIT ITEM BOTTOM SHEET
  void _openAddItemSheet({
    InventoryItemEntity? existingItem,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddItemSheet(
          existingItem: existingItem,
          onSave: (item) {
            if (existingItem == null) {
              InjectionContainer.inventoryBloc.add(AddInventoryItemEvent(item));
            } else {
              InjectionContainer.inventoryBloc.add(UpdateInventoryItemEvent(item));
            }

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  existingItem == null ? 'Item added successfully' : 'Item updated successfully',
                ),
              ),
            );
          },
        );
      },
    );
  }
}