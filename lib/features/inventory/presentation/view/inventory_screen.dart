import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_complete/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inventory_management_complete/features/inventory/presentation/bloc/inventory_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../widget/inventory_add_item_bottom_sheet.dart';
import '../widget/inventory_empty_state.dart';
import '../widget/inventory_item_card.dart';
import '../widget/inventory_shimmer.dart';
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
  Timer? _searchDebounceTimer;

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
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      InjectionContainer.inventoryBloc.add(
        FetchInventoryItemsEvent(
          searchQuery: query,
          category: selectedCategory,
          filter: selectedFilter,
        ),
      );
    });
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
    bool isSubmitting = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
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
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
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
                                      fontSize: MediaQuery.of(context).size.width > 600 ? 20 : 17,
                                    ),
                                  ),
                                  Text(
                                    'Add a new category to organize your products',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        if (errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Category Name Field
                        TextFormField(
                          controller: nameController,
                          autofocus: true,
                          enabled: !isSubmitting,
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
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),

                        const SizedBox(height: 12),

                        // Description Field
                        TextFormField(
                          controller: descController,
                          maxLines: 2,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            labelText: 'Description (Optional)',
                            hintText: 'Brief description of this category...',
                            prefixIcon: Icon(
                              Icons.description_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),

                        const SizedBox(height: 12),

                        // Character Counter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'All fields are optional except name',
                                  style: TextStyle(
                                    fontSize: 11,
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
                                    fontSize: 11,
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

                        const SizedBox(height: 16),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Cancel Button
                            OutlinedButton(
                              onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                minimumSize: const Size(0, 0),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Create Button with Button Loader
                            FilledButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        final categoryName = nameController.text.trim();
                                        final description = descController.text.trim();

                                        setDialogState(() {
                                          isSubmitting = true;
                                          errorMessage = null;
                                        });

                                        try {
                                          await InjectionContainer.inventoryRemoteDataSource.createCategory(
                                            categoryName,
                                            description: description.isNotEmpty ? description : null,
                                          );

                                          InjectionContainer.inventoryBloc.add(
                                            AddCategoryLocalEvent(categoryName),
                                          );

                                          if (dialogContext.mounted) {
                                            Navigator.pop(dialogContext, categoryName);
                                          }

                                          if (context.mounted) {
                                            _onCategorySelected(categoryName);
                                          }
                                        } catch (e) {
                                          final rawErr = e.toString();
                                          if (rawErr.toLowerCase().contains('already exists') ||
                                              rawErr.contains('409') ||
                                              rawErr.toLowerCase().contains('conflict')) {
                                            InjectionContainer.inventoryBloc.add(
                                              AddCategoryLocalEvent(categoryName),
                                            );
                                            if (dialogContext.mounted) {
                                              Navigator.pop(dialogContext, categoryName);
                                            }
                                            if (context.mounted) {
                                              _onCategorySelected(categoryName);
                                            }
                                          } else {
                                            if (dialogContext.mounted) {
                                              setDialogState(() {
                                                isSubmitting = false;
                                                errorMessage = rawErr
                                                    .replaceAll('Exception: ', '')
                                                    .replaceAll('ServerFailure: ', '')
                                                    .replaceAll('NetworkFailure: ', '');
                                              });
                                            }
                                          }
                                        }
                                      }
                                    },
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 0),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_rounded,
                                          size: 18,
                                        ),
                                        SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'Create Category',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
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
              ),
            );
          },
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
            tooltip: 'Import CSV / এক্সেল ফাইল আপলোড',
            onPressed: () => _showImportCsvDialog(context),
            icon: const Icon(Icons.upload_file_rounded),
          ),
          BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, state) {
              final isRefreshing = state is InventoryLoadedState && state.isListLoading;
              return IconButton(
                tooltip: 'Refresh',
                onPressed: isRefreshing
                    ? null
                    : () {
                        InjectionContainer.inventoryBloc.add(
                          FetchInventoryItemsEvent(
                            searchQuery: searchController.text,
                            category: selectedCategory,
                            filter: selectedFilter,
                          ),
                        );
                      },
                icon: const Icon(Icons.refresh_rounded),
              );
            },
          ),
          IconButton(
            tooltip: 'Filter',
            onPressed: () {
              setState(() {
                isFilterVisible = !isFilterVisible;
              });
            },
            icon: Icon(isFilterVisible ? Icons.filter_alt_off : Icons.filter_alt),
          ),
        ],
      ),
      floatingActionButton: BlocSelector<AuthBloc, AuthState, bool>(
          selector: (state) {
            return state is AuthenticatedState &&
                state.user?.role.toLowerCase() == 'admin';
          },
        builder: (context, isAdmin) {
          if (!isAdmin) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: () {
              _openAddItemSheet();
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Item'),
          );
        }
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
            return const InventoryFullScreenShimmer();
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
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
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
                child: (loadedState != null && loadedState.isListLoading)
                    ? const InventoryListShimmer()
                    : filteredItems.isEmpty
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

            // Immediately refresh inventory categories & items so the main screen updates
            InjectionContainer.inventoryBloc.add(
              FetchInventoryItemsEvent(
                category: selectedCategory,
                searchQuery: searchController.text,
                filter: selectedFilter,
              ),
            );

            if (sheetContext.mounted) {
              Navigator.pop(sheetContext);
            }
          },
        );
      },
    );
  }

  void _showImportCsvDialog(BuildContext context) {
    final csvController = TextEditingController(
      text: 'Name,Category,SellingPrice,CostPrice,StockQuantity,Barcode\n'
          'সয়াবিন তেল ১ লিটার,গ্রোসারী,190,165,50,890123456789\n'
          'মিনিকেট চাল ২৫ কেজি,চাল ও ডাল,1650,1480,20,890987654321',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Bulk CSV Import / এক্সেল থেকে প্রোডাক্ট আপলোড'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CSV ফরম্যাটের ডাটা পেস্ট করুন (কমা দিয়ে আলাদা করা):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: csvController,
                maxLines: 8,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: 'Name,Category,SellingPrice,CostPrice,StockQuantity,Barcode...',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'টিপস: হেডার ঠিক রেখে এক্সেল ফাইল থেকে কপি করে পেস্ট করুন।',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('বাতিল'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('ইম্পোর্ট করুন'),
            onPressed: () {
              final rawText = csvController.text.trim();
              if (rawText.isEmpty) return;

              final lines = rawText.split('\n');
              if (lines.length < 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('কমপক্ষে ১ টি ডাটা লাইন থাকা আবশ্যক!')),
                );
                return;
              }

              final List<Map<String, dynamic>> items = [];
              for (int i = 1; i < lines.length; i++) {
                final line = lines[i].trim();
                if (line.isEmpty) continue;
                final parts = line.split(',');
                if (parts.isNotEmpty) {
                  items.add({
                    'name': parts[0].trim(),
                    'category': parts.length > 1 ? parts[1].trim() : 'General',
                    'sellingPrice': parts.length > 2 ? double.tryParse(parts[2].trim()) ?? 0.0 : 0.0,
                    'costPrice': parts.length > 3 ? double.tryParse(parts[3].trim()) ?? 0.0 : 0.0,
                    'quantity': parts.length > 4 ? int.tryParse(parts[4].trim()) ?? 10 : 10,
                    'barcode': parts.length > 5 ? parts[5].trim() : '',
                  });
                }
              }

              if (items.isNotEmpty) {
                InjectionContainer.inventoryBloc.add(ImportCsvEvent(items));
                Navigator.pop(dialogCtx);
              }
            },
          ),
        ],
      ),
    );
  }
}