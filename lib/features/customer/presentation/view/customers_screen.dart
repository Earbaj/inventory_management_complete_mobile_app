import 'package:flutter/material.dart';

import '../../../../core/route/app_route.dart';
import '../../customer.dart';
import '../../customer_transaction.dart';
import '../widget/add_customer_sheet.dart';
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

  final List<Customer> customers = [
    const Customer(
      id: '1',
      name: 'Rahim',
      phone: '01712345678',
      address: 'Dhaka',
      openingBalance: 2500,
    ),

    const Customer(
      id: '2',
      name: 'Jahid',
      phone: '01812345678',
      address: 'Mirpur, Dhaka',
      openingBalance: 1200,
    ),

    const Customer(
      id: '3',
      name: 'Karim Ahmed',
      phone: '01912345678',
      address: 'Uttara, Dhaka',
      openingBalance: 0,
    ),

    const Customer(
      id: '4',
      name: 'Sadia Akter',
      phone: '01612345678',
      address: 'Dhanmondi, Dhaka',
      openingBalance: 5000,
    ),
  ];

  final Map<String, List<CustomerTransaction>> transactions = {
    '1': [
      CustomerTransaction(
        id: 't1',
        date: DateTime(2026, 8, 10),
        reference: 'INV-1001',
        type: TransactionType.sale,
        amount: 3500,
        note: 'POS Sale',
      ),

      CustomerTransaction(
        id: 't2',
        date: DateTime(2026, 8, 12),
        reference: 'PAY-1001',
        type: TransactionType.payment,
        amount: 2000,
        note: 'Cash payment',
      ),
    ],

    '2': [
      CustomerTransaction(
        id: 't3',
        date: DateTime(2026, 8, 11),
        reference: 'INV-1002',
        type: TransactionType.sale,
        amount: 1800,
        note: 'POS Sale',
      ),
    ],
  };

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Customer> get filteredCustomers {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      return customer.name.toLowerCase().contains(query);
    }).toList();
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
            onPressed: _openAddCustomerSheet,
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCustomerSheet,

        icon: const Icon(Icons.person_add_alt_1_rounded),

        label: const Text('Add Customer'),
      ),

      body: Column(
        children: [
          // =========================
          // CUSTOMER SUMMARY
          // =========================
          CustomerSummary(totalCustomers: customers.length),

          // =========================
          // SEARCH
          // =========================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),

            child: TextField(
              controller: searchController,

              onChanged: (_) {
                setState(() {});
              },

              decoration: InputDecoration(
                hintText: 'Search customer by name',

                prefixIcon: const Icon(Icons.search_rounded),

                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();

                          setState(() {});
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

          // =========================
          // CUSTOMER LIST
          // =========================
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ====================================
  // ADD / EDIT CUSTOMER
  // ====================================

  void _openAddCustomerSheet({Customer? existingCustomer}) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return AddCustomerSheet(
          existingCustomer: existingCustomer,

          onSave: (customer) {
            setState(() {
              if (existingCustomer == null) {
                customers.add(customer);
              } else {
                final index = customers.indexWhere(
                  (element) => element.id == customer.id,
                );

                if (index != -1) {
                  customers[index] = customer;
                }
              }
            });

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  existingCustomer == null
                      ? 'Customer added successfully'
                      : 'Customer updated successfully',
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ====================================
  // DELETE CUSTOMER
  // ====================================

  void _deleteCustomer(Customer customer) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Customer?'),

          content: Text(
            'Are you sure you want to delete '
            '${customer.name}?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                setState(() {
                  customers.removeWhere((element) => element.id == customer.id);

                  transactions.remove(customer.id);
                });

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

  // ====================================
  // VIEW STATEMENT
  // ====================================

  void _openStatement(Customer customer) {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) => CustomerStatementScreen(
          customer: customer,

          transactions: transactions[customer.id] ?? const [],
        ),
      ),
    );
  }
}
