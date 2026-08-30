import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/route/app_route.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/widgets/global_warning_dialog.dart';
import '../../domain/entities/supplier_entity.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';
import '../widget/add_edit_supplier_sheet.dart';
import '../widget/new_purchase_order_sheet.dart';
import '../widget/purchase_order_receipt_dialog.dart';
import '../widget/purchase_orders_tab_view.dart';
import '../widget/supplier_details_sheet.dart';
import '../widget/suppliers_expandable_fab.dart';
import '../widget/suppliers_list_tab_view.dart';

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

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _fabAnimationController,
    );

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
      title: 'Delete Supplier Confirmation',
      message: 'Are you sure you want to delete "${supplier.name}"? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_forever_rounded,
      confirmColor: Colors.red,
      onConfirm: () async {
        context.read<SupplierBloc>().add(DeleteSupplierEvent(supplier.id));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
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
      floatingActionButton: SuppliersExpandableFab(
        expandAnimation: _expandAnimation,
        isFabOpen: _isFabOpen,
        onToggle: _toggleFab,
        onAddSupplier: () => _showAddSupplierSheet(context),
        onNewPurchaseOrder: () {
          final state = context.read<SupplierBloc>().state;
          final suppliers = state is SupplierLoadedState ? state.suppliers : <SupplierEntity>[];
          _showNewPurchaseOrderSheet(context, suppliers);
        },
      ),
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

              // Main Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Suppliers List
                    SuppliersListTabView(
                      state: state,
                      isInitialLoading: isInitialLoading,
                      isRefreshing: isRefreshing,
                      onSupplierTap: (supplier) => SupplierDetailsSheet.show(context, supplier),
                      onSupplierEdit: (supplier) => _showEditSupplierSheet(context, supplier),
                      onSupplierDelete: (supplier) => _confirmDeleteSupplier(context, supplier),
                    ),

                    // Tab 2: Purchase Orders History
                    PurchaseOrdersTabView(
                      state: state,
                      isInitialLoading: isInitialLoading,
                      isRefreshing: isRefreshing,
                      onOrderTap: (order, supplier) {
                        PurchaseOrderReceiptDialog.show(
                          context,
                          order: order,
                          supplier: supplier,
                        );
                      },
                      onPrintPdf: (order, supplier) {
                        PdfExportService.printOrSavePurchaseOrderPdf(
                          context,
                          order: order,
                          supplier: supplier,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
