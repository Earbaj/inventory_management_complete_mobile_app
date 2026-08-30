import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../core/di/injection_container.dart';
import '../../../inventory/data/models/inventory_item_model.dart';
import '../../../inventory/presentation/widget/inventory_add_item_bottom_sheet.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../../domain/entities/supplier_entity.dart';

class NewPurchaseOrderSheet extends StatefulWidget {
  final List<SupplierEntity> suppliers;
  final Future<void> Function(PurchaseOrderEntity) onSave;

  const NewPurchaseOrderSheet({
    super.key,
    required this.suppliers,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required List<SupplierEntity> suppliers,
    required Future<void> Function(PurchaseOrderEntity) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewPurchaseOrderSheet(
        suppliers: suppliers,
        onSave: onSave,
      ),
    );
  }

  @override
  State<NewPurchaseOrderSheet> createState() => _NewPurchaseOrderSheetState();
}

class _NewPurchaseOrderSheetState extends State<NewPurchaseOrderSheet> {
  final _formKey = GlobalKey<FormState>();
  late SupplierEntity _selectedSupplier;
  final _qtyCtrl = TextEditingController(text: '10');
  final _costCtrl = TextEditingController(text: '100');
  final _paidCtrl = TextEditingController(text: '0');
  final _noteCtrl = TextEditingController();

  List<InventoryItemModel> _inventoryItems = [];
  String? _selectedItemId;
  String _selectedItemName = '';
  bool _isLoadingItems = true;
  bool _isSubmitting = false;
  String _paymentType = 'due'; // 'paid', 'due', 'partial'

  @override
  void initState() {
    super.initState();
    _selectedSupplier = widget.suppliers.first;
    _loadInventoryItems();
  }

