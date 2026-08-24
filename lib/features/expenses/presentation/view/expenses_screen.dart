import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../domain/entities/expense_entity.dart';
import '../bloc/expenses_bloc.dart';
import '../bloc/expenses_event.dart';
import '../bloc/expenses_state.dart';
import '../widget/add_edit_expense_dialog.dart';
import '../widget/expense_card.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;

  final List<Map<String, String>> _categories = const [
    {'key': 'all', 'label': 'All Categories'},
    {'key': 'utility', 'label': 'Utility ⚡'},
    {'key': 'rent', 'label': 'Rent 🏪'},
    {'key': 'salary', 'label': 'Salary 💼'},
    {'key': 'transport', 'label': 'Transport 🚚'},
    {'key': 'misc', 'label': 'Misc 📑'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ExpensesBloc>().add(const FetchExpensesEvent(isRefresh: true));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ExpensesBloc>().add(const LoadMoreExpensesEvent());
    }
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AddEditExpenseDialog(
        onSave: (expense) {
          context.read<ExpensesBloc>().add(CreateExpenseEvent(expense));
        },
      ),
    );
  }

  void _showEditExpenseDialog(ExpenseEntity expense) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AddEditExpenseDialog(
        expenseToEdit: expense,
        onSave: (updatedExpense) {
          context.read<ExpensesBloc>().add(UpdateExpenseEvent(updatedExpense));
        },
      ),
    );
  }

  void _confirmDeleteExpense(ExpenseEntity expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Move to Recycle Bin?'),
          ],
        ),
        content: Text('Are you sure you want to delete "${expense.title}"? It can be restored later from the Recycle Bin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ExpensesBloc>().add(DeleteExpenseEvent(expense.id));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
        title: const Row(
          children: [
            Icon(Icons.receipt_long_rounded, size: 24),
            SizedBox(width: 8),
            Text('Shop Expenses'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<ExpensesBloc>().add(const FetchExpensesEvent(isRefresh: true));
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Expenses',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Record Expense'),
      ),
      body: BlocConsumer<ExpensesBloc, ExpensesState>(
        listener: (context, state) {
          if (state is ExpensesOperationSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ExpensesErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ExpensesLoadingState && state is! ExpensesLoadedState) {
            return const Center(child: CircularProgressIndicator());
          }

          final loadedState = state is ExpensesLoadedState ? state : null;
          final expenses = loadedState?.expenses ?? [];
          final totalAmount = loadedState?.totalExpenseAmount ?? 0.0;
          final isLoadingMore = loadedState?.isLoadingMore ?? false;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ExpensesBloc>().add(const FetchExpensesEvent(isRefresh: true));
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // TOTAL SUMMARY CARD
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade700, Colors.deepOrange.shade800],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Operational Expenses',
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              Icon(Icons.trending_down_rounded, color: Colors.white70),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '৳ ${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${loadedState?.meta.total ?? expenses.length} records total',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // CATEGORY FILTER CHIPS
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: _categories.map((c) {
                        final key = c['key']!;
                        final isSelected = (key == 'all' && _selectedCategory == null) ||
                            (_selectedCategory == key);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(c['label']!),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = key == 'all' ? null : key;
                              });
                              context
                                  .read<ExpensesBloc>()
                                  .add(FilterExpensesByCategoryEvent(_selectedCategory));
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // EXPENSES LIST
                if (expenses.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No Expenses Found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap + Record Expense button below to log shop expenses.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= expenses.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final expense = expenses[index];
                          return ExpenseCard(
                            expense: expense,
                            onEdit: () => _showEditExpenseDialog(expense),
                            onDelete: () => _confirmDeleteExpense(expense),
                          );
                        },
                        childCount: expenses.length + (isLoadingMore ? 1 : 0),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),
    );
  }
}
