import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/route/app_route.dart';
import '../../../../core/services/barcode_scanner_service.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';
import '../../../inventory/presentation/bloc/inventory_event.dart';
import '../../../inventory/presentation/bloc/inventory_state.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';
import '../bloc/pos_state.dart';
import '../widget/check_out_sheet.dart';
import '../widget/product_card.dart';
import '../widget/sale_success_dialog.dart';

class PosBillingScreen extends StatefulWidget {
  const PosBillingScreen({super.key});

  @override
  State<PosBillingScreen> createState() => _PosBillingScreenState();
}

class _PosBillingScreenState extends State<PosBillingScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  String selectedCategory = 'All';
  Timer? _searchDebounceTimer;
  String _lastRemoteSearchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch events with maximum allowed backend limit (100)
    context.read<InventoryBloc>().add(const FetchInventoryItemsEvent(limit: 100));
    context.read<CustomerBloc>().add(const FetchCustomersEvent(limit: 100));

    discountController.addListener(() {
      final value = double.tryParse(discountController.text) ?? 0.0;
      context.read<PosBloc>().add(ApplyDiscountEvent(value));
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    discountController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // 1. Instant local filter for in-memory products (0ms response)
    setState(() {});

    _searchDebounceTimer?.cancel();
    final trimmed = query.trim();

    // If query is cleared and previously searched remotely, restore top 100 items
    if (trimmed.isEmpty) {
      _isSearching = false;
      _lastRemoteSearchQuery = '';
      context.read<InventoryBloc>().add(const FetchInventoryItemsEvent(searchQuery: '', limit: 100));
      setState(() {});
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // 2. Debounced remote search fallback to search entire database if item not in initial 100
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_lastRemoteSearchQuery != trimmed) {
        _lastRemoteSearchQuery = trimmed;
        context.read<InventoryBloc>().add(
          FetchInventoryItemsEvent(
            searchQuery: trimmed,
            limit: 100,
          ),
        );
      } else {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<PosBloc, PosState>(
          listener: (context, state) {
            if (state is PosCheckoutSuccessState) {
              discountController.clear();
              showDialog(
                context: context,
                builder: (_) => SaleSuccessDialog(completedSale: state.completedSale),
              );
            } else if (state is PosCheckoutErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is InventoryLoadedState && !state.isListLoading) {
              if (_isSearching) {
                setState(() {
                  _isSearching = false;
                });
              }
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              AppRoute.shellScaffoldKey.currentState?.openDrawer();
            },
            icon: const Icon(Icons.menu_rounded),
          ),
          title: const Text('POS Billing'),
          actions: [
            IconButton(
              onPressed: () {
                context.read<PosBloc>().add(const ClearCartEvent());
                discountController.clear();
              },
              tooltip: 'Clear Cart',
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
          ],
        ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search product name or SKU',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    IconButton(
                      tooltip: 'Scan Barcode with Camera',
                      onPressed: () async {
                        final scannedCode = await BarcodeScannerService.scanBarcode(context);
                        if (!context.mounted) return;
                        if (scannedCode != null && scannedCode.isNotEmpty) {
                          searchController.text = scannedCode;
                          setState(() {});

                          final invState = context.read<InventoryBloc>().state;
                          if (invState is InventoryLoadedState) {
                            final matches = invState.items.where(
                              (item) => item.sku.toLowerCase() == scannedCode.toLowerCase() || item.name.toLowerCase() == scannedCode.toLowerCase(),
                            );

                            if (matches.isNotEmpty) {
                              final matchingItem = matches.first;
                              context.read<PosBloc>().add(AddToCartEvent(matchingItem));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Scanned & Added "${matchingItem.name}" to Cart!'), backgroundColor: Colors.green.shade700),
                              );
                            } else {
                              _lastRemoteSearchQuery = scannedCode;
                              context.read<InventoryBloc>().add(
                                FetchInventoryItemsEvent(
                                  searchQuery: scannedCode,
                                  limit: 100,
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.cyan),
                    ),
                  ],
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // CATEGORIES & PRODUCT LIST (BlocBuilder from InventoryBloc)
          Expanded(
            child: BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoadingState && state is! InventoryLoadedState) {
                  return const Center(child: CircularProgressIndicator());
                }

                final loadedState = state is InventoryLoadedState ? state : null;
                final allProducts = loadedState?.items ?? [];
                final List<String> categories;
                if (loadedState != null && loadedState.categories.isNotEmpty) {
                  categories = loadedState.categories.contains('All')
                      ? loadedState.categories
                      : ['All', ...loadedState.categories];
                } else {
                  categories = ['All', ...allProducts.map((e) => e.category.trim()).where((c) => c.isNotEmpty).toSet()];
                }

                final query = searchController.text.trim().toLowerCase();
                final filteredProducts = allProducts.where((p) {
                  final matchesSearch = query.isEmpty ||
                      p.name.toLowerCase().contains(query) ||
                      p.sku.toLowerCase().contains(query);
                  final matchesCategory = selectedCategory == 'All' || p.category == selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                return Column(
                  children: [
                    // CATEGORY CHIPS
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final selected = selectedCategory == category;

                          return ChoiceChip(
                            label: Text(category),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // PRODUCT LIST
                    Expanded(
                      child: (_isSearching && filteredProducts.isEmpty)
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 12),
                                  Text(
                                    'Searching database...',
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : filteredProducts.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No products available',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : BlocBuilder<PosBloc, PosState>(
                                  builder: (context, posState) {
                                    final cartState = posState is PosCartState ? posState : const PosCartState(cartItems: []);

                                    return ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                      itemCount: filteredProducts.length,
                                      itemBuilder: (context, index) {
                                        final product = filteredProducts[index];
                                        final cartIndex = cartState.cartItems.indexWhere((element) => element.item.id == product.id);
                                        final quantity = cartIndex != -1 ? cartState.cartItems[cartIndex].quantity : 0;

                                        return ProductCard(
                                          product: product,
                                          quantity: quantity,
                                          onAdd: () {
                                            context.read<PosBloc>().add(AddToCartEvent(product));
                                          },
                                          onIncrease: () {
                                            context.read<PosBloc>().add(AddToCartEvent(product));
                                          },
                                          onDecrease: () {
                                            context.read<PosBloc>().add(UpdateCartQuantityEvent(
                                              itemId: product.id,
                                              quantity: quantity - 1,
                                            ));
                                          },
                                          onRemove: () {},
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
          ),
        ],
      ),

      // CART & CHECKOUT BOTTOM PANEL
      bottomNavigationBar: BlocBuilder<PosBloc, PosState>(
        builder: (context, posState) {
          final cartState = posState is PosCartState ? posState : const PosCartState(cartItems: []);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CUSTOMER SELECTION BLOC BUILDER
                  BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, custState) {
                      final loadedCustState = custState is CustomerLoadedState ? custState : null;
                      final customerList = loadedCustState?.customers ?? [];

                      CustomerEntity? selectedVal;
                      if (cartState.selectedCustomer != null) {
                        final matchIndex = customerList.indexWhere((c) => c.id == cartState.selectedCustomer!.id);
                        if (matchIndex != -1) {
                          selectedVal = customerList[matchIndex];
                        }
                      }

                      return Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CustomerEntity?>(
                            isExpanded: true,
                            value: selectedVal,
                            hint: const Text('Select Customer (Optional)'),
                            items: [
                              const DropdownMenuItem<CustomerEntity?>(
                                value: null,
                                child: Text('Walk-in Customer (Guest)'),
                              ),
                              ...customerList.map((cust) {
                                return DropdownMenuItem<CustomerEntity?>(
                                  value: cust,
                                  child: Text('${cust.name} (${cust.phone})'),
                                );
                              }),
                            ],
                            onChanged: (cust) {
                              context.read<PosBloc>().add(SelectPosCustomerEvent(cust));
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // TOTALS DISPLAY & CHECKOUT BUTTON
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${cartState.totalItemCount} Items',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '৳${cartState.netTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: cartState.cartItems.isEmpty
                              ? null
                              : () {
                                  _openCheckoutSheet(context, cartState);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Checkout',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
  }

  void _openCheckoutSheet(BuildContext context, PosCartState posState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return CheckOutSheet(
          cartItems: posState.cartItems,
          customer: posState.selectedCustomer,
          subtotal: posState.subtotal,
          discountController: discountController,
          onComplete: (paymentMethod, paidAmount) {
            Navigator.pop(sheetContext);

            context.read<PosBloc>().add(SubmitCheckoutEvent(
              paymentMethod: paymentMethod,
              paidAmount: paidAmount,
            ));
          },
        );
      },
    );
  }
}