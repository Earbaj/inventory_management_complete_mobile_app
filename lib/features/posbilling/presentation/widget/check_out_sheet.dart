import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_complete/features/posbilling/presentation/bloc/pos_bloc.dart';

import '../../../customers/domain/entities/customer_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../presentation/bloc/pos_event.dart';
import '../../presentation/bloc/pos_state.dart';
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
  late TextEditingController _overallDiscountCtrl;
  late TextEditingController _paidCtrl;
  bool _isPaidEdited = false;
  String _overallDiscountType = 'percent'; // Default toggle type: 'percent' or 'amount'

  @override
  void initState() {
    super.initState();
    _paymentMethod = widget.selectedPayment ?? 'cash';
    _overallDiscountCtrl = widget.discountController ?? TextEditingController();
    _paidCtrl = TextEditingController();

    // If initial text already contains %, detect percentage mode
    if (_overallDiscountCtrl.text.endsWith('%')) {
      _overallDiscountType = 'percent';
    }

    _updateDefaultPaidAmount(widget.cartItems);
  }

  void _updateDefaultPaidAmount([List<CartItemEntity>? currentItems]) {
    final cartList = currentItems ?? widget.cartItems ?? [];
    final double rawSub = cartList.fold<double>(0.0, (sum, i) => sum + i.rawSubtotal);
    final double itemDisc = cartList.fold<double>(0.0, (sum, i) => sum + i.discountAmount);
    final double subAfterItemDisc = (rawSub - itemDisc).clamp(0.0, double.infinity);

    final double overallDiscInTk = _calculateOverallDiscountTk(subAfterItemDisc);
    final double calcNetTotal = (subAfterItemDisc - overallDiscInTk).clamp(0.0, double.infinity);

    if (!_isPaidEdited) {
      if (_paymentMethod.toLowerCase() == 'due') {
        _paidCtrl.text = '0';
      } else {
        _paidCtrl.text = calcNetTotal.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    if (widget.discountController == null) {
      _overallDiscountCtrl.dispose();
    }
    _paidCtrl.dispose();
    super.dispose();
  }

  _ParsedDiscount _parseDiscount(String input, [String defaultType = 'amount']) {
    final text = input.trim();
    if (text.isEmpty) return _ParsedDiscount(0.0, defaultType);
    if (text.endsWith('%')) {
      final pctText = text.replaceAll('%', '').trim();
      final pct = double.tryParse(pctText) ?? 0.0;
      return _ParsedDiscount(pct, 'percent');
    }
    final val = double.tryParse(text) ?? 0.0;
    return _ParsedDiscount(val, defaultType);
  }

  double _calculateOverallDiscountTk(double baseSubtotal) {
    if (baseSubtotal <= 0) return 0.0;
    final parsed = _parseDiscount(_overallDiscountCtrl.text, _overallDiscountType);
    if (parsed.value <= 0) return 0.0;
    if (parsed.type == 'percent') {
      return (baseSubtotal * (parsed.value / 100.0)).clamp(0.0, baseSubtotal);
    }
    return parsed.value.clamp(0.0, baseSubtotal);
  }

  String _getOverallDiscountHelperText(double baseSubtotal) {
    final text = _overallDiscountCtrl.text.trim();
    if (text.isEmpty) {
      return _overallDiscountType == 'percent'
          ? 'Enter % (e.g. 10 for 10% discount)'
          : 'Enter flat amount in ${MoneyUtil.currencySymbol} (e.g. 50)';
    }
    final parsed = _parseDiscount(text, _overallDiscountType);
    if (parsed.value <= 0) return 'Invalid discount format';
    if (parsed.type == 'percent') {
      final tkVal = _calculateOverallDiscountTk(baseSubtotal);
      return '${parsed.value.toStringAsFixed(parsed.value % 1 == 0 ? 0 : 1)}% discount = ${MoneyUtil.currencySymbol} ${tkVal.toStringAsFixed(2)} off';
    }
    return 'Fixed ${MoneyUtil.currencySymbol} ${parsed.value.toStringAsFixed(2)} discount off';
  }

  void _showProductDiscountDialog(BuildContext context, CartItemEntity cartItem) {
    String selectedType = cartItem.discountType;
    final String initialText;
    if (cartItem.discount > 0) {
      initialText = cartItem.discount.toStringAsFixed(cartItem.discount % 1 == 0 ? 0 : 1);
    } else {
      initialText = '';
    }
    final discCtrl = TextEditingController(text: initialText);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final colorScheme = Theme.of(context).colorScheme;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Product Discount for ${cartItem.item.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unit Price: ${MoneyUtil.currencySymbol}${cartItem.item.retailSellPrice.toStringAsFixed(2)} | Qty: ${cartItem.quantity}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Item Raw Price: ${MoneyUtil.currencySymbol}${cartItem.rawSubtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: discCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: selectedType == 'percent' ? 'Item Discount (%)' : 'Item Discount (${MoneyUtil.currencySymbol})',
                    hintText: selectedType == 'percent' ? 'e.g. 10 for 10%' : 'e.g. 50 for ${MoneyUtil.currencySymbol}50 off',
                    border: const OutlineInputBorder(),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedType = 'amount';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: selectedType == 'amount' ? colorScheme.primary : Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                MoneyUtil.currencySymbol,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: selectedType == 'amount' ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedType = 'percent';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: selectedType == 'percent' ? colorScheme.primary : Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: selectedType == 'percent' ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final parsed = _parseDiscount(discCtrl.text, selectedType);
                  context.read<PosBloc>().add(UpdateCartItemDiscountEvent(
                    itemId: cartItem.item.id,
                    discount: parsed.value,
                    discountType: parsed.type,
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<PosBloc, PosState>(
      listener: (context, state) {
        if (state is PosCheckoutSuccessState) {
          Navigator.of(context).pop(state.completedSale);
        } else if (state is PosCheckoutErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is PosCheckoutLoadingState;
        final posState = state is PosCartState
            ? state
            : PosCartState(
                cartItems: widget.cartItems ?? [],
                selectedCustomer: widget.customer,
              );

        final cartItemsList = posState.cartItems.isNotEmpty ? posState.cartItems : (widget.cartItems ?? []);
        final double rawSubtotal = cartItemsList.fold<double>(0.0, (sum, i) => sum + i.rawSubtotal);
        final double productDiscounts = cartItemsList.fold<double>(0.0, (sum, i) => sum + i.discountAmount);
        final double subtotalAfterItemDiscounts = (rawSubtotal - productDiscounts).clamp(0.0, double.infinity);

        final double overallDiscInTk = _calculateOverallDiscountTk(subtotalAfterItemDiscounts);
        final double calcNetTotal = (subtotalAfterItemDiscounts - overallDiscInTk).clamp(0.0, double.infinity);
        final double totalDiscounts = productDiscounts + overallDiscInTk;

        final itemCount = posState.totalItemCount > 0
            ? posState.totalItemCount
            : (widget.cart?.values.fold<int>(0, (a, b) => a + b) ?? cartItemsList.fold<int>(0, (sum, i) => sum + i.quantity));

        if (!_isPaidEdited) {
          if (_paymentMethod.toLowerCase() == 'due') {
            _paidCtrl.text = '0';
          } else {
            _paidCtrl.text = calcNetTotal.toStringAsFixed(0);
          }
        }

        final paidAmountInput = double.tryParse(_paidCtrl.text) ?? 0.0;
        final dueAmount = (calcNetTotal - paidAmountInput).clamp(0.0, double.infinity);

        return PopScope(
          canPop: !isLoading,
          child: Container(
            height: MediaQuery.sizeOf(context).height * 0.92,
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
                      // PRODUCT WISE ITEMS & DISCOUNTS
                      if (cartItemsList.isNotEmpty) ...[
                        const SectionTitle(title: 'Item Discounts'),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cartItemsList.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final cItem = cartItemsList[idx];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                title: Text(
                                  cItem.item.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                subtitle: Text(
                                  'Qty: ${cItem.quantity} x ${MoneyUtil.currencySymbol}${cItem.item.retailSellPrice.toStringAsFixed(0)}'
                                  '${cItem.discount > 0 ? " | Item Disc: ${cItem.discountType == 'percent' ? '${cItem.discount.toStringAsFixed(0)}%' : '${MoneyUtil.currencySymbol}${cItem.discount.toStringAsFixed(0)}'}" : ""}',
                                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${MoneyUtil.currencySymbol}${cItem.totalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        cItem.discount > 0 ? Icons.discount_rounded : Icons.discount_outlined,
                                        size: 20,
                                        color: cItem.discount > 0 ? colorScheme.primary : Colors.grey,
                                      ),
                                      onPressed: () => _showProductDiscountDialog(context, cItem),
                                      tooltip: 'Item Discount (${MoneyUtil.currencySymbol} or %)',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // PAYMENT METHOD SELECTOR
                      const SectionTitle(title: 'Payment Method'),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            PaymentOption(
                              title: 'Cash',
                              icon: Icons.payments_outlined,
                              selected: _paymentMethod.toLowerCase() == 'cash',
                              onTap: () {
                                setState(() {
                                  _paymentMethod = 'cash';
                                  _isPaidEdited = false;
                                });
                                widget.onPaymentChanged?.call('cash');
                              },
                            ),
                            const SizedBox(width: 10),
                            PaymentOption(
                              title: 'bKash / Card',
                              icon: Icons.account_balance_wallet_outlined,
                              selected: _paymentMethod.toLowerCase() == 'bkash' || _paymentMethod.toLowerCase() == 'card',
                              onTap: () {
                                setState(() {
                                  _paymentMethod = 'bkash';
                                  _isPaidEdited = false;
                                });
                                widget.onPaymentChanged?.call('bkash');
                              },
                            ),
                            const SizedBox(width: 10),
                            PaymentOption(
                              title: 'Due',
                              icon: Icons.money_off_rounded,
                              selected: _paymentMethod.toLowerCase() == 'due',
                              onTap: () {
                                setState(() {
                                  _paymentMethod = 'due';
                                  _paidCtrl.text = '0';
                                  _isPaidEdited = true;
                                });
                                widget.onPaymentChanged?.call('due');
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // OVERALL DISCOUNT & PAID AMOUNT EDITING INPUTS
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _overallDiscountCtrl,
                              keyboardType: TextInputType.text,
                              onChanged: (_) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                labelText: _overallDiscountType == 'percent'
                                    ? 'Overall Discount (%)'
                                    : 'Overall Discount (${MoneyUtil.currencySymbol})',
                                hintText: _overallDiscountType == 'percent' ? 'e.g. 10' : 'e.g. 50',
                                helperMaxLines: 2,
                                prefixIcon: Icon(
                                  _overallDiscountType == 'percent' ? Icons.percent_rounded : Icons.attach_money_rounded,
                                  size: 20,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _overallDiscountType = 'amount';
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _overallDiscountType == 'amount'
                                                ? colorScheme.primary
                                                : Colors.grey.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            MoneyUtil.currencySymbol,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: _overallDiscountType == 'amount' ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _overallDiscountType = 'percent';
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _overallDiscountType == 'percent'
                                                ? colorScheme.primary
                                                : Colors.grey.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: _overallDiscountType == 'percent' ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _paidCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              enabled: _paymentMethod.toLowerCase() != 'due',
                              onChanged: (_) {
                                setState(() {
                                  _isPaidEdited = true;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Paid Amount',
                                hintText: '${MoneyUtil.currencySymbol} 0',
                                prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(_getOverallDiscountHelperText(subtotalAfterItemDiscounts)),
                      const SizedBox(height: 18),

                      // SUMMARY BREAKDOWN BOX
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
                              value: '${MoneyUtil.currencySymbol} ${rawSubtotal.toStringAsFixed(0)}',
                            ),
                            if (totalDiscounts > 0) ...[
                              const SizedBox(height: 8),
                              SummaryRow(
                                title: 'Total Discount',
                                value: '- ${MoneyUtil.currencySymbol} ${totalDiscounts.toStringAsFixed(0)}',
                                valueColor: Colors.red,
                              ),
                            ],
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(),
                            ),
                            SummaryRow(
                              title: 'Net Total',
                              value: '${MoneyUtil.currencySymbol} ${calcNetTotal.toStringAsFixed(0)}',
                              large: true,
                            ),
                            const SizedBox(height: 8),
                            SummaryRow(
                              title: 'Paid Amount',
                              value: '${MoneyUtil.currencySymbol} ${paidAmountInput.toStringAsFixed(0)}',
                              valueColor: Colors.green[700],
                            ),
                            const SizedBox(height: 8),
                            SummaryRow(
                              title: 'Due Amount',
                              value: '${MoneyUtil.currencySymbol} ${dueAmount.toStringAsFixed(0)}',
                              valueColor: dueAmount > 0 ? Colors.orange[800] : Colors.grey,
                              large: dueAmount > 0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // COMPLETE CHECKOUT ACTION BUTTON
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: FilledButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            // Sync overall calculated discount (in Tk) with PosBloc state
                            context.read<PosBloc>().add(ApplyDiscountEvent(overallDiscInTk));

                            final double finalPaid;
                            if (_paymentMethod.toLowerCase() == 'due') {
                              finalPaid = 0.0;
                            } else {
                              finalPaid = double.tryParse(_paidCtrl.text) ?? calcNetTotal;
                            }

                            if (widget.onComplete != null) {
                              widget.onComplete!(_paymentMethod, finalPaid);
                            } else if (widget.onCheckout != null) {
                              widget.onCheckout!();
                            } else {
                              context.read<PosBloc>().add(SubmitCheckoutEvent(
                                paymentMethod: _paymentMethod,
                                paidAmount: finalPaid,
                              ));
                            }
                          },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Processing Checkout...',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Text(
                                  dueAmount > 0 ? 'Checkout with ${MoneyUtil.currencySymbol}${dueAmount.toStringAsFixed(0)} Due' : 'Complete Checkout',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                '${MoneyUtil.currencySymbol} ${calcNetTotal.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  }
}

class _ParsedDiscount {
  final double value;
  final String type;

  const _ParsedDiscount(this.value, this.type);
}