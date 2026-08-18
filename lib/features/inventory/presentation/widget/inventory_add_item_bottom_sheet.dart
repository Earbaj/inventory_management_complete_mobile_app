import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/barcode_scanner_service.dart';
import '../../inventory_item.dart';
import 'iinventory_add_item_sub_widget.dart';

class AddItemSheet extends StatefulWidget {
  final InventoryItem? existingItem;
  final Future<void> Function(InventoryItem item) onSave;

  const AddItemSheet({
    super.key,
    this.existingItem,
    required this.onSave,
  });

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController skuController;
  late final TextEditingController lowStockController;
  late final TextEditingController sellPriceController;
  late final TextEditingController purchasePriceController;
  late final TextEditingController stockController;

  String category = 'Accessories';
  String unit = 'Piece';
  List<String> categoriesList = [
    'Accessories',
    'Electronics',
    'General',
    'Monitor',
    'Storage',
    'Furniture',
  ];
  bool isLoadingCategories = true;
  bool isSaving = false;

  final units = const [
    'Piece',
    'Box',
    'Pack',
    'Kg',
    'Liter',
    'Dozen',
    'pcs',
  ];

  @override
  void initState() {
    super.initState();

    final item = widget.existingItem;

    nameController = TextEditingController(text: item?.name ?? '');
    skuController = TextEditingController(text: item?.sku ?? '');
    lowStockController = TextEditingController(text: item?.lowStockQuantity.toString() ?? '5');
    sellPriceController = TextEditingController(text: item?.retailSellPrice.toString() ?? '');
    purchasePriceController = TextEditingController(text: item?.purchasePrice.toString() ?? '');
    stockController = TextEditingController(text: item?.stockQuantity.toString() ?? '');

    if (item != null) {
      category = item.category;
      unit = item.unit;
    }

    _fetchCategoriesFromApi();
  }

  Future<void> _fetchCategoriesFromApi() async {
    try {
      final apiCategories = await InjectionContainer.inventoryRemoteDataSource.getCategories();
      if (mounted) {
        setState(() {
          final set = <String>{
            if (widget.existingItem != null) widget.existingItem!.category,
            'General',
            'Accessories',
            'Electronics',
            'Monitor',
            'Storage',
            'Furniture',
            ...apiCategories,
          };
          categoriesList = set.toList();
          if (!categoriesList.contains(category)) {
            category = categoriesList.first;
          }
          isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingCategories = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    skuController.dispose();
    lowStockController.dispose();
    sellPriceController.dispose();
    purchasePriceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final editing = widget.existingItem != null;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.92,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      editing ? 'Edit Item' : 'Add New Item',
                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: isSaving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Form(
                key: formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  children: [
                    // ======================
                    // BASIC INFORMATION
                    // ======================
                    const FormSectionTitle(title: 'Basic Information'),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Item Name *',
                        hintText: 'e.g. Wireless Mouse',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Item name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: skuController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'SKU / Barcode *',
                        hintText: 'e.g. WM-001',
                        prefixIcon: const Icon(Icons.qr_code_2_rounded),
                        suffixIcon: IconButton(
                          tooltip: 'Scan Barcode with Camera',
                          onPressed: () async {
                            final code = await BarcodeScannerService.scanBarcode(context);
                            if (code != null && code.isNotEmpty) {
                              skuController.text = code;
                            }
                          },
                          icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.cyan),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'SKU / Barcode is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        // DYNAMIC CATEGORIES FROM GET /api/categories
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: categoriesList.contains(category) ? category : categoriesList.first,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: const Icon(Icons.category_outlined),
                              suffixIcon: isLoadingCategories
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : null,
                            ),
                            items: categoriesList.map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  category = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: units.contains(unit) ? unit : units.first,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              prefixIcon: Icon(Icons.straighten_outlined),
                            ),
                            items: units.map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  unit = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ======================
                    // STOCK
                    // ======================
                    const FormSectionTitle(title: 'Stock Information'),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Quantity *',
                        hintText: '0',
                        prefixIcon: Icon(Icons.inventory_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stock quantity is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a valid quantity';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: lowStockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Low Stock Threshold *',
                        hintText: 'e.g. 5',
                        prefixIcon: Icon(Icons.warning_amber_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Low stock quantity is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a valid quantity';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 22),

                    // ======================
                    // PRICING
                    // ======================
                    const FormSectionTitle(title: 'Pricing'),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: purchasePriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Purchase / Buy Price *',
                        hintText: 'e.g. 650',
                        prefixText: '৳ ',
                        prefixIcon: Icon(Icons.shopping_cart_outlined),
                      ),
                      validator: _validatePrice,
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: sellPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Retail Sell Price *',
                        hintText: 'e.g. 850',
                        prefixText: '৳ ',
                        prefixIcon: Icon(Icons.sell_outlined),
                      ),
                      validator: _validatePrice,
                    ),

                    const SizedBox(height: 25),

                    // ======================
                    // SAVE ACTION WITH CIRCULAR LOADER
                    // ======================
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: isSaving ? null : _saveItem,
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(editing ? Icons.save_outlined : Icons.add_rounded),
                                  const SizedBox(width: 8),
                                  Text(
                                    editing ? 'Update Item' : 'Add Item',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    if (double.tryParse(value) == null) {
      return 'Enter a valid price';
    }
    if (double.parse(value) < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }

  Future<void> _saveItem() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final oldItem = widget.existingItem;

    final item = InventoryItem(
      id: oldItem?.id ?? '',
      name: nameController.text.trim(),
      sku: skuController.text.trim(),
      category: category,
      unit: unit,
      lowStockQuantity: int.parse(lowStockController.text),
      stockQuantity: int.parse(stockController.text),
      retailSellPrice: double.parse(sellPriceController.text),
      purchasePrice: double.parse(purchasePriceController.text),
    );

    try {
      await widget.onSave(item);
    } catch (e) {
      if (mounted) {
        setState(() {
          isSaving = false;
        });

        final rawMsg = e is Failure ? e.message : e.toString();
        final cleanMsg = rawMsg
            .replaceAll('Exception: ', '')
            .replaceAll('ServerFailure: ', '')
            .replaceAll('NetworkFailure: ', '');

        final isFreeTierLimit = cleanMsg.toLowerCase().contains('free tier') ||
            cleanMsg.toLowerCase().contains('limited to 5') ||
            cleanMsg.toLowerCase().contains('upgrade');

        if (isFreeTierLimit) {
          _showFreeTierLimitDialog(context, cleanMsg);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Text(cleanMsg)),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  void _showFreeTierLimitDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Free Tier Limit Reached',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.star_rounded, color: Colors.amber),
              label: const Text('Upgrade Plan'),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }
}