import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/route/app_route.dart';
import '../../../../core/widgets/global_empty_placeholder.dart';
import '../../../../core/widgets/global_warning_dialog.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';
import '../widget/add_edit_supplier_sheet.dart';
import '../widget/new_purchase_order_sheet.dart';
import '../widget/supplier_details_sheet.dart';
import '../widget/suppliers_shimmer.dart';

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

  void _showAddSupplierSheet(BuildContext context) {
    AddEditSupplierSheet.show(
      context,
      onSave: (supplier) async {
        final bloc = context.read<SupplierBloc>();
        bloc.add(CreateSupplierEvent(supplier));
        await bloc.stream.firstWhere((s) => (s is SupplierLoadedState && !s.isSaving) || s is SupplierErrorState);
      },
    );
  }

  void _showEditSupplierSheet(BuildContext context, SupplierEntity supplier) {
    AddEditSupplierSheet.show(
      context,
      supplierToEdit: supplier,
      onSave: (updated) async {
        final bloc = context.read<SupplierBloc>();
        bloc.add(UpdateSupplierEvent(updated));
        await bloc.stream.firstWhere((s) => (s is SupplierLoadedState && !s.isSaving) || s is SupplierErrorState);
      },
    );
  }

  void _showNewPurchaseOrderSheet(BuildContext context, List<SupplierEntity> suppliers) {
    NewPurchaseOrderSheet.show(
      context,
      suppliers: suppliers,
      onSave: (order) async {
        final bloc = context.read<SupplierBloc>();
        bloc.add(CreatePurchaseOrderEvent(order));
        await bloc.stream.firstWhere((s) => (s is SupplierLoadedState && !s.isSaving) || s is SupplierErrorState);
      },
    );
  }

  void _confirmDeleteSupplier(BuildContext context, SupplierEntity supplier) {
    GlobalWarningDialog.show(
      context,
      title: 'মহাজন ডিলিট নিশ্চিতকরণ',
      message: 'আপনি কি নিশ্চিত যে "${supplier.name}" এর প্রোফাইল ডিলিট করতে চান?',
      confirmText: 'ডিলিট করুন',
      cancelText: 'বাতিল',
      icon: Icons.delete_forever_rounded,
      confirmColor: Colors.red,
      onConfirm: () async {
        context.read<SupplierBloc>().add(DeleteSupplierEvent(supplier.id));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              context.read<SupplierBloc>().add(const LoadSuppliersEvent(forceRefresh: true));
            },
          ),
          IconButton(
            icon: Icon(_isSearchOpen ? Icons.filter_alt_off : Icons.filter_alt),
            tooltip: 'Toggle Search',
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                if (!_isSearchOpen && _searchController.text.isNotEmpty) {
                  _searchController.clear();
                  context.read<SupplierBloc>().add(const LoadSuppliersEvent());
                }
              });
            },
          ),
        ],
      ),
      floatingActionButton: _buildExpandableFab(context, colorScheme),
      body: BlocConsumer<SupplierBloc, SupplierState>(
        listenWhen: (previous, current) {
          return (current is SupplierLoadedState && current.successMessage != null) ||
              current is SupplierErrorState;
        },
        buildWhen: (previous, current) =>
            current is! SupplierLoadedState || current.isSaving == false,
        listener: (context, state) {
          if (state is SupplierLoadedState && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is SupplierErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isInitialLoading =
              state is SupplierLoadingState && state is! SupplierLoadedState;
          final bool isRefreshing =
              state is SupplierLoadedState && state.isListLoading;

          return Column(
            children: [
              // Search Input Bar
              if (_isSearchOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
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

              // Main Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSupplierTabContent(context, state, isInitialLoading, isRefreshing),
                    _buildPurchaseOrdersTabContent(context, state, isInitialLoading, isRefreshing),
                  ],
                ),
              ),
            ],
          );
        },
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
                        _showNewPurchaseOrderSheet(context, state.suppliers);
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
                      _showAddSupplierSheet(context);
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
                turns: _isFabOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSupplierTabContent(
    BuildContext context,
    SupplierState state,
    bool isInitialLoading,
    bool isRefreshing,
  ) {
    if (isInitialLoading || isRefreshing) {
      return const SuppliersShimmerView();
    }

    if (state is SupplierErrorState && state.previousSuppliers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, color: Colors.red.shade400, size: 48),
              const SizedBox(height: 16),
              Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<SupplierBloc>().add(const LoadSuppliersEvent(forceRefresh: true));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('পুনরায় চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      );
    }

    final List<SupplierEntity> suppliers = state is SupplierLoadedState
        ? state.suppliers
        : (state is SupplierErrorState ? state.previousSuppliers : []);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SupplierBloc>().add(const LoadSuppliersEvent(forceRefresh: true));
      },
      child: _buildSupplierList(context, suppliers),
    );
  }

  Widget _buildPurchaseOrdersTabContent(
    BuildContext context,
    SupplierState state,
    bool isInitialLoading,
    bool isRefreshing,
  ) {
    if (isInitialLoading || isRefreshing) {
      return const SuppliersShimmerView(isPurchaseOrder: true);
    }

    if (state is SupplierErrorState && state.previousPurchaseOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(state.message, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        ),
      );
    }

    final List<PurchaseOrderEntity> orders = state is SupplierLoadedState
        ? state.purchaseOrders
        : (state is SupplierErrorState ? state.previousPurchaseOrders : []);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SupplierBloc>().add(const LoadPurchaseOrdersEvent(forceRefresh: true));
      },
      child: _buildPurchaseOrdersList(context, orders),
    );
  }

  Widget _buildSupplierList(BuildContext context, List<SupplierEntity> suppliers) {
    if (suppliers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: const GlobalEmptyPlaceholder(
              title: 'NO Suppliers Found',
              subtitle: 'Add Suppliers To Start Your Business.',
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        return InkWell(
          onTap: () => SupplierDetailsSheet.show(context, supplier),
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
                          SupplierDetailsSheet.show(context, supplier);
                        } else if (val == 'edit') {
                          _showEditSupplierSheet(context, supplier);
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

                // ৩. মোট ক্রয় এবং বাকি হিসাবের কার্ড
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
                              'বাকি (Due)',
                              style: TextStyle(
                                fontSize: 11,
                                color: supplier.dueAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '৳${supplier.dueAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: supplier.dueAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
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
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: const GlobalEmptyPlaceholder(
              title: 'NO Purchase History Found',
              subtitle: 'Start Purchasing Stock From Suppliers.',
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final formattedDate =
            '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ভাউচার: ${order.poNumber.isNotEmpty ? order.poNumber : "#${order.id.length > 8 ? order.id.substring(order.id.length - 6) : order.id}"}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'মহাজন: ${order.supplierName}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const Divider(),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.itemName} (x${item.quantity})'),
                        Text('৳${item.totalPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('মোট: ৳${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'বাকি: ৳${order.dueAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: order.dueAmount > 0 ? Colors.red : Colors.green,
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
}
