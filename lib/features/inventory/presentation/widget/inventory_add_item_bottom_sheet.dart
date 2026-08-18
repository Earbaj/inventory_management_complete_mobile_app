import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/barcode_scanner_service.dart';
import '../../inventory_item.dart';
import 'iinventory_add_item_sub_widget.dart';

class AddItemSheet
    extends StatefulWidget {

  final InventoryItem? existingItem;

  final ValueChanged<InventoryItem>
  onSave;

  const AddItemSheet({
    this.existingItem,
    required this.onSave,
  });

  @override
  State<AddItemSheet> createState() =>
      _AddItemSheetState();
}

class _AddItemSheetState
    extends State<AddItemSheet> {

  final formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  nameController;

  late final TextEditingController
  skuController;

  late final TextEditingController
  lowStockController;

  late final TextEditingController
  sellPriceController;

  late final TextEditingController
  purchasePriceController;

  late final TextEditingController
  stockController;

  String category = 'Accessories';
  String unit = 'Piece';

  final categories = const [
    'Accessories',
    'Monitor',
    'Storage',
    'Furniture',
    'Electronics',
    'Other',
  ];

  final units = const [
    'Piece',
    'Box',
    'Pack',
    'Kg',
    'Liter',
    'Dozen',
  ];

  @override
  void initState() {
    super.initState();

    final item = widget.existingItem;

    nameController =
        TextEditingController(
          text: item?.name ?? '',
        );

    skuController =
        TextEditingController(
          text: item?.sku ?? '',
        );

    lowStockController =
        TextEditingController(
          text: item?.lowStockQuantity
              .toString() ??
              '',
        );

    sellPriceController =
        TextEditingController(
          text: item?.retailSellPrice
              .toString() ??
              '',
        );

    purchasePriceController =
        TextEditingController(
          text: item?.purchasePrice
              .toString() ??
              '',
        );

    stockController =
        TextEditingController(
          text: item?.stockQuantity
              .toString() ??
              '',
        );

    if (item != null) {
      category = item.category;
      unit = item.unit;
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

    final editing =
        widget.existingItem != null;

    return Container(
      height:
      MediaQuery.sizeOf(context)
          .height *
          0.92,

      decoration: BoxDecoration(
        color: colorScheme.surface,

        borderRadius:
        const BorderRadius.vertical(
          top: Radius.circular(25),
        ),
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
                borderRadius:
                BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Row(
                children: [

                  Expanded(
                    child: Text(
                      editing
                          ? 'Edit Item'
                          : 'Add New Item',

                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            Expanded(
              child: Form(
                key: formKey,

                child: ListView(
                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    20,
                  ),

                  children: [

                    // ======================
                    // BASIC INFORMATION
                    // ======================

                    const FormSectionTitle(
                      title:
                      'Basic Information',
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller:
                      nameController,

                      textInputAction:
                      TextInputAction.next,

                      decoration:
                      const InputDecoration(
                        labelText: 'Item Name',
                        hintText:
                        'e.g. Wireless Mouse',
                        prefixIcon: Icon(
                          Icons.inventory_2_outlined,
                        ),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Item name is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller:
                      skuController,

                      textInputAction:
                      TextInputAction.next,

                      decoration: InputDecoration(
                        labelText: 'SKU / Barcode',
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

                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'SKU / Barcode is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [

                        Expanded(
                          child:
                          DropdownButtonFormField<
                              String>(
                            initialValue:
                            category,

                            decoration:
                            const InputDecoration(
                              labelText:
                              'Category',
                              prefixIcon:
                              Icon(
                                Icons
                                    .category_outlined,
                              ),
                            ),

                            items:
                            categories
                                .map(
                                  (value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                  ),
                                );
                              },
                            ).toList(),

                            onChanged:
                                (value) {
                              if (value !=
                                  null) {
                                setState(() {
                                  category =
                                      value;
                                });
                              }
                            },
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child:
                          DropdownButtonFormField<
                              String>(
                            initialValue: unit,

                            decoration:
                            const InputDecoration(
                              labelText:
                              'Unit',
                              prefixIcon:
                              Icon(
                                Icons
                                    .straighten_outlined,
                              ),
                            ),

                            items:
                            units
                                .map(
                                  (value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                  ),
                                );
                              },
                            ).toList(),

                            onChanged:
                                (value) {
                              if (value !=
                                  null) {
                                setState(() {
                                  unit =
                                      value;
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

                    const FormSectionTitle(
                      title:
                      'Stock Information',
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller:
                      stockController,

                      keyboardType:
                      TextInputType.number,

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Stock Quantity',
                        hintText: '0',
                        prefixIcon:
                        Icon(
                          Icons
                              .inventory_outlined,
                        ),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {
                          return 'Stock quantity is required';
                        }

                        if (int.tryParse(
                          value,
                        ) ==
                            null) {
                          return 'Enter a valid quantity';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller:
                      lowStockController,

                      keyboardType:
                      TextInputType.number,

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Low Stock Quantity',
                        hintText:
                        'e.g. 10',
                        prefixIcon:
                        Icon(
                          Icons
                              .warning_amber_outlined,
                        ),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {
                          return 'Low stock quantity is required';
                        }

                        if (int.tryParse(
                          value,
                        ) ==
                            null) {
                          return 'Enter a valid quantity';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 22),

                    // ======================
                    // PRICE
                    // ======================

                    const FormSectionTitle(
                      title:
                      'Pricing',
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller:
                      purchasePriceController,

                      keyboardType:
                      const TextInputType
                          .numberWithOptions(
                        decimal: true,
                      ),

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Purchase Price',
                        hintText:
                        'e.g. 650',
                        prefixText: '৳ ',
                        prefixIcon:
                        Icon(
                          Icons
                              .shopping_cart_outlined,
                        ),
                      ),

                      validator: _validatePrice,
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller:
                      sellPriceController,

                      keyboardType:
                      const TextInputType
                          .numberWithOptions(
                        decimal: true,
                      ),

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Retail Sell Price',
                        hintText:
                        'e.g. 850',
                        prefixText: '৳ ',
                        prefixIcon:
                        Icon(
                          Icons
                              .sell_outlined,
                        ),
                      ),

                      validator: _validatePrice,
                    ),

                    const SizedBox(height: 25),

                    // ======================
                    // SAVE
                    // ======================

                    SizedBox(
                      height: 54,

                      child: FilledButton.icon(
                        onPressed: _saveItem,

                        icon: Icon(
                          editing
                              ? Icons
                              .save_outlined
                              : Icons
                              .add_rounded,
                        ),

                        label: Text(
                          editing
                              ? 'Update Item'
                              : 'Add Item',

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w700,
                          ),
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

  String? _validatePrice(
      String? value,
      ) {

    if (value == null ||
        value.trim().isEmpty) {
      return 'Price is required';
    }

    if (double.tryParse(value) ==
        null) {
      return 'Enter a valid price';
    }

    if (double.parse(value) < 0) {
      return 'Price cannot be negative';
    }

    return null;
  }

  void _saveItem() {

    if (!formKey.currentState!
        .validate()) {
      return;
    }

    final oldItem =
        widget.existingItem;

    final item = InventoryItem(
      id: oldItem?.id ??
          DateTime.now()
              .millisecondsSinceEpoch
              .toString(),

      name: nameController.text.trim(),

      sku: skuController.text.trim(),

      category: category,

      unit: unit,

      lowStockQuantity:
      int.parse(
        lowStockController.text,
      ),

      stockQuantity:
      int.parse(
        stockController.text,
      ),

      retailSellPrice:
      double.parse(
        sellPriceController.text,
      ),

      purchasePrice:
      double.parse(
        purchasePriceController.text,
      ),
    );

    widget.onSave(item);
  }
}