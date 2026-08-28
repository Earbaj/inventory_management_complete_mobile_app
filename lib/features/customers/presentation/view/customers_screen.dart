import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../posbilling/domain/entities/sale_entity.dart';
import '../../../reports/presentation/bloc/reports_state.dart';
import '../../customer.dart';
import '../../customer_transaction.dart';
import '../bloc/customer_bloc.dart';
import '../widget/add_customer_sheet.dart';
import '../widget/collect_payment_sheet.dart';
import '../widget/customer_card.dart';
import '../widget/customer_summary.dart';
import '../widget/empty_customer_state.dart';
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
              InjectionContainer.customerBloc.add(FetchCustomersEvent(searchQuery: searchController.text));
            },
            icon: const Icon(Icons.refresh_rounded),
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
      body: BlocBuilder<CustomerBloc,CustomerState>(
        builder: (context, snapshot) {
          final state = snapshot;

          if (state is CustomerLoadingState && state is! CustomerLoadedState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_off_rounded,
                        color: colorScheme.error,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Something Went Wrong',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message.isNotEmpty
                          ? state.message
                          : 'Unable to load customers. Cache expired or network connection failed.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        InjectionContainer.customerBloc.add(FetchCustomersEvent(searchQuery: searchController.text));
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final loadedState = state is CustomerLoadedState ? state : null;
          final totalCustomers = loadedState?.customers.length ?? 0;
          final filteredCustomers = loadedState?.filteredCustomers ?? [];

          return Column(
            children: [
              /*// SUMMARY
              CustomerSummary(totalCustomers: totalCustomers),
*/
              // SEARCH
              if(isSearch)...[
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
              // LIST
              Expanded(
                child: filteredCustomers.isEmpty
                    ? const EmptyCustomers()
                    : ListView.builder(
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
          onSave: (customer) {
            if (existingCustomer == null) {
              InjectionContainer.customerBloc.add(AddCustomerEvent(customer));
            } else {
              InjectionContainer.customerBloc.add(UpdateCustomerEvent(customer));
            }

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  existingCustomer == null ? 'Customer added successfully' : 'Customer updated successfully',
                ),
              ),
            );
          },
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Customer?'),
          content: Text('Are you sure you want to delete ${customer.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                InjectionContainer.customerBloc.add(DeleteCustomerEvent(customer.id));

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Customer deleted successfully'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // VIEW STATEMENT
  void _openStatement(CustomerEntity customer) {
    final reportsState = InjectionContainer.reportsBloc.state;
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
