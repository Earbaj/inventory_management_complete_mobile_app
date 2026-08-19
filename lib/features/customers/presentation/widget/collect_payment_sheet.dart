import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../../../reports/presentation/bloc/reports_event.dart';

class CollectPaymentSheet extends StatefulWidget {
  final CustomerEntity? preSelectedCustomer;

  const CollectPaymentSheet({
    super.key,
    this.preSelectedCustomer,
  });

  @override
  State<CollectPaymentSheet> createState() => _CollectPaymentSheetState();
}

class _CollectPaymentSheetState extends State<CollectPaymentSheet> {
  CustomerEntity? _selectedCustomer;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  String _paymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.preSelectedCustomer;
    _amountCtrl = TextEditingController();
    _noteCtrl = TextEditingController();

    if (_selectedCustomer != null && _selectedCustomer!.totalDue > 0) {
      _amountCtrl.text = _selectedCustomer!.totalDue.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  bool _isSubmitting = false;

  Future<void> _submitPayment(double amount) async {
    if (_selectedCustomer == null || amount <= 0 || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await InjectionContainer.customerRemoteDataSource.collectCustomerPayment(
        customerId: _selectedCustomer!.id,
        amount: amount,
        paymentMethod: _paymentMethod,
        note: _noteCtrl.text.trim(),
      );

      InjectionContainer.customerBloc.add(const FetchCustomersEvent());
      try {
        InjectionContainer.reportsBloc.add(const FetchReportsEvent());
      } catch (_) {}

      if (mounted) {
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment of ৳${amount.toStringAsFixed(0)} received for ${_selectedCustomer!.name}',
            ),
            backgroundColor: Colors.green[700],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final customerState = InjectionContainer.customerBloc.state;
    final List<CustomerEntity> customersList = customerState is CustomerLoadedState
        ? customerState.customers
        : (_selectedCustomer != null ? [_selectedCustomer!] : []);

    final double enteredAmount = double.tryParse(_amountCtrl.text) ?? 0.0;
    final double currentDue = _selectedCustomer?.totalDue ?? 0.0;
    final double closingBalance = (currentDue - enteredAmount).clamp(0.0, double.infinity);

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.88,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 16),

            // SHEET TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.payments_rounded, color: Colors.green, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Customer Payment Collection',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // 1. CUSTOMER DROPDOWN SELECTION
                  const Text(
                    'Select Customer',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<CustomerEntity>(
                    value: _selectedCustomer,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: 'Choose a customer from list',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    items: customersList.map((customer) {
                      return DropdownMenuItem<CustomerEntity>(
                        value: customer,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                customer.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              'Due: ৳${customer.totalDue.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: customer.totalDue > 0 ? Colors.orange[800] : Colors.grey,
                                fontWeight: customer.totalDue > 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCustomer = val;
                        if (val != null && val.totalDue > 0) {
                          _amountCtrl.text = val.totalDue.toStringAsFixed(0);
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  // 2. SELECTED CUSTOMER DETAILS CARD
                  if (_selectedCustomer != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedCustomer!.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                _selectedCustomer!.phone,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          const Divider(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Opening Balance:', style: TextStyle(fontSize: 13)),
                              Text(
                                '৳${_selectedCustomer!.openingBalance.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Current Total Due:', style: TextStyle(fontSize: 13, color: Colors.orange)),
                              Text(
                                '৳${currentDue.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: currentDue > 0 ? Colors.orange[900] : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Estimated New Balance:', style: TextStyle(fontSize: 13, color: Colors.green)),
                              Text(
                                '৳${closingBalance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: closingBalance > 0 ? Colors.orange[900] : Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // 3. PAYMENT AMOUNT INPUT
                  const Text(
                    'Payment Amount (৳)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Enter amount to receive',
                      prefixText: '৳ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: _selectedCustomer != null && _selectedCustomer!.totalDue > 0
                          ? TextButton(
                              onPressed: () {
                                setState(() {
                                  _amountCtrl.text = _selectedCustomer!.totalDue.toStringAsFixed(0);
                                });
                              },
                              child: const Text('Pay Full'),
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 4. PAYMENT METHOD
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payments_outlined, size: 18),
                              SizedBox(width: 6),
                              Text('Cash'),
                            ],
                          ),
                          selected: _paymentMethod == 'cash',
                          onSelected: (sel) {
                            if (sel) setState(() => _paymentMethod = 'cash');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, size: 18),
                              SizedBox(width: 6),
                              Text('bKash / Card'),
                            ],
                          ),
                          selected: _paymentMethod == 'bkash',
                          onSelected: (sel) {
                            if (sel) setState(() => _paymentMethod = 'bkash');
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 5. NOTE INPUT
                  const Text(
                    'Note / Reference (Optional)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Due collection for Invoice #102',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // SUBMIT BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton(
                onPressed: _selectedCustomer == null || enteredAmount <= 0 || _isSubmitting
                    ? null
                    : () => _submitPayment(enteredAmount),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded),
                          const SizedBox(width: 8),
                          Text(
                            _selectedCustomer != null
                                ? 'Collect ৳${enteredAmount.toStringAsFixed(0)} from ${_selectedCustomer!.name}'
                                : 'Process Payment',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
