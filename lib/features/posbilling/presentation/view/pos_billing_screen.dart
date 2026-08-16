import 'package:flutter/material.dart';

import '../../../dashboard/presentation/widgets/app_drawer.dart';
import '../../pos_customer.dart';
import '../../pos_product.dart';
import '../widget/check_out_sheet.dart';
import '../widget/product_card.dart';
import '../widget/sale_success_dialog.dart';


class PosBillingScreen extends StatefulWidget {
  const PosBillingScreen({super.key});

  @override
  State<PosBillingScreen> createState() =>
      _PosBillingScreenState();
}

class _PosBillingScreenState
    extends State<PosBillingScreen> {
  final TextEditingController searchController =
  TextEditingController();

  final TextEditingController discountController =
  TextEditingController();

  final List<PosProduct> products = const [
    PosProduct(
      id: '1',
      name: 'Wireless Mouse',
      sku: 'WM-001',
      price: 850,
      stock: 42,
      category: 'Accessories',
    ),
    PosProduct(
      id: '2',
      name: 'USB Keyboard',
      sku: 'KB-002',
      price: 1250,
      stock: 28,
      category: 'Accessories',
    ),
    PosProduct(
      id: '3',
      name: 'HD Monitor 24"',
      sku: 'MN-003',
      price: 14500,
      stock: 12,
      category: 'Monitor',
    ),
    PosProduct(
      id: '4',
      name: 'Office Chair',
      sku: 'CH-004',
      price: 7800,
      stock: 8,
      category: 'Furniture',
    ),
    PosProduct(
      id: '5',
      name: 'External HDD 1TB',
      sku: 'HD-005',
      price: 6200,
      stock: 15,
      category: 'Storage',
    ),
    PosProduct(
      id: '6',
      name: 'USB-C Cable',
      sku: 'CB-006',
      price: 450,
      stock: 75,
      category: 'Accessories',
    ),
  ];

  final List<PosCustomer> customers = const [
    PosCustomer(
      id: 'walk-in',
      name: 'Walk-in Customer',
      phone: '',
      due: 0,
    ),
    PosCustomer(
      id: 'rahim',
      name: 'Rahim',
      phone: '01712345678',
      due: 2500,
    ),
    PosCustomer(
      id: 'jahid',
      name: 'Jahid',
      phone: '01812345678',
      due: 1200,
    ),
  ];

  final Map<String, int> cart = {};

  PosCustomer? selectedCustomer;

  String selectedPayment = 'Cash';

  String selectedCategory = 'All';

  double discount = 0;

  @override
  void initState() {
    super.initState();

    selectedCustomer = customers.first;

    discountController.addListener(() {
      final value =
          double.tryParse(
            discountController.text,
          ) ??
              0;

      setState(() {
        discount = value;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    discountController.dispose();

    super.dispose();
  }

  List<PosProduct> get filteredProducts {
    final query =
    searchController.text.trim().toLowerCase();

    return products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(query) ||
              product.sku.toLowerCase().contains(query);

      final matchesCategory =
          selectedCategory == 'All' ||
              product.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> get categories {
    return [
      'All',
      ...products
          .map((product) => product.category)
          .toSet(),
    ];
  }

  List<PosProduct> get cartProducts {
    return products.where(
          (product) => cart.containsKey(product.id),
    ).toList();
  }

  double get subtotal {
    double total = 0;

    for (final product in cartProducts) {
      total +=
          product.price *
              (cart[product.id] ?? 0);
    }

    return total;
  }

  double get finalDiscount {
    if (discount < 0) {
      return 0;
    }

    if (discount > subtotal) {
      return subtotal;
    }

    return discount;
  }

  double get total {
    return subtotal - finalDiscount;
  }

  int get totalItems {
    return cart.values.fold(
      0,
          (sum, quantity) => sum + quantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      drawer: const AppDrawer(
        currentRoute: '/pos-billing',
      ),

      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu_rounded,
              ),
            );
          },
        ),

        title: const Text(
          'POS Billing',
        ),

        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                cart.clear();
                discountController.clear();
              });
            },
            tooltip: 'Clear Cart',
            icon: const Icon(
              Icons.delete_sweep_outlined,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // =========================
          // SEARCH
          // =========================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              10,
            ),
            child: TextField(
              controller: searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search product or SKU...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                ),
                suffixIcon:
                searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController.clear();

                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                )
                    : null,
                filled: true,
                fillColor:
                colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // =========================
          // CATEGORY
          // =========================

          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) =>
              const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category =
                categories[index];

                final selected =
                    selectedCategory == category;

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

          // =========================
          // PRODUCT LIST
          // =========================

          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
              child: Text(
                'No products found',
              ),
            )
                : ListView.builder(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                4,
                16,
                110,
              ),
              itemCount:
              filteredProducts.length,
              itemBuilder: (
                  context,
                  index,
                  ) {
                final product =
                filteredProducts[index];

                final quantity =
                    cart[product.id] ?? 0;

                return ProductCard(
                  product: product,
                  quantity: quantity,
                  onAdd: () {
                    _addProduct(product);
                  },
                  onRemove: () {
                    _removeProduct(product);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // =========================
      // CART BUTTON
      // =========================

      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            10,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                blurRadius: 15,
                color: Colors.black
                    .withValues(alpha: 0.08),
              ),
            ],
          ),
          child: FilledButton(
            onPressed: () {
              _openCheckoutSheet();
            },
            style: FilledButton.styleFrom(
              minimumSize:
              const Size.fromHeight(54),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius:
                    BorderRadius.circular(
                      7,
                    ),
                  ),
                  child: Text(
                    '$totalItems',
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'Review & Checkout',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),

                Text(
                  '৳ ${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addProduct(PosProduct product) {
    final currentQuantity =
        cart[product.id] ?? 0;

    if (currentQuantity >= product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Not enough stock available',
          ),
        ),
      );

      return;
    }

    setState(() {
      cart[product.id] =
          currentQuantity + 1;
    });
  }

  void _removeProduct(PosProduct product) {
    final currentQuantity =
        cart[product.id] ?? 0;

    if (currentQuantity <= 1) {
      setState(() {
        cart.remove(product.id);
      });
    } else {
      setState(() {
        cart[product.id] =
            currentQuantity - 1;
      });
    }
  }

  void _openCheckoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CheckoutSheet(
          cartProducts: cartProducts,
          cart: cart,
          subtotal: subtotal,
          discount: finalDiscount,
          total: total,
          selectedCustomer: selectedCustomer!,
          customers: customers,
          selectedPayment: selectedPayment,
          discountController: discountController,
          onCustomerChanged: (customer) {
            setState(() {
              selectedCustomer = customer;
            });
          },
          onPaymentChanged: (payment) {
            setState(() {
              selectedPayment = payment;
            });
          },
          onQuantityChanged: (
              product,
              quantity,
              ) {
            setState(() {
              if (quantity <= 0) {
                cart.remove(product.id);
              } else if (quantity <=
                  product.stock) {
                cart[product.id] = quantity;
              }
            });
          },
          onCheckout: () {
            Navigator.pop(context);
            _completeCheckout();
          },
        );
      },
    );
  }

  void _completeCheckout() {
    if (cart.isEmpty) {
      return;
    }

    // এখানে পরে Firebase/backend API call হবে।

    setState(() {
      cart.clear();
      discountController.clear();
      discount = 0;
      selectedCustomer = customers.first;
      selectedPayment = 'Cash';
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const SaleSuccessDialog();
      },
    );
  }
}