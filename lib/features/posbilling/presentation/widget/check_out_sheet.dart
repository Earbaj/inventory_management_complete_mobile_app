import 'package:flutter/material.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../customers/domain/entities/customer_entity.dart';
import '../../pos_customer.dart';
import '../../pos_product.dart';
import 'payment_options.dart';
import 'section_tile.dart';
import 'summary_raw.dart';

class CheckoutSheet extends StatefulWidget {
  final List<CartItemEntity>? cartItems;
  final CustomerEntity? customer;
  final Function(String paymentMethod, double paidAmount)? onComplete;

  final List<PosProduct>? cartProducts;
  final Map<String, int>? cart;
  final double? subtotal;
  final double? discount;
  final double? total;
  final PosCustomer? selectedCustomer;
  final List<PosCustomer>? customers;
  final String? selectedPayment;
  final TextEditingController? discountController;
  final ValueChanged<PosCustomer>? onCustomerChanged;
  final ValueChanged<String>? onPaymentChanged;
  final void Function(PosProduct product, int quantity)? onQuantityChanged;
  final VoidCallback? onCheckout;

  const CheckoutSheet({
    super.key,
    this.cartItems,
    this.customer,
    this.onComplete,
    this.cartProducts,
    this.cart,
    this.subtotal,
    this.discount,
    this.total,
    this.selectedCustomer,
    this.customers,
    this.selectedPayment,
    this.discountController,
    this.onCustomerChanged,
    this.onPaymentChanged,
    this.onQuantityChanged,
    this.onCheckout,
  });

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

typedef CheckOutSheet = CheckoutSheet;

class _CheckoutSheetState extends State<CheckoutSheet> {
  late String _paymentMethod;
  late TextEditingController _discountCtrl;

  @override
  void initState() {
    super.initState();
    _paymentMethod = widget.selectedPayment ?? 'cash';
    _discountCtrl = widget.discountController ?? TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cartItemsList = widget.cartItems ?? [];
    final calcSubtotal = widget.subtotal ?? cartItemsList.fold(0.0, (sum, i) => sum + i.totalPrice);
    final disc = double.tryParse(_discountCtrl.text) ?? widget.discount ?? 0.0;
    final calcTotal = (calcSubtotal - disc).clamp(0.0, double.infinity);
    final itemCount = widget.cart?.values.fold<int>(0, (a, b) => a + b) ?? cartItemsList.fold<int>(0, (sum, i) => sum + i.quantity);

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.90,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Checkout',
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '$itemCount Items',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  const SectionTitle(title: 'Payment Method'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: PaymentOption(
                          title: 'Cash',
                          icon: Icons.payments_outlined,
                          selected: _paymentMethod.toLowerCase() == 'cash',
                          onTap: () {
                            setState(() => _paymentMethod = 'cash');
                            widget.onPaymentChanged?.call('cash');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PaymentOption(
                          title: 'bKash / Card',
                          icon: Icons.account_balance_wallet_outlined,
                          selected: _paymentMethod.toLowerCase() == 'bkash' || _paymentMethod.toLowerCase() == 'card',
                          onTap: () {
                            setState(() => _paymentMethod = 'bkash');
                            widget.onPaymentChanged?.call('bkash');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PaymentOption(
                          title: 'Due',
                          icon: Icons.money_off_rounded,
                          selected: _paymentMethod.toLowerCase() == 'due',
                          onTap: () {
                            setState(() => _paymentMethod = 'due');
                            widget.onPaymentChanged?.call('due');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        SummaryRow(
                          title: 'Subtotal',
                          value: '৳ ${calcSubtotal.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 8),
                        SummaryRow(
                          title: 'Discount',
                          value: '- ৳ ${disc.toStringAsFixed(0)}',
                          valueColor: Colors.red,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(),
                        ),
                        SummaryRow(
                          title: 'Total',
                          value: '৳ ${calcTotal.toStringAsFixed(0)}',
                          large: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: FilledButton(
                onPressed: () {
                  if (widget.onComplete != null) {
                    widget.onComplete!(_paymentMethod, calcTotal);
                  } else if (widget.onCheckout != null) {
                    widget.onCheckout!();
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Complete Checkout',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '৳ ${calcTotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
}