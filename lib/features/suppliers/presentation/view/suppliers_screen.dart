import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../../core/widgets/global_empty_placeholder.dart';
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

class _SuppliersScreenState extends State<SuppliersScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fabAnimationController;
  late Animation<double> _expandAnimation;
  bool _isFabOpen = false;
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // FAB Animation Controller
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _fabAnimationController,
    );

    // Initialize loading suppliers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierBloc>().add(const LoadSuppliersEvent());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }


  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
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
          IconButton(
            icon: Icon(_isSearchOpen ? Icons.filter_alt_off:Icons.filter_alt),
            tooltip: 'IsSearchTogle',
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
              });
            },
          ),
        ],
      ),
      floatingActionButton: _buildExpandableFab(context, colorScheme),
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
                if(_isSearchOpen)...[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Suppliers ...',
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
                ],

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

  Widget _buildExpandableFab(BuildContext context, ColorScheme colorScheme) {
    return BlocBuilder<SupplierBloc, SupplierState>(
      builder: (context, state) {
        final hasSuppliers = state is SupplierLoadedState && state.suppliers.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // বাটন ১: মালামাল ক্রয় (Purchase Order)
            ScaleTransition(
              scale: _expandAnimation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black87,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'মালামাল ক্রয়',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    heroTag: 'fab_purchase',
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      _toggleFab();
                      if (hasSuppliers) {
                        _showNewPurchaseOrderDialog(context, state.suppliers);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('প্রথমে একজন মহাজন যুক্ত করুন!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.add_shopping_cart_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // বাটন ২: নতুন মহাজন (Add Supplier)
            ScaleTransition(
              scale: _expandAnimation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black87,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'নতুন মহাজন',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    heroTag: 'fab_supplier',
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      _toggleFab();
                      _showAddSupplierDialog(context);
                    },
                    child: const Icon(Icons.person_add_alt_1_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // মূল ট্রিগার FAB (প্লাস / ক্রস বাটন)
            FloatingActionButton(
              heroTag: 'fab_main_toggle',
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: _toggleFab,
              child: AnimatedRotation(
                turns: _isFabOpen ? 0.125 : 0, // ট্যাপ করলে 45 ডিগ্রি ঘুরে Close (X) আইকন হবে
                duration: const Duration(milliseconds: 250),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            ),
          ],
        );
      },
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
      return GlobalEmptyPlaceholder(
        title: 'NO Suppliers Found',
        subtitle: 'Add Suppliers To Start Your Business.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        return InkWell(
          onTap: () => _showSupplierDetailsDialog(context, supplier),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ১. হেডার: অবতার, নাম ও পপআপ অ্যাকশন
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.business_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            supplier.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            supplier.companyName.isNotEmpty ? supplier.companyName : 'কোম্পানি নাম নেই',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade600, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('ডিলিট করুন', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ২. যোগাযোগের তথ্য (Phone & Address)
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      supplier.phone,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    if (supplier.address.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text('•', style: TextStyle(color: Colors.grey.shade400)),
                      ),
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          supplier.address,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.8),
                const SizedBox(height: 12),

                // ৩. মোট ক্রয় এবং বাকি হিসাবের কাস্টম সমান স্পেসযুক্ত কার্ডস
                Row(
                  children: [
                    // মোট ক্রয়
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'মোট ক্রয়',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '৳${supplier.totalPurchases.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // বাকি (Due)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          color: supplier.dueAmount > 0
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: supplier.dueAmount > 0
                                ? Colors.red.shade200
                                : Colors.green.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'বাকি টাকা',
                              style: TextStyle(
                                fontSize: 11,
                                color: supplier.dueAmount > 0
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '৳${supplier.dueAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: supplier.dueAmount > 0
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildPurchaseOrdersList(BuildContext context, List<PurchaseOrderEntity> orders) {
    if (orders.isEmpty) {
      return GlobalEmptyPlaceholder(
        title: 'NO Recipe Found',
        subtitle: 'Buy Product From Suppliers To Start Your Business.',
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
      barrierDismissible: false,
      builder: (dialogCtx) {
        return BlocConsumer<SupplierBloc, SupplierState>(
          listenWhen: (previous, current) {
            return previous is SupplierLoadedState &&
                previous.isSaving &&
                current is SupplierLoadedState &&
                !current.isSaving &&
                current.successMessage != null;
          },
          listener: (context, state) {
            Navigator.pop(dialogCtx);
          },
          builder: (context, state) {
            final isSaving = state is SupplierLoadedState && state.isSaving;
            return AlertDialog(
              title: const Text('Create New Suppliers Profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Suppliers Name *'),
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: companyCtrl,
                      decoration: const InputDecoration(labelText: 'Suppliers Name / Business *'),
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Mobile Number *'),
                      keyboardType: TextInputType.phone,
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email (Optional)'),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(labelText: 'Address (Optional)'),
                      enabled: !isSaving,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
                  child: const Text('Reject'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () {
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
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
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
      barrierDismissible: false,
      builder: (dialogCtx) {
        return BlocConsumer<SupplierBloc, SupplierState>(
          listenWhen: (previous, current) {
            return previous is SupplierLoadedState &&
                previous.isSaving &&
                current is SupplierLoadedState &&
                !current.isSaving &&
                current.successMessage != null;
          },
          listener: (context, state) {
            Navigator.pop(dialogCtx);
          },
          builder: (context, state) {
            final isSaving = state is SupplierLoadedState && state.isSaving;
            return AlertDialog(
              title: const Text('মহাজনের তথ্য আপডেট'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'মহাজনের নাম'), enabled: !isSaving),
                    TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'কোম্পানির নাম'), enabled: !isSaving),
                    TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'মোবাইল নম্বর'), enabled: !isSaving),
                    TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'ইমেইল'), enabled: !isSaving),
                    TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'ঠিকানা'), enabled: !isSaving),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: isSaving ? null : () => Navigator.pop(dialogCtx), child: const Text('বাতিল')),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          final updated = supplier.copyWith(
                            name: nameCtrl.text.trim(),
                            companyName: companyCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            address: addressCtrl.text.trim(),
                          );
                          context.read<SupplierBloc>().add(UpdateSupplierEvent(updated));
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('আপডেট করুন'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteSupplier(BuildContext context, SupplierEntity supplier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return BlocConsumer<SupplierBloc, SupplierState>(
          listenWhen: (previous, current) {
            return previous is SupplierLoadedState &&
                previous.isSaving &&
                current is SupplierLoadedState &&
                !current.isSaving &&
                current.successMessage != null;
          },
          listener: (context, state) {
            Navigator.pop(dialogCtx);
          },
          builder: (context, state) {
            final isSaving = state is SupplierLoadedState && state.isSaving;
            return AlertDialog(
              title: const Text('মহাজন ডিলিট নিশ্চিতকরণ'),
              content: Text('আপনি কি নিশ্চিত যে "${supplier.name}" এর প্রোফাইল ডিলিট করতে চান?'),
              actions: [
                TextButton(onPressed: isSaving ? null : () => Navigator.pop(dialogCtx), child: const Text('বাতিল')),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isSaving
                      ? null
                      : () {
                          context.read<SupplierBloc>().add(DeleteSupplierEvent(supplier.id));
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('ডিলিট করুন'),
                ),
              ],
            );
          },
        );
      },
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
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final qty = int.tryParse(qtyCtrl.text) ?? 1;
          final unitCost = double.tryParse(costCtrl.text) ?? 0.0;
          final total = qty * unitCost;
          final paid = double.tryParse(paidCtrl.text) ?? total;
          final due = total - paid > 0 ? total - paid : 0.0;

          return BlocConsumer<SupplierBloc, SupplierState>(
            listenWhen: (previous, current) {
              return previous is SupplierLoadedState &&
                  previous.isSaving &&
                  current is SupplierLoadedState &&
                  !current.isSaving &&
                  current.successMessage != null;
            },
            listener: (context, state) {
              Navigator.pop(dialogCtx);
            },
            builder: (context, state) {
              final isSaving = state is SupplierLoadedState && state.isSaving;
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
                        onChanged: isSaving
                            ? null
                            : (val) {
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
                          onChanged: isSaving
                              ? null
                              : (val) {
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
                          enabled: !isSaving,
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
                              enabled: !isSaving,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: costCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'পাইকারি রেট (৳)'),
                              onChanged: (_) => setDialogState(() {}),
                              enabled: !isSaving,
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
                              enabled: !isSaving,
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
                        enabled: !isSaving,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: isSaving ? null : () => Navigator.pop(dialogCtx), child: const Text('বাতিল')),
                  FilledButton.icon(
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check),
                    label: isSaving ? const Text('সেভ করা হচ্ছে...') : const Text('মেমো সেভ & স্টক আপডেট'),
                    onPressed: isSaving
                        ? null
                        : () {
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
                          },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
