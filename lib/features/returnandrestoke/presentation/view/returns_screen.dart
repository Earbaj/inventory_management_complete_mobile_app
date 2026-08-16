import 'package:flutter/material.dart';

import '../../../../core/route/app_route.dart';
import '../../../posbilling/presentation/widget/section_tile.dart';
import '../../return_models.dart';
import '../widget/invoic_header.dart';
import '../widget/return_header.dart';
import '../widget/return_item_card.dart';
import '../widget/return_summary.dart';


class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  State<ReturnsScreen> createState() =>
      _ReturnsScreenState();
}

class _ReturnsScreenState
    extends State<ReturnsScreen> {

  ReturnCustomer? selectedCustomer;
  CustomerInvoice? selectedInvoice;

  final Map<String, int> returnQuantities = {};

  // ==============================
  // DEMO CUSTOMERS
  // ==============================

  final List<ReturnCustomer> customers = const [

    ReturnCustomer(
      id: 'c1',
      name: 'Rahim',
      phone: '01712345678',
    ),

    ReturnCustomer(
      id: 'c2',
      name: 'Jahid',
      phone: '01812345678',
    ),

    ReturnCustomer(
      id: 'c3',
      name: 'Karim Ahmed',
      phone: '01912345678',
    ),
  ];

  // ==============================
  // DEMO INVOICES
  // ==============================

  final List<CustomerInvoice> invoices = [

    CustomerInvoice(
      id: 'inv1',
      invoiceNumber: 'INV-1001',
      customerId: 'c1',
      date: DateTime(2026, 8, 10),

      items: const [

        InvoiceItem(
          productId: 'p1',
          productName: 'Rice 5KG',
          sku: 'RICE-005',
          price: 450,
          purchasedQuantity: 3,
        ),

        InvoiceItem(
          productId: 'p2',
          productName: 'Soybean Oil 1L',
          sku: 'OIL-001',
          price: 180,
          purchasedQuantity: 2,
        ),

        InvoiceItem(
          productId: 'p3',
          productName: 'Sugar 1KG',
          sku: 'SUGAR-001',
          price: 140,
          purchasedQuantity: 1,
        ),
      ],
    ),

    CustomerInvoice(
      id: 'inv2',
      invoiceNumber: 'INV-1002',
      customerId: 'c1',
      date: DateTime(2026, 8, 12),

      items: const [

        InvoiceItem(
          productId: 'p4',
          productName: 'Milk 1L',
          sku: 'MILK-001',
          price: 90,
          purchasedQuantity: 4,
        ),

        InvoiceItem(
          productId: 'p5',
          productName: 'Bread',
          sku: 'BREAD-001',
          price: 70,
          purchasedQuantity: 2,
        ),
      ],
    ),

    CustomerInvoice(
      id: 'inv3',
      invoiceNumber: 'INV-1003',
      customerId: 'c2',
      date: DateTime(2026, 8, 13),

      items: const [

        InvoiceItem(
          productId: 'p6',
          productName: 'Biscuit',
          sku: 'BISC-001',
          price: 50,
          purchasedQuantity: 5,
        ),
      ],
    ),
  ];

  List<CustomerInvoice> get customerInvoices {

    if (selectedCustomer == null) {
      return [];
    }

    return invoices
        .where(
          (invoice) =>
      invoice.customerId ==
          selectedCustomer!.id,
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {

    final theme =
    Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            AppRoute.shellScaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
        ),
        title: const Text(
          'Returns',
        ),
      ),

      body: ListView(

        padding:
        const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          30,
        ),

        children: [

          // ==========================
          // HEADER
          // ==========================

          ReturnHeader(),

          const SizedBox(
            height: 16,
          ),

          // ==========================
          // CUSTOMER DROPDOWN
          // ==========================

          SectionTitle(
            title: 'Select Customer',
          ),

          const SizedBox(
            height: 8,
          ),

          DropdownButtonFormField<
              ReturnCustomer>(

            value: selectedCustomer,

            isExpanded: true,

            decoration:
            const InputDecoration(
              hintText:
              'Select customer',

              prefixIcon:
              Icon(
                Icons
                    .person_search_outlined,
              ),
            ),

            items: customers.map(
                  (customer) {

                return DropdownMenuItem<
                    ReturnCustomer>(

                  value: customer,

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: [

                      Text(
                        customer.name,

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      Text(
                        customer.phone,

                        style: theme
                            .textTheme
                            .bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ).toList(),

            onChanged: (customer) {

              setState(() {

                selectedCustomer =
                    customer;

                selectedInvoice =
                null;

                returnQuantities
                    .clear();
              });
            },
          ),

          const SizedBox(
            height: 20,
          ),

          // ==========================
          // INVOICE DROPDOWN
          // ==========================

          SectionTitle(
            title: 'Select Invoice',
          ),

          const SizedBox(
            height: 8,
          ),

          DropdownButtonFormField<
              CustomerInvoice>(

            value: selectedInvoice,

            isExpanded: true,

            decoration:
            InputDecoration(

              hintText:
              selectedCustomer ==
                  null
                  ? 'Select customer first'
                  : 'Select invoice',

              prefixIcon:
              const Icon(
                Icons
                    .receipt_long_outlined,
              ),
            ),

            items: customerInvoices.map(
                  (invoice) {

                return DropdownMenuItem<
                    CustomerInvoice>(

                  value: invoice,

                  child: Row(
                    children: [

                      Expanded(
                        child: Text(
                          invoice.invoiceNumber,

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),

                      Text(
                        '৳ ${invoice.total.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                );
              },
            ).toList(),

            onChanged:
            selectedCustomer == null
                ? null
                : (invoice) {

              setState(() {

                selectedInvoice =
                    invoice;

                returnQuantities
                    .clear();
              });
            },
          ),

          // ==========================
          // INVOICE DETAILS
          // ==========================

          if (selectedInvoice != null) ...[

            const SizedBox(
              height: 24,
            ),

            InvoiceHeader(
              invoice:
              selectedInvoice!,
            ),

            const SizedBox(
              height: 12,
            ),

            SectionTitle(
              title:
              'Purchased Items',
            ),

            const SizedBox(
              height: 8,
            ),

            ...selectedInvoice!.items.map(
                  (item) =>
                  ReturnItemCard(
                    item: item,

                    quantity:
                    returnQuantities[
                    item.productId] ??
                        0,

                    onQuantityChanged:
                        (quantity) {

                      setState(() {

                        returnQuantities[
                        item.productId] =
                            quantity;
                      });
                    },
                  ),
            ),

            const SizedBox(
              height: 14,
            ),

            ReturnSummary(
              invoice:
              selectedInvoice!,

              quantities:
              returnQuantities,
            ),

            const SizedBox(
              height: 16,
            ),

            // ==========================
            // PROCESS RETURN
            // ==========================

            SizedBox(
              height: 54,

              child: FilledButton.icon(

                onPressed:
                _canProcessReturn
                    ? _processReturn
                    : null,

                icon:
                const Icon(
                  Icons
                      .assignment_return_rounded,
                ),

                label:
                const Text(
                  'Process Return & Restock',

                  style:
                  TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get _canProcessReturn {

    return returnQuantities.values
        .any(
          (quantity) =>
      quantity > 0,
    );
  }

  void _processReturn() {

    if (!_canProcessReturn ||
        selectedInvoice == null) {
      return;
    }

    final selectedItems =
    selectedInvoice!.items
        .where(
          (item) =>
      (returnQuantities[
      item.productId] ??
          0) >
          0,
    )
        .toList();

    final returnTotal =
    selectedItems.fold<double>(
      0,
          (total, item) {

        final quantity =
            returnQuantities[
            item.productId] ??
                0;

        return total +
            item.price * quantity;
      },
    );

    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            'Confirm Return',
          ),

          content: Text(
            'Are you sure you want to return '
                '${selectedItems.length} item type(s) '
                'worth ৳${returnTotal.toStringAsFixed(2)}?\n\n'
                'The returned quantity will be '
                'added back to inventory.',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child:
              const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {

                Navigator.pop(context);

                _completeReturn(
                  returnTotal,
                );
              },

              child:
              const Text('Confirm Return'),
            ),
          ],
        );
      },
    );
  }

  void _completeReturn(
      double returnTotal,
      ) {

    // =================================
    // BACKEND IMPLEMENTATION LATER:
    //
    // 1. Create return invoice
    // 2. Reduce original invoice quantity
    // 3. Increase inventory stock
    // 4. Update customer outstanding
    // 5. Create transaction
    // =================================

    setState(() {

      for (final item
      in selectedInvoice!.items) {

        final returnedQuantity =
            returnQuantities[
            item.productId] ??
                0;

        if (returnedQuantity > 0) {

          // Demo purpose:
          // Real stock update will happen
          // through repository/API.

          debugPrint(
            'Restock: ${item.productName} '
                'x $returnedQuantity',
          );
        }
      }

      returnQuantities.clear();
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
        SnackBarBehavior.floating,

        content: Text(
          'Return processed successfully. '
              '৳${returnTotal.toStringAsFixed(2)} restocked.',
        ),

        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}