  Future<void> _loadInventoryItems() async {
    try {
      final items = await InjectionContainer.inventoryLocalDataSource.getItems();
      if (mounted) {
        setState(() {
          _inventoryItems = items;
          if (items.isNotEmpty) {
            _selectedItemId = items.first.id;
            _selectedItemName = items.first.name;
            _costCtrl.text = items.first.purchasePrice > 0
                ? items.first.purchasePrice.toStringAsFixed(0)
                : '100';
            _updateCalculations();
          }
          _isLoadingItems = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingItems = false);
      }
    }
  }

  void _openAddNewItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddItemSheet(
        onSave: (newItem) async {
          final model = InventoryItemModel(
            id: newItem.id.isNotEmpty ? newItem.id : 'item_${DateTime.now().millisecondsSinceEpoch}',
            name: newItem.name,
            sku: newItem.sku,
            category: newItem.category,
            unit: newItem.unit,
            stockQuantity: newItem.stockQuantity,
            lowStockQuantity: newItem.lowStockQuantity,
            purchasePrice: newItem.purchasePrice,
            retailSellPrice: newItem.retailSellPrice,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          );
          try {
            await InjectionContainer.inventoryRemoteDataSource.addItem(model);
          } catch (_) {}
          setState(() {
            _inventoryItems.insert(0, model);
            _selectedItemId = model.id;
            _selectedItemName = model.name;
            _costCtrl.text = model.purchasePrice.toStringAsFixed(0);
            _updateCalculations();
          });
        },
      ),
    );
  }

  void _updateCalculations() {
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final unitCost = double.tryParse(_costCtrl.text.trim()) ?? 0.0;
    final total = qty * unitCost;

    if (_paymentType == 'paid') {
      _paidCtrl.text = total.toStringAsFixed(0);
    } else if (_paymentType == 'due') {
      _paidCtrl.text = '0';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _costCtrl.dispose();
    _paidCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;
    final unitCost = double.tryParse(_costCtrl.text.trim()) ?? 0.0;
    final total = qty * unitCost;
    final paid = double.tryParse(_paidCtrl.text.trim()) ?? 0.0;
    final due = total - paid > 0 ? total - paid : 0.0;

    setState(() => _isSubmitting = true);

    final orderItem = PurchaseOrderItemEntity(
      itemId: _selectedItemId ?? 'item_${DateTime.now().millisecondsSinceEpoch}',
      itemName: _selectedItemName.isNotEmpty ? _selectedItemName : 'পণ্য',
      quantity: qty,
      unitCost: unitCost,
      totalPrice: total,
    );

    final order = PurchaseOrderEntity(
      id: 'PO_${DateTime.now().millisecondsSinceEpoch}',
      supplierId: _selectedSupplier.id,
      supplierName: _selectedSupplier.name,
      items: [orderItem],
      totalAmount: total,
      paidAmount: paid,
      dueAmount: due,
      note: _noteCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await widget.onSave(order);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.86;

    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final unitCost = double.tryParse(_costCtrl.text.trim()) ?? 0.0;
    final total = qty * unitCost;
    final paid = double.tryParse(_paidCtrl.text.trim()) ?? 0.0;
    final due = total - paid > 0 ? total - paid : 0.0;

    return PopScope(
      canPop: !_isSubmitting,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SafeArea(
            top: false,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Drag Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Compact Header Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.add_shopping_cart_rounded,
                          color: colorScheme.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Purchase Order',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Purchase items from supplier and add stock',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),

                  // Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Supplier Select
                          DropdownButtonFormField<SupplierEntity>(
                            initialValue: _selectedSupplier,
                            decoration: InputDecoration(
                              labelText: 'Select Supplier *',
                              prefixIcon: const Icon(Icons.business_outlined, size: 20),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: widget.suppliers.map((sup) {
                              return DropdownMenuItem(
                                value: sup,
                                child: Text(
                                  '${sup.name} (${sup.companyName.isNotEmpty ? sup.companyName : "Individual"})',
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: _isSubmitting
                                ? null
                                : (val) {
                                    if (val != null) {
                                      setState(() => _selectedSupplier = val);
                                    }
                                  },
                          ),
                          const SizedBox(height: 12),

                          // 2. Product Item Header + "+ Add New Product" Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Select Product Item:',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              InkWell(
                                onTap: _isSubmitting ? null : _openAddNewItemSheet,
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_circle_outline_rounded, size: 15, color: colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '+ Add New Product',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Product Item Dropdown
                          if (_isLoadingItems)
                            const LinearProgressIndicator()
                          else if (_inventoryItems.isNotEmpty)
                            DropdownButtonFormField<String>(
                              initialValue: _selectedItemId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                hintText: 'Choose inventory item',
                                prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: _inventoryItems.map((item) {
                                return DropdownMenuItem(
                                  value: item.id,
                                  child: Text(
                                    '${item.name} (${item.stockQuantity} ${item.unit} in stock)',
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: _isSubmitting
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        final selected = _inventoryItems.firstWhere((i) => i.id == val);
                                        setState(() {
                                          _selectedItemId = selected.id;
                                          _selectedItemName = selected.name;
                                          _costCtrl.text = selected.purchasePrice > 0
                                              ? selected.purchasePrice.toStringAsFixed(0)
                                              : '100';
                                        });
                                        _updateCalculations();
                                      }
                                    },
                            )
                          else
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Item Name *',
                                hintText: 'e.g. Sugar 50kg bag',
                                prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (val) => _selectedItemName = val,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter item name';
                                return null;
                              },
                            ),
                          const SizedBox(height: 12),

                          // 3. Quantity & Rate Row
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _qtyCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Quantity (Qty) *',
                                    prefixIcon: const Icon(Icons.format_list_numbered_rounded, size: 20),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    filled: true,
                                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (_) => _updateCalculations(),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'Enter quantity';
                                    final parsed = int.tryParse(val.trim());
                                    if (parsed == null || parsed <= 0) return 'Enter a valid number';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _costCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Buy Price / Unit Cost (${MoneyUtil.currencySymbol}) *',
                                    prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    filled: true,
                                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (_) => _updateCalculations(),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'Enter unit price';
                                    final parsed = double.tryParse(val.trim());
                                    if (parsed == null || parsed <= 0) return 'Enter a valid price';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 4. Payment Type Toggle (Full Due / Full Paid)
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Full Due', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  selected: _paymentType == 'due',
                                  selectedColor: Colors.red.shade100,
                                  visualDensity: VisualDensity.compact,
                                  avatar: Icon(
                                    Icons.money_off_rounded,
                                    size: 15,
                                    color: _paymentType == 'due' ? Colors.red.shade800 : Colors.grey,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _paymentType = 'due';
                                        _paidCtrl.text = '0';
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Full Paid', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  selected: _paymentType == 'paid',
                                  selectedColor: Colors.green.shade100,
                                  visualDensity: VisualDensity.compact,
                                  avatar: Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 15,
                                    color: _paymentType == 'paid' ? Colors.green.shade800 : Colors.grey,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _paymentType = 'paid';
                                        _paidCtrl.text = total.toStringAsFixed(0);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // 5. Summary Box (Total, Paid, Due)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total Bill:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    Text(
                                      '${MoneyUtil.currencySymbol} ${total.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _paidCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Paid Amount (${MoneyUtil.currencySymbol})',
                                    prefixIcon: const Icon(Icons.payments_outlined, size: 18),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    filled: true,
                                    fillColor: colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      final p = double.tryParse(val.trim()) ?? 0.0;
                                      if (p == 0) {
                                        _paymentType = 'due';
                                      } else if (p >= total && total > 0) {
                                        _paymentType = 'paid';
                                      } else {
                                        _paymentType = 'partial';
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      due > 0 ? 'Due Amount:' : 'Payment Status:',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      due > 0 ? '${MoneyUtil.currencySymbol} ${due.toStringAsFixed(0)} (Due)' : 'Fully Paid',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: due > 0 ? Colors.red.shade700 : Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 6. Optional Note
                          TextFormField(
                            controller: _noteCtrl,
                            decoration: InputDecoration(
                              labelText: 'Note / Voucher No (Optional)',
                              hintText: 'e.g. Invoice / PO #1042',
                              prefixIcon: const Icon(Icons.note_alt_outlined, size: 20),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary,
                          ),
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Save Purchase Order', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
