import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../inventory/data/models/inventory_item_model.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize loading suppliers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierBloc>().add(const LoadSuppliersEvent());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers / মহাজন হিসাব'),
        leading: IconButton(
          onPressed: () {
            AppRoute.shellScaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people_alt_outlined), text: 'Suppliers List'),
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Suppliers Recipe'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<SupplierBloc>().add(const LoadSuppliersEvent());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddSupplierDialog(context),
          label: Text("Add Supplier")
      ),
      body: BlocConsumer<SupplierBloc, SupplierState>(
          listener: (context, state) {
            if (state is SupplierLoadedState && state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is SupplierErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Action Buttons Header
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'মহাজন বা কোম্পানির নাম খুঁজুন...',
                            prefixIcon: const Icon(Icons.search),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (val) {
                            context.read<SupplierBloc>().add(LoadSuppliersEvent(search: val));
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Banner for Purchase
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, color: colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'পাইকারি মালামাল ক্রয় মেমো',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'মহাজনের কাছ থেকে ক্রয়কৃত মালামাল যুক্ত করলে ইনভেন্টরি স্টক অটো-রিস্টক হবে।',
                              style: TextStyle(fontSize: 11, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: state is SupplierLoadedState && state.suppliers.isNotEmpty
                            ? () => _showNewPurchaseOrderDialog(context, state.suppliers)
                            : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('প্রথমে একজন মহাজন যুক্ত করুন!')),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text('মালামাল ক্রয়'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 0),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Main Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSupplierTabContent(context, state),
                      _buildPurchaseOrdersTabContent(context, state),
                    ],
                  ),
                ),
              ],
            );
          }
      ),
    );
  }

  Widget _buildSupplierTabContent(BuildContext context, SupplierState state) {
    if (state is SupplierLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is SupplierErrorState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(state.message, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        ),
      );
    }
    final List<SupplierEntity> suppliers = state is SupplierLoadedState ? state.suppliers : [];
    return _buildSupplierList(context, suppliers);
  }

  Widget _buildPurchaseOrdersTabContent(BuildContext context, SupplierState state) {
    if (state is SupplierLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is SupplierErrorState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(state.message, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        ),
      );
    }
    final List<PurchaseOrderEntity> orders = state is SupplierLoadedState ? state.purchaseOrders : [];
    return _buildPurchaseOrdersList(context, orders);
  }

  Widget _buildSupplierList(BuildContext context, List<SupplierEntity> suppliers) {
    if (suppliers.isEmpty) {
      return const Center(
        child: Text('কোন মহাজন পাওয়া যায়নি। "নতুন মহাজন" বাটনে ক্লিক করে যোগ করুন।'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : 'M',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              supplier.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('কোম্পানি: ${supplier.companyName.isNotEmpty ? supplier.companyName : "N/A"} | ফোন: ${supplier.phone}'),
                if (supplier.address.isNotEmpty) Text('ঠিকানা: ${supplier.address}', style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text('মোট ক্রয়: ৳${supplier.totalPurchases.toStringAsFixed(0)}'),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 6),
                    Chip(
                      label: Text(
                        'বাকি: ৳${supplier.dueAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: supplier.dueAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'details') {
                  _showSupplierDetailsDialog(context, supplier);
                } else if (val == 'edit') {
                  _showEditSupplierDialog(context, supplier);
                } else if (val == 'delete') {
                  _confirmDeleteSupplier(context, supplier);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'details', child: Text('ইতিহাস ও প্রোফাইল')),
                const PopupMenuItem(value: 'edit', child: Text('তথ্য আপডেট')),
                const PopupMenuItem(value: 'delete', child: Text('ডিলিট করুন', style: TextStyle(color: Colors.red))),
              ],
            ),
            onTap: () => _showSupplierDetailsDialog(context, supplier),
          ),
        );
      },
    );
  }

  Widget _buildPurchaseOrdersList(BuildContext context, List<PurchaseOrderEntity> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('এখনও কোন কেনাকাটার মেমো তৈরি হয়নি। "মালামাল ক্রয়" বাটনে চাপুন।'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ExpansionTile(
            leading: const Icon(Icons.receipt_long, color: Colors.blue),
            title: Text(
              'মেমো #${order.id} - ${order.supplierName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'তারিখ: ${order.createdAt.toString().split(' ')[0]} | মোট: ৳${order.totalAmount.toStringAsFixed(0)} (পরিশোধ: ৳${order.paidAmount.toStringAsFixed(0)})',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ক্রয়কৃত আইটেমের তালিকা:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('• ${item.itemName} (${item.quantity} টি)'),
                              Text('৳${item.totalPrice.toStringAsFixed(0)} (@ ৳${item.unitCost})'),
                            ],
                          ),
                        )),
                    if (order.note.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('নোট: ${order.note}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSupplierDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Create New Suppliers Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Suppliers Name *')),
              const SizedBox(height: 4,),
              TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'Suppliers Name / Business *')),
              const SizedBox(height: 4,),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Number *'), keyboardType: TextInputType.phone),
              const SizedBox(height: 4,),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email (Optional)'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 4,),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address (Optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Reject')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and Phone Number mandatory!')),
                );
                return;
              }

              final supplier = SupplierEntity(
                id: 'sup_${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text.trim(),
                companyName: companyCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                address: addressCtrl.text.trim(),
                createdAt: DateTime.now(),
              );

              context.read<SupplierBloc>().add(CreateSupplierEvent(supplier));
              Navigator.pop(dialogCtx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditSupplierDialog(BuildContext context, SupplierEntity supplier) {
    final nameCtrl = TextEditingController(text: supplier.name);
    final companyCtrl = TextEditingController(text: supplier.companyName);
    final phoneCtrl = TextEditingController(text: supplier.phone);
    final emailCtrl = TextEditingController(text: supplier.email);
    final addressCtrl = TextEditingController(text: supplier.address);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('মহাজনের তথ্য আপডেট'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'মহাজনের নাম')),
              TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'কোম্পানির নাম')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'মোবাইল নম্বর')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'ইমেইল')),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'ঠিকানা')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('বাতিল')),
          FilledButton(
            onPressed: () {
              final updated = supplier.copyWith(
                name: nameCtrl.text.trim(),
                companyName: companyCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                address: addressCtrl.text.trim(),
              );
              context.read<SupplierBloc>().add(UpdateSupplierEvent(updated));
              Navigator.pop(dialogCtx);
            },
            child: const Text('আপডেট করুন'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSupplier(BuildContext context, SupplierEntity supplier) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('মহাজন ডিলিট নিশ্চিতকরণ'),
        content: Text('আপনি কি নিশ্চিত যে "${supplier.name}" এর প্রোফাইল ডিলিট করতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('বাতিল')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<SupplierBloc>().add(DeleteSupplierEvent(supplier.id));
              Navigator.pop(dialogCtx);
            },
            child: const Text('ডিলিট করুন'),
          ),
        ],
      ),
    );
  }

  void _showSupplierDetailsDialog(BuildContext context, SupplierEntity supplier) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(supplier.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('কোম্পানি: ${supplier.companyName}'),
              Text('ফোন: ${supplier.phone}'),
              Text('ইমেইল: ${supplier.email.isNotEmpty ? supplier.email : "N/A"}'),
              Text('ঠিকানা: ${supplier.address.isNotEmpty ? supplier.address : "N/A"}'),
              const Divider(),
              Text('মোট কেনাকাটা: ৳${supplier.totalPurchases.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('বর্তমান বাকি (Due): ৳${supplier.dueAmount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: supplier.dueAmount > 0 ? Colors.red : Colors.green)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('বন্ধ করুন')),
        ],
      ),
    );
  }

  void _showNewPurchaseOrderDialog(BuildContext context, List<SupplierEntity> suppliers) async {
    SupplierEntity selectedSupplier = suppliers.first;
    final qtyCtrl = TextEditingController(text: '10');
    final costCtrl = TextEditingController(text: '100');
    final paidCtrl = TextEditingController(text: '1000');
    final noteCtrl = TextEditingController();

    // Fetch existing inventory items to choose from
    List<InventoryItemModel> inventoryItems = [];
    try {
      inventoryItems = await InjectionContainer.inventoryLocalDataSource.getItems();
    } catch (_) {}

    String selectedItemId = inventoryItems.isNotEmpty ? inventoryItems.first.id : 'item_1';
    String selectedItemName = inventoryItems.isNotEmpty ? inventoryItems.first.name : 'নতুন মালামাল আইটেম';

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final qty = int.tryParse(qtyCtrl.text) ?? 1;
          final unitCost = double.tryParse(costCtrl.text) ?? 0.0;
          final total = qty * unitCost;
          final paid = double.tryParse(paidCtrl.text) ?? total;
          final due = total - paid > 0 ? total - paid : 0.0;

          return AlertDialog(
            title: const Text('New Purchase / মালামাল ক্রয় মেমো'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('মহাজন নির্বাচন করুন:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<SupplierEntity>(
                    isExpanded: true,
                    value: selectedSupplier,
                    items: suppliers.map((sup) {
                      return DropdownMenuItem(value: sup, child: Text('${sup.name} (${sup.companyName})'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedSupplier = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text('প্রোডাক্ট আইটেম নির্বাচন করুন:', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (inventoryItems.isNotEmpty)
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedItemId,
                      items: inventoryItems.map((item) {
                        return DropdownMenuItem(value: item.id, child: Text('${item.name} (বর্তমান স্টক: ${item.quantity})'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final selected = inventoryItems.firstWhere((i) => i.id == val);
                          setDialogState(() {
                            selectedItemId = selected.id;
                            selectedItemName = selected.name;
                            costCtrl.text = selected.costPrice.toStringAsFixed(0);
                          });
                        }
                      },
                    )
                  else
                    TextField(
                      decoration: const InputDecoration(labelText: 'মালামালের নাম'),
                      onChanged: (val) => selectedItemName = val,
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'পরিমাণ (Qty)'),
                          onChanged: (_) => setDialogState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: costCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'পাইকারি রেট (৳)'),
                          onChanged: (_) => setDialogState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('মোট বিল: ৳${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: paidCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'পরিশোধিত টাকা (৳)', isDense: true),
                          onChanged: (_) => setDialogState(() {}),
                        ),
                        const SizedBox(height: 4),
                        Text('বাকি (Due): ৳${due.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: due > 0 ? Colors.red : Colors.green)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(labelText: 'নোট / রিমার্কস (ঐচ্ছিক)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('বাতিল')),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('মেমো সেভ & স্টক আপডেট'),
                onPressed: () {
                  final orderItem = PurchaseOrderItemEntity(
                    itemId: selectedItemId,
                    itemName: selectedItemName,
                    quantity: qty,
                    unitCost: unitCost,
                    totalPrice: total,
                  );

                  final order = PurchaseOrderEntity(
                    id: 'PO_${DateTime.now().millisecondsSinceEpoch}',
                    supplierId: selectedSupplier.id,
                    supplierName: selectedSupplier.name,
                    items: [orderItem],
                    totalAmount: total,
                    paidAmount: paid,
                    dueAmount: due,
                    note: noteCtrl.text.trim(),
                    createdAt: DateTime.now(),
                  );

                  context.read<SupplierBloc>().add(CreatePurchaseOrderEvent(order));
                  Navigator.pop(dialogCtx);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
