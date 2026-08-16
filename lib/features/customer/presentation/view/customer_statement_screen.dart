import 'package:flutter/material.dart';

import '../../customer.dart';
import '../../customer_transaction.dart';
import '../widget/customer_statement_customer_header.dart';
import '../widget/customer_statement_summary_card.dart';
import '../widget/no_transaction_card.dart';
import '../widget/transaction_card.dart';


class CustomerStatementScreen
    extends StatelessWidget {

  final Customer customer;

  final List<CustomerTransaction>
  transactions;

  const CustomerStatementScreen({
    super.key,
    required this.customer,
    required this.transactions,
  });

  double get totalSales {

    return transactions
        .where(
          (transaction) =>
      transaction.type ==
          TransactionType.sale,
    )
        .fold(
      0,
          (sum, transaction) =>
      sum + transaction.amount,
    );
  }

  double get totalPayments {

    return transactions
        .where(
          (transaction) =>
      transaction.type ==
          TransactionType.payment,
    )
        .fold(
      0,
          (sum, transaction) =>
      sum + transaction.amount,
    );
  }

  double get totalReturns {

    return transactions
        .where(
          (transaction) =>
      transaction.type ==
          TransactionType.returnInvoice,
    )
        .fold(
      0,
          (sum, transaction) =>
      sum + transaction.amount,
    );
  }

  double get currentBalance {

    return customer.openingBalance +
        totalSales -
        totalPayments -
        totalReturns;
  }

  @override
  Widget build(BuildContext context) {

    final theme =
    Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Customer Statement',
        ),
      ),

      body: ListView(

        padding:
        const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          30,
        ),

        children: [

          // ==========================
          // CUSTOMER HEADER
          // ==========================

          CustomerHeader(
            customer: customer,
          ),

          const SizedBox(
            height: 14,
          ),

          // ==========================
          // CURRENT BALANCE
          // ==========================

          Container(

            padding:
            const EdgeInsets.all(18),

            decoration:
            BoxDecoration(

              color:
              colorScheme.primary
                  .withValues(
                alpha: 0.08,
              ),

              borderRadius:
              BorderRadius.circular(
                18,
              ),

              border:
              Border.all(
                color:
                colorScheme.primary
                    .withValues(
                  alpha: 0.15,
                ),
              ),
            ),

            child: Column(
              children: [

                Text(
                  'Current Balance',

                  style: theme
                      .textTheme
                      .bodyMedium,
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  '৳ ${currentBalance.toStringAsFixed(2)}',

                  style:
                  TextStyle(
                    fontSize: 28,
                    fontWeight:
                    FontWeight.w800,
                    color:
                    colorScheme.primary,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  currentBalance > 0
                      ? 'Due from customer'
                      : 'No outstanding due',

                  style:
                  theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          // ==========================
          // SUMMARY
          // ==========================

          Row(
            children: [

              Expanded(
                child:
                StatementSummaryCard(
                  title:
                  'Opening',

                  value:
                  customer.openingBalance,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child:
                StatementSummaryCard(
                  title:
                  'Sales',

                  value:
                  totalSales,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child:
                StatementSummaryCard(
                  title:
                  'Paid',

                  value:
                  totalPayments,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 22,
          ),

          // ==========================
          // TRANSACTIONS
          // ==========================

          Row(
            children: [

              const Expanded(
                child: Text(
                  'Transactions',

                  style:
                  TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              Text(
                '${transactions.length} records',

                style:
                theme.textTheme.bodySmall,
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          if (transactions.isEmpty)

            NoTransactions()

          else

            ...transactions.map(
                  (transaction) =>
                  TransactionCard(
                    transaction:
                    transaction,
                  ),
            ),
        ],
      ),
    );
  }
}