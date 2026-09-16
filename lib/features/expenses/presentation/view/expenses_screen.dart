import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_local.dart';
import '../../../../core/route/app_route.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../core/widgets/global_empty_placeholder.dart';
import '../../../../core/widgets/global_warning_dialog.dart';
import '../../domain/entities/expense_entity.dart';
import '../bloc/expenses_bloc.dart';
import '../bloc/expenses_event.dart';
import '../bloc/expenses_state.dart';
import '../widget/add_edit_expense_sheet.dart';
import '../widget/expense_card.dart';
import '../widget/expenses_shimmer.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ExpensesBloc>().add(const FetchExpensesEvent());
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

  void _showAddExpenseSheet() {
    AddEditExpenseSheet.show(
      context,
      onSave: (expense) async {
        final bloc = context.read<ExpensesBloc>();
        final future = bloc.stream
            .firstWhere(
              (s) => s is ExpensesOperationSuccessState || s is ExpensesErrorState,
            )
            .timeout(
              const Duration(seconds: 20),
              onTimeout: () => const ExpensesErrorState('Request timed out. Please check your connection.'),
            );
        bloc.add(CreateExpenseEvent(expense));
        final state = await future;
        if (state is ExpensesErrorState) {
          throw Exception(state.message);
        }
      },
    );
  }

  void _showEditExpenseSheet(ExpenseEntity expense) {
    AddEditExpenseSheet.show(
      context,
      expenseToEdit: expense,
      onSave: (updatedExpense) async {
        final bloc = context.read<ExpensesBloc>();
        final future = bloc.stream
            .firstWhere(
              (s) => s is ExpensesOperationSuccessState || s is ExpensesErrorState,
            )
            .timeout(
              const Duration(seconds: 20),
              onTimeout: () => const ExpensesErrorState('Request timed out. Please check your connection.'),
            );
        bloc.add(UpdateExpenseEvent(updatedExpense));
        final state = await future;
        if (state is ExpensesErrorState) {
          throw Exception(state.message);
        }
      },
    );
  }

  void _confirmDeleteExpense(ExpenseEntity expense) {
    GlobalWarningDialog.show(
      context,
      title: ExpensesStrings.deleteExpense.getString(context),
      message: ExpensesStrings.deleteExpenseConfirm.getString(context),
      confirmText: Bangla.delete.getString(context),
      cancelText: Bangla.cancel.getString(context),
      icon: Icons.delete_forever_rounded,
      confirmColor: Colors.red,
      onConfirm: () async {
        context.read<ExpensesBloc>().add(DeleteExpenseEvent(expense.id));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categories = [
      {'key': 'all', 'label': Bangla.all.getString(context)},
      {'key': 'utility', 'label': '${ExpensesStrings.utilities.getString(context)} ⚡'},
      {'key': 'rent', 'label': '${ExpensesStrings.rent.getString(context)} 🏪'},
      {'key': 'salary', 'label': '${ExpensesStrings.salary.getString(context)} 💼'},
      {'key': 'transport', 'label': '${ExpensesStrings.transport.getString(context)} 🚚'},
      {'key': 'misc', 'label': '${ExpensesStrings.other.getString(context)} 📑'},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            AppRoute.shellScaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
        ),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, size: 24),
            const SizedBox(width: 8),
            Text(ExpensesStrings.expensesTitle.getString(context)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<ExpensesBloc>().add(const FetchExpensesEvent(isRefresh: true));
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: Bangla.details.getString(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseSheet,
        icon: const Icon(Icons.add_rounded),
        label: Text(ExpensesStrings.addExpense.getString(context)),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ExpensesBloc, ExpensesState>(
        listenWhen: (previous, current) =>
            current is ExpensesOperationSuccessState || current is ExpensesErrorState,
        buildWhen: (previous, current) => current is! ExpensesOperationSuccessState,
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
          final bool isInitialLoading = state is ExpensesLoadingState && state is! ExpensesLoadedState;
          final bool isRefreshing = state is ExpensesLoadedState && state.isListLoading;

          if (isInitialLoading || isRefreshing) {
            return const ExpensesShimmerView();
          }

          if (state is ExpensesErrorState && state.previousExpenses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_off_rounded,
                        color: Colors.red.shade700,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Something Went Wrong',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message.isNotEmpty
                          ? state.message
                          : 'Unable to load shop expenses. Please check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ExpensesBloc>().add(const FetchExpensesEvent(isRefresh: true));
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

          final loadedState = state is ExpensesLoadedState ? state : null;
          final expenses = loadedState?.expenses ??
              (state is ExpensesErrorState ? state.previousExpenses : []);
          final totalAmount = loadedState?.totalExpenseAmount ??
              (state is ExpensesErrorState ? state.previousTotalAmount : 0.0);
          final isLoadingMore = loadedState?.isLoadingMore ?? false;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ExpensesBloc>().add(const FetchExpensesEvent(isRefresh: true));
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ExpensesStrings.totalExpenses.getString(context),
                                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const Icon(Icons.trending_down_rounded, color: Colors.white70),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${MoneyUtil.currencySymbol} ${totalAmount.toStringAsFixed(2)}',
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
                      children: categories.map((c) {
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
                  GlobalEmptyPlaceholder.sliver(
                    title: ExpensesStrings.noExpensesFound.getString(context),
                    subtitle: ExpensesStrings.addExpense.getString(context),
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
                            onEdit: () => _showEditExpenseSheet(expense),
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
