import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_complete/features/posbilling/presentation/widget/payment_options.dart';
import 'package:inventory_management_complete/features/posbilling/presentation/widget/section_tile.dart';
import 'package:inventory_management_complete/features/posbilling/presentation/widget/summary_raw.dart';

import '../../pos_customer.dart';
import '../../pos_product.dart';
import 'check_out_product_raw.dart';

class CheckoutSheet extends StatelessWidget {
  final List<PosProduct> cartProducts;
  final Map<String, int> cart;

  final double subtotal;
  final double discount;
  final double total;

  final PosCustomer selectedCustomer;
  final List<PosCustomer> customers;

  final String selectedPayment;

  final TextEditingController discountController;

  final ValueChanged<PosCustomer>
  onCustomerChanged;

  final ValueChanged<String>
  onPaymentChanged;

  final void Function(
      PosProduct product,
      int quantity,
      ) onQuantityChanged;

  final VoidCallback onCheckout;

  const CheckoutSheet({
    required this.cartProducts,
    required this.cart,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.selectedCustomer,
    required this.customers,
    required this.selectedPayment,
    required this.discountController,
    required this.onCustomerChanged,
    required this.onPaymentChanged,
    required this.onQuantityChanged,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height:
      MediaQuery.sizeOf(context).height *
          0.90,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
        const BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // HANDLE

            const SizedBox(height: 10),

            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius:
                BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 15),

            // TITLE

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),

                  Text(
                    '${cart.values.fold<int>(0, (a, b) => a + b)} Items',
                    style: theme
                        .textTheme
                        .bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  20,
                ),
                children: [
                  // =====================
                  // CART
                  // =====================

                  const SectionTitle(
                    title: 'Order Items',
                  ),

                  const SizedBox(height: 8),

                  ...cartProducts.map(
                        (product) {
                      final quantity =
                          cart[product.id] ?? 0;

                      return CheckoutProductRow(
                        product: product,
                        quantity: quantity,
                        onQuantityChanged:
                            (value) {
                          onQuantityChanged(
                            product,
                            value,
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  // =====================
                  // CUSTOMER
                  // =====================

                  const SectionTitle(
                    title: 'Customer',
                  ),

                  const SizedBox(height: 8),

                  InkWell(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                    onTap: () {
                      _showCustomerPicker(
                        context,
                      );
                    },
                    child: Container(
                      padding:
                      const EdgeInsets.all(
                        13,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme
                            .surfaceContainerHighest,
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 21,
                            backgroundColor:
                            colorScheme
                                .primary
                                .withValues(
                              alpha: 0.10,
                            ),
                            child: Icon(
                              selectedCustomer.id ==
                                  'walk-in'
                                  ? Icons
                                  .person_outline
                                  : Icons
                                  .person_rounded,
                              color:
                              colorScheme
                                  .primary,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  selectedCustomer
                                      .name,
                                  style: const TextStyle(
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),

                                if (selectedCustomer
                                    .phone
                                    .isNotEmpty)
                                  Text(
                                    selectedCustomer
                                        .phone,
                                    style: theme
                                        .textTheme
                                        .bodySmall,
                                  ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons
                                .keyboard_arrow_down_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =====================
                  // DISCOUNT
                  // =====================

                  const SectionTitle(
                    title: 'Discount',
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller:
                    discountController,
                    keyboardType:
                    const TextInputType
                        .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                    const InputDecoration(
                      hintText:
                      'Enter discount amount',
                      prefixText: '৳ ',
                      prefixIcon: Icon(
                        Icons.discount_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =====================
                  // PAYMENT
                  // =====================

                  const SectionTitle(
                    title: 'Payment Method',
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: PaymentOption(
                          title: 'Cash',
                          icon: Icons
                              .payments_outlined,
                          selected:
                          selectedPayment ==
                              'Cash',
                          onTap: () {
                            onPaymentChanged(
                              'Cash',
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: PaymentOption(
                          title: 'Due',
                          icon: Icons
                              .account_balance_wallet_outlined,
                          selected:
                          selectedPayment ==
                              'Due',
                          onTap: () {
                            onPaymentChanged(
                              'Due',
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =====================
                  // SUMMARY
                  // =====================

                  Container(
                    padding:
                    const EdgeInsets.all(
                      16,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme
                          .surfaceContainerHighest,
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: Column(
                      children: [
                        SummaryRow(
                          title: 'Subtotal',
                          value:
                          '৳ ${subtotal.toStringAsFixed(0)}',
                        ),

                        const SizedBox(height: 8),

                        SummaryRow(
                          title: 'Discount',
                          value:
                          '- ৳ ${discount.toStringAsFixed(0)}',
                          valueColor:
                          Colors.red,
                        ),

                        const Padding(
                          padding:
                          EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: Divider(),
                        ),

                        SummaryRow(
                          title: 'Total',
                          value:
                          '৳ ${total.toStringAsFixed(0)}',
                          large: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // CHECKOUT BUTTON
            // =========================

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                12,
              ),
              child: FilledButton(
                onPressed: onCheckout,
                style: FilledButton.styleFrom(
                  minimumSize:
                  const Size.fromHeight(
                    54,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Complete Checkout',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),

                    Text(
                      '৳ ${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerPicker(
      BuildContext context,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Select Customer',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              ...customers.map(
                    (customer) {
                  final selected =
                      customer.id ==
                          selectedCustomer.id;

                  return ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        customer.id ==
                            'walk-in'
                            ? Icons
                            .person_outline
                            : Icons
                            .person,
                      ),
                    ),
                    title: Text(
                      customer.name,
                    ),
                    subtitle:
                    customer.phone.isEmpty
                        ? null
                        : Text(
                      customer.phone,
                    ),
                    trailing: selected
                        ? const Icon(
                      Icons.check_circle,
                    )
                        : null,
                    onTap: () {
                      onCustomerChanged(
                        customer,
                      );

                      Navigator.pop(
                        context,
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}