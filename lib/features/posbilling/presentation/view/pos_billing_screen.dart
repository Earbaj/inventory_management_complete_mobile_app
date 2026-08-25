import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../../core/services/barcode_scanner_service.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../inventory/presentation/bloc/inventory_event.dart';
import '../../../inventory/presentation/bloc/inventory_state.dart';
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
  StreamSubscription<PosState>? _posSubscription;
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch events
    InjectionContainer.inventoryBloc.add(const FetchInventoryItemsEvent());
    InjectionContainer.customerBloc.add(const FetchCustomersEvent());

    discountController.addListener(() {
      final value = double.tryParse(discountController.text) ?? 0.0;
      InjectionContainer.posBloc.add(ApplyDiscountEvent(value));
    });

    _posSubscription = InjectionContainer.posBloc.stream.listen((state) {
      if (!mounted) return;
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
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _posSubscription?.cancel();
    searchController.dispose();
    discountController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      InjectionContainer.inventoryBloc.add(
        FetchInventoryItemsEvent(
          searchQuery: query,
          category: selectedCategory,
        ),
      );
    });
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
        title: const Text('POS Billing'),
        actions: [
          IconButton(
            onPressed: () {
              InjectionContainer.posBloc.add(const ClearCartEvent());
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
                        if (scannedCode != null && scannedCode.isNotEmpty) {
                          searchController.text = scannedCode;
                          setState(() {});

                          final invState = InjectionContainer.inventoryBloc.state;
                          if (invState is InventoryLoadedState) {
                            final matchingItem = invState.items.firstWhere(
                              (item) => item.sku.toLowerCase() == scannedCode.toLowerCase() || item.name.toLowerCase() == scannedCode.toLowerCase(),
                              orElse: () => invState.items.first,
                            );

                            InjectionContainer.posBloc.add(AddToCartEvent(matchingItem));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Scanned & Added "${matchingItem.name}" to Cart!'), backgroundColor: Colors.green.shade700),
                            );
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

          // CATEGORIES & PRODUCT LIST (Streamed from InventoryBloc)
          Expanded(
            child: StreamBuilder<InventoryState>(
              stream: InjectionContainer.inventoryBloc.stream,
              initialData: InjectionContainer.inventoryBloc.state,
              builder: (context, snapshot) {
                final state = snapshot.data;

                if (state is InventoryLoadingState && state is! InventoryLoadedState) {
                  return const Center(child: CircularProgressIndicator());
                }

                final loadedState = state is InventoryLoadedState ? state : null;
                final allProducts = loadedState?.items ?? [];
                final categories = ['All', ...allProducts.map((e) => e.category).toSet()];

                final query = searchController.text.trim().toLowerCase();
                final filteredProducts = allProducts.where((p) {
                  final matchesSearch = query.isEmpty || p.name.toLowerCase().contains(query) || p.sku.toLowerCase().contains(query);
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
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                              InjectionContainer.inventoryBloc.add(
                                FetchInventoryItemsEvent(
                                  searchQuery: searchController.text,
                                  category: category,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // PRODUCT LIST
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? const Center(
                              child: Text(
                                'No products available',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : StreamBuilder<PosState>(
                              stream: InjectionContainer.posBloc.stream,
                              initialData: InjectionContainer.posBloc.state,
                              builder: (context, posSnapshot) {
                                final posState = posSnapshot.data is PosCartState ? posSnapshot.data as PosCartState : const PosCartState(cartItems: []);

                                return ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  itemCount: filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = filteredProducts[index];
                                    final cartIndex = posState.cartItems.indexWhere((element) => element.item.id == product.id);
                                    final quantity = cartIndex != -1 ? posState.cartItems[cartIndex].quantity : 0;

                                    return ProductCard(
                                      product: product,
                                      quantity: quantity,
                                      onAdd: () {
                                        InjectionContainer.posBloc.add(AddToCartEvent(product));
                                      },
                                      onIncrease: () {
                                        InjectionContainer.posBloc.add(AddToCartEvent(product));
                                      },
                                      onDecrease: () {
                                        InjectionContainer.posBloc.add(UpdateCartQuantityEvent(
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

      // CART & CHECKOUT BOTTOM PANEL (Refactored to Scaffold bottomNavigationBar)
      bottomNavigationBar: StreamBuilder<PosState>(
        stream: InjectionContainer.posBloc.stream,
        initialData: InjectionContainer.posBloc.state,
        builder: (context, snapshot) {
          final posState = snapshot.data is PosCartState ? snapshot.data as PosCartState : const PosCartState(cartItems: []);

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
                  // CUSTOMER SELECTION STREAM (Explicit height 48 to prevent Dropdown layout assertions)
                  StreamBuilder<CustomerState>(
                    stream: InjectionContainer.customerBloc.stream,
                    initialData: InjectionContainer.customerBloc.state,
                    builder: (context, custSnapshot) {
                      final custState = custSnapshot.data is CustomerLoadedState ? custSnapshot.data as CustomerLoadedState : null;
                      final customerList = custState?.customers ?? [];

                      CustomerEntity? selectedVal;
                      if (posState.selectedCustomer != null) {
                        final matchIndex = customerList.indexWhere((c) => c.id == posState.selectedCustomer!.id);
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
                              InjectionContainer.posBloc.add(SelectPosCustomerEvent(cust));
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
                              '${posState.totalItemCount} Items',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '৳${posState.netTotal.toStringAsFixed(2)}',
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
                          onPressed: posState.cartItems.isEmpty
                              ? null
                              : () {
                                  _openCheckoutSheet(context, posState);
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
    );
  }

  void _openCheckoutSheet(BuildContext context, PosCartState posState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CheckOutSheet(
          cartItems: posState.cartItems,
          customer: posState.selectedCustomer,
          subtotal: posState.subtotal,
          discountController: discountController,
          onComplete: (paymentMethod, paidAmount) {
            Navigator.pop(context);

            InjectionContainer.posBloc.add(SubmitCheckoutEvent(
              paymentMethod: paymentMethod,
              paidAmount: paidAmount,
            ));
          },
        );
      },
    );
  }
}