import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../data/mappers/supplier_mapper.dart';
import 'purchase_order_receipt_dialog.dart';

class SupplierDetailsSheet extends StatefulWidget {
  final SupplierEntity supplier;

  const SupplierDetailsSheet({
    super.key,
    required this.supplier,
  });

  static Future<void> show(BuildContext context, SupplierEntity supplier) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SupplierDetailsSheet(supplier: supplier),
    );
  }

  @override
  State<SupplierDetailsSheet> createState() => _SupplierDetailsSheetState();
}

class _SupplierDetailsSheetState extends State<SupplierDetailsSheet> {
  late SupplierEntity _supplier;
  List<PurchaseOrderEntity> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _supplier = widget.supplier;
    _loadSupplierDetails();
  }

  Future<void> _loadSupplierDetails() async {
    try {
      final model = await InjectionContainer.supplierRemoteDataSource.getSupplierById(_supplier.id);
      final entity = SupplierMapper.supplierToEntity(model);
      final orders = model.purchaseOrders.isNotEmpty
          ? model.purchaseOrders.map(SupplierMapper.orderToEntity).toList()
          : await InjectionContainer.supplierRepository.getPurchaseOrders(supplierId: _supplier.id);
      if (mounted) {
        setState(() {
          _supplier = entity;
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.business_outlined, color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _supplier.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _supplier.companyName.isNotEmpty ? _supplier.companyName : 'Individual Supplier',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Summary row (Total Purchases & Due)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Purchases', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(
                          '৳ ${_supplier.totalPurchases.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _supplier.dueAmount > 0 ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _supplier.dueAmount > 0 ? Colors.red.shade200 : Colors.green.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Due',
                          style: TextStyle(
                            fontSize: 11,
                            color: _supplier.dueAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '৳ ${_supplier.dueAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _supplier.dueAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Scrollable Info & Orders List
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.phone_outlined, 'Phone Number', _supplier.phone),
                    if (_supplier.email.isNotEmpty)
                      _buildInfoRow(Icons.email_outlined, 'Email Address', _supplier.email),
                    if (_supplier.address.isNotEmpty)
                      _buildInfoRow(Icons.location_on_outlined, 'Address', _supplier.address),

                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // Order History Header
                    Text(
                      'Purchase Orders History (${_orders.length})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                    else if (_orders.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: Text(
                          'No purchase orders found for this supplier.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      )
                    else
                      ..._orders.map((po) {
                        final poNum = po.poNumber.isNotEmpty
                            ? po.poNumber
                            : '#${po.id.length > 8 ? po.id.substring(po.id.length - 6) : po.id}';

                        return InkWell(
                          onTap: () {
                            PurchaseOrderReceiptDialog.show(
                              context,
                              order: po,
                              supplier: _supplier,
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      poNum,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${po.createdAt.day}/${po.createdAt.month}/${po.createdAt.year}',
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(Icons.chevron_right_rounded, size: 16, color: colorScheme.primary),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ...po.items.map((i) => Text(
                                  '• ${i.itemName} (x${i.quantity}) - ৳${i.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 12),
                                )),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total: ৳${po.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    Text(
                                      po.dueAmount > 0 ? 'Due: ৳${po.dueAmount.toStringAsFixed(0)}' : 'Paid',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: po.dueAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            // Close button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
