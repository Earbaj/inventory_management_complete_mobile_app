import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../../core/widgets/global_empty_placeholder.dart';
import '../../../../core/widgets/global_warning_dialog.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../posbilling/domain/entities/sale_entity.dart';
import '../../../reports/presentation/bloc/reports_bloc.dart';
import '../../../reports/presentation/bloc/reports_state.dart';
import '../../customer_transaction.dart';
import '../bloc/customer_bloc.dart';
import '../widget/add_customer_sheet.dart';
import '../widget/collect_payment_sheet.dart';
import '../widget/customer_card.dart';
import '../widget/customer_shimmer.dart';
import 'customer_statement_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController searchController = TextEditingController();

  final Map<String, List<CustomerTransaction>> transactions = {};
  bool isSearch = false;

  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch to CustomerBloc
    context.read<CustomerBloc>().add(FetchCustomersEvent());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<CustomerBloc>().add(FetchCustomersEvent(searchQuery: query));
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
        title: const Text('Customers'),
        actions: [
          IconButton(
            onPressed: () => _openCollectPaymentSheet(),
            icon: const Icon(Icons.payments_rounded, color: Colors.green),
            tooltip: 'Receive Payment',
          ),
          IconButton(
            onPressed: () {
              context.read<CustomerBloc>().add(FetchCustomersEvent(searchQuery: searchController.text));
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: (){
              setState(() {
                isSearch = !isSearch;
              });
            },
            icon: Icon(isSearch ? Icons.filter_alt_off:Icons.filter_alt),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCustomerSheet,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Customer'),
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listenWhen: (previous, current) =>
            current is CustomerOperationSuccessState || current is CustomerErrorState,
        buildWhen: (previous, current) => current is! CustomerOperationSuccessState,
        listener: (context, state) {
          if (state is CustomerOperationSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade700,
              ),
            );
          } else if (state is CustomerErrorState) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    const Text('Limit Exceeded'),
                  ],
                ),
                content: Text(
                  state.message.isNotEmpty
                      ? state.message
                      : 'Free tier is limited to 1 customer only. Please upgrade to premium.',
                  style: const TextStyle(fontSize: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Upgrade/Subscription পেজে নেওয়ার জন্য (যদি থাকে)
                      // context.push('/subscription');
                    },
                    child: const Text('Upgrade Plan'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, snapshot) {
          final state = snapshot;
          final bool isInitialLoading = state is CustomerLoadingState || state is CustomerInitialState;
          final bool isRefreshing = state is CustomerLoadedState && state.isListLoading;

          // 🎯 মূল ফিক্স: LoadedState থাকলে সেটা নেবে, আর ErrorState হলে আগের লিস্টটা ধরে রাখবে
          List<CustomerEntity> filteredCustomers = [];
          if (state is CustomerLoadedState) {
            filteredCustomers = state.filteredCustomers;
          } else if (state is CustomerErrorState) {
            filteredCustomers = state.previousCustomers; // 👈 লিস্ট খালি হবে না!
          }

          return Column(
            children: [
              // SEARCH
              if (isSearch) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: TextField(
                    controller: searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search customer by name or phone',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                searchController.clear();
                                _onSearchChanged('');
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],

              // LIST OR SHIMMER
              if (isInitialLoading || isRefreshing)
                const Expanded(
                  child: CustomerShimmerView(),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<CustomerBloc>().add(FetchCustomersEvent(searchQuery: searchController.text));
                    },
                    child: filteredCustomers.isEmpty
                        ? const SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: 400,
                              child: GlobalEmptyPlaceholder(
                                title: 'No customers found',
                                subtitle: 'Tap Add Customer To Create Customer And Sell.',
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = filteredCustomers[index];

                              return CustomerCard(
                                customer: customer,
                                onEdit: () {
                                  _openAddCustomerSheet(existingCustomer: customer);
                                },
                                onDelete: () {
                                  _deleteCustomer(customer);
                                },
                                onStatement: () {
                                  _openStatement(customer);
                                },
                                onCollectPayment: () {
                                  _openCollectPaymentSheet(preSelectedCustomer: customer);
                                },
                              );
                            },
                          ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ADD / EDIT CUSTOMER
  void _openAddCustomerSheet({CustomerEntity? existingCustomer}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddCustomerSheet(
          existingCustomer: existingCustomer,
        );
      },
    );
  }

  // COLLECT PAYMENT SHEET
  void _openCollectPaymentSheet({CustomerEntity? preSelectedCustomer}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CollectPaymentSheet(preSelectedCustomer: preSelectedCustomer);
      },
    );
  }

  // DELETE CUSTOMER
  void _deleteCustomer(CustomerEntity customer) {
    GlobalWarningDialog.show(
      context,
      title: 'Delete Customer?',
      message: 'Are you sure you want to delete ${customer.name}?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_forever_rounded,
      confirmColor: Colors.red,
      onConfirm: () async {
        try {
          await InjectionContainer.deleteCustomerUseCase(customer.id);
          if (mounted) {
            context.read<CustomerBloc>().add(const FetchCustomersEvent());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Customer deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: Colors.red,
              ),
            );
          }
          rethrow;
        }
      },
    );
  }

  // VIEW STATEMENT
  void _openStatement(CustomerEntity customer) {
    final reportsState = context.read<ReportsBloc>().state;
    final allLogs = reportsState is ReportsLoadedState ? reportsState.invoiceLogs : <SaleEntity>[];

    final customerSales = allLogs.where((sale) {
      final matchId = sale.customer?.id.isNotEmpty == true && sale.customer!.id == customer.id;
      final matchName = sale.customer?.name.isNotEmpty == true &&
          sale.customer!.name.trim().toLowerCase() == customer.name.trim().toLowerCase();
      final matchPhone = sale.customer?.phone.isNotEmpty == true &&
          customer.phone.isNotEmpty &&
          sale.customer!.phone.trim() == customer.phone.trim();

      return matchId || matchName || matchPhone;
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerStatementScreen(
          customer: customer,
          transactions: const [],
          customerSales: customerSales,
        ),
      ),
    );
  }
}
