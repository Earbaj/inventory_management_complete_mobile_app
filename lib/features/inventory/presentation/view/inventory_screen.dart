import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_complete/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inventory_management_complete/features/inventory/presentation/bloc/inventory_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../auth/domain/entities/user_entity.dart';
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
  bool isFilterVisible = false;
  UserEntity? user;
  

  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch event to InventoryBloc
    context.read<InventoryBloc>().add(
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
  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.85, // Increased from 0.8
            ),
            padding: const EdgeInsets.all(20), // Reduced padding
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with Icon
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Category',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width > 600 ? 20 : 17, // Reduced
                              ),
                            ),
                            Text(
                              'Add a new category to organize your products',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 12, // Reduced
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16), // Reduced

                  // Category Name Field
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter category name';
                      }
                      if (value.trim().length < 2) {
                        return 'Category name must be at least 2 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      hintText: 'e.g. Electronics, Grocery, Fashion',
                      prefixIcon: Icon(
                        Icons.label_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 20, // Reduced
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14, // Reduced from 16
                      ),
                    ),
                    style: const TextStyle(fontSize: 15), // Reduced
                  ),

                  const SizedBox(height: 12), // Reduced

                  // Description Field
                  TextFormField(
                    controller: descController,
                    maxLines: 2, // Reduced from 3
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Brief description of this category...',
                      prefixIcon: Icon(
                        Icons.description_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 20, // Reduced
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14, // Reduced from 16
                      ),
                    ),
                    style: const TextStyle(fontSize: 15), // Reduced
                  ),

                  const SizedBox(height: 12), // Reduced

                  // Character Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14, // Reduced
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'All fields are optional except name',
                            style: TextStyle(
                              fontSize: 11, // Reduced
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      ValueListenableBuilder(
                        valueListenable: nameController,
                        builder: (context, value, child) {
                          return Text(
                            '${value.text.trim().length}/50',
                            style: TextStyle(
                              fontSize: 11, // Reduced
                              color: value.text.trim().length > 45
                                  ? Colors.orange
                                  : Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16), // Reduced

                  // Action Buttons - Fixed Overflow Issue
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel Button - Flexible
                      OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12, // Reduced
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          minimumSize: const Size(0, 0), // Allow smaller size
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14, // Reduced
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis, // Prevent overflow
                        ),
                      ),
                      const SizedBox(width: 10), // Reduced
                      // Create Button - Flexible
                      FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final categoryName = nameController.text.trim();
                            final description = descController.text.trim();

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Creating category...'),
                                  ],
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            InjectionContainer.inventoryBloc.add(
                              CreateCategoryEvent(
                                name: categoryName,
                                description: description.isNotEmpty ? description : null,
                              ),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12, // Reduced
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 0), // Allow smaller size
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Important for preventing overflow
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              size: 18, // Reduced
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Create Category',
                                style: TextStyle(
                                  fontSize: 14, // Reduced
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis, // Prevent overflow
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                isFilterVisible =!isFilterVisible;
              });
            },
            icon: Icon(isFilterVisible ? Icons.filter_alt_off:Icons.filter_alt),
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
      body: BlocConsumer<InventoryBloc,InventoryState>(
        listener: (context, state) {
          // SnackBar side-effects
          if (state is InventoryOperationSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is InventoryErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, snapshot) {
          final state = snapshot;

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

              if(isFilterVisible)...[
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
                    itemCount: categories.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ActionChip(
                          avatar: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Category'),
                          onPressed: () => _showAddCategoryDialog(context),
                        );
                      }

                      final category = categories[index - 1];
                      final selected = selectedCategory == category;

                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        onSelected: (_) => _onCategorySelected(category),
                      );
                    },
                  ),
                ),
              ],
              // SUMMARY
              InventorySummary(
                totalItems: totalItems,
                lowStock: lowStockCount,
                outOfStock: outOfStockCount,
                selectedFilter: selectedFilter,
                onFilterChanged: _onFilterChanged,
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
                            onDelete: () {
                              _confirmDeleteItem(context, item);
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

  void _confirmDeleteItem(BuildContext context, InventoryItemEntity item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Delete Item?'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${item.name}" (SKU: ${item.sku})?\n\nThis action will remove the item from your inventory.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.delete_forever_rounded),
              label: const Text('Delete Item'),
              onPressed: () {
                Navigator.pop(dialogContext);
                InjectionContainer.inventoryBloc.add(DeleteInventoryItemEvent(item.id));
              },
            ),
          ],
        );
      },
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
      builder: (sheetContext) {
        return AddItemSheet(
          existingItem: existingItem,
          onSave: (item) async {
            if (existingItem == null) {
              final savedItem = await InjectionContainer.addInventoryItemUseCase(item);
              InjectionContainer.inventoryBloc.add(AddInventoryItemEvent(savedItem));
            } else {
              final updatedItem = await InjectionContainer.updateInventoryItemUseCase(item);
              InjectionContainer.inventoryBloc.add(UpdateInventoryItemEvent(updatedItem));
            }

            if (sheetContext.mounted) {
              Navigator.pop(sheetContext);
            }
          },
        );
      },
    );
  }
}