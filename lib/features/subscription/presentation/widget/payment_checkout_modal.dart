import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';

class PaymentCheckoutModal extends StatefulWidget {
  const PaymentCheckoutModal({super.key});

  @override
  State<PaymentCheckoutModal> createState() => _PaymentCheckoutModalState();
}

class _PaymentCheckoutModalState extends State<PaymentCheckoutModal> {
  final _formKey = GlobalKey<FormState>();
  final _trxController = TextEditingController();
  final _amountController = TextEditingController(text: '999');

  String _selectedMethod = 'bkash';

  final Map<String, String> _paymentNumbers = const {
    'bkash': '01700000000 (Merchant)',
    'nagad': '01800000000 (Merchant)',
    'rocket': '01900000000 (Personal)',
    'bank': 'City Bank - A/C 123456789',
  };

  @override
  void dispose() {
    _trxController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text.trim()) ?? 999.0;
      final trxId = _trxController.text.trim();

      InjectionContainer.subscriptionBloc.add(SubmitSubscriptionPaymentEvent(
        method: _selectedMethod,
        transactionId: trxId,
        amount: amount,
        targetTier: 'premium',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: StreamBuilder<SubscriptionState>(
        stream: InjectionContainer.subscriptionBloc.stream,
        initialData: InjectionContainer.subscriptionBloc.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is PaymentSubmittedSuccessState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
                const SizedBox(height: 12),
                Text(
                  'Payment Submitted!',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          }

          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upgrade to Premium Tier',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Send payment to our official account and enter TrxID below for instant activation.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),

                // METHOD SELECTOR
                Row(
                  children: ['bkash', 'nagad', 'rocket', 'bank'].map((method) {
                    final isSelected = _selectedMethod == method;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ChoiceChip(
                          label: Text(method.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedMethod = method);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // INSTRUCTIONS BOX
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Account Number:',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _paymentNumbers[_selectedMethod] ?? '',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _trxController,
                  decoration: InputDecoration(
                    labelText: 'Transaction ID (TrxID)',
                    hintText: 'e.g. 9J87X1K2',
                    prefixIcon: const Icon(Icons.receipt_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter valid TrxID' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (BDT)',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter amount' : null,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: state is SubscriptionLoadingState ? null : _submitPayment,
                    icon: state is SubscriptionLoadingState
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.verified_user_rounded),
                    label: Text(
                      state is SubscriptionLoadingState ? 'Submitting...' : 'Submit Payment TrxID',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
