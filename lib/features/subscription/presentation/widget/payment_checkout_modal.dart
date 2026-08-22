import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';
import '../../data/models/subscription_package_model.dart';

class PaymentCheckoutModal extends StatefulWidget {
  const PaymentCheckoutModal({super.key});

  @override
  State<PaymentCheckoutModal> createState() => _PaymentCheckoutModalState();
}

class _PaymentCheckoutModalState extends State<PaymentCheckoutModal> {
  int _currentStep = 0; // 0 = Package Selection, 1 = Payment TrxID Form

  List<SubscriptionPackageModel> _packages = [];
  bool _isLoadingPackages = true;
  SubscriptionPackageModel? _selectedPackage;

  final _formKey = GlobalKey<FormState>();
  final _trxController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedMethod = 'bkash';

  Map<String, String> _paymentNumbers = {
    'bkash': '01700000000 (Merchant)',
    'nagad': '01800000000 (Merchant)',
    'rocket': '01900000000 (Personal)',
    'bank': 'City Bank - A/C 123456789',
  };
  String _instructions = 'Send money or make payment to our official merchant account and enter TrxID below for instant activation.';

  @override
  void initState() {
    super.initState();
    _fetchPackages();
    _fetchPaymentInfo();
  }

  Future<void> _fetchPackages() async {
    try {
      final packages = await InjectionContainer.subscriptionRemoteDataSource.getPackages();
      if (mounted) {
        setState(() {
          _packages = packages;
          _isLoadingPackages = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPackages = false);
    }
  }

  Future<void> _fetchPaymentInfo() async {
    try {
      final info = await InjectionContainer.subscriptionRemoteDataSource.getPaymentInfo();
      if (mounted) {
        setState(() {
          _paymentNumbers = info.toNumbersMap();
          _instructions = info.instructions;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _trxController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _selectPackage(SubscriptionPackageModel pkg) {
    setState(() {
      _selectedPackage = pkg;
      _amountController.text = pkg.price > 0 ? pkg.price.toStringAsFixed(0) : '999';
      _currentStep = 1; // Advance to Payment TrxID Form Step
    });
  }

  void _submitPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text.trim()) ?? _selectedPackage?.price ?? 999.0;
      final trxId = _trxController.text.trim();
      final targetTier = _selectedPackage?.tier ?? 'premium';

      InjectionContainer.subscriptionBloc.add(SubmitSubscriptionPaymentEvent(
        method: _selectedMethod,
        transactionId: trxId,
        amount: amount,
        targetTier: targetTier,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.88,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: StreamBuilder<SubscriptionState>(
          stream: InjectionContainer.subscriptionBloc.stream,
          initialData: InjectionContainer.subscriptionBloc.state,
          builder: (context, snapshot) {
            final state = snapshot.data;

            if (state is PaymentSubmittedSuccessState) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      'Payment Request Submitted!',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(160, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 14),

                // MODAL HEADER WITH BACK BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (_currentStep == 1)
                        IconButton(
                          onPressed: () => setState(() => _currentStep = 0),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      Expanded(
                        child: Text(
                          _currentStep == 0
                              ? '1. Select Subscription Package'
                              : '2. Payment via bKash / Nagad',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 16),

                // BODY STEPS
                Expanded(
                  child: _currentStep == 0
                      ? _buildPackageSelectionStep(theme, colorScheme)
                      : _buildPaymentFormStep(theme, colorScheme, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // STEP 1: PACKAGE SELECTION LIST
  Widget _buildPackageSelectionStep(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoadingPackages) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const Text(
          'Choose the right plan for your business needs:',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 14),

        Builder(
          builder: (context) {
            final displayPackages = _packages.where((pkg) =>
                pkg.tier.toLowerCase() != 'free' &&
                pkg.id.toLowerCase() != 'free' &&
                pkg.price > 0
            ).toList();

            final listToRender = displayPackages.isNotEmpty ? displayPackages : _packages;

            return Column(
              children: listToRender.map((pkg) {
                final isPremium = pkg.tier.toLowerCase() == 'premium' || pkg.id.contains('premium');

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isPremium ? colorScheme.primary : theme.dividerColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _selectPackage(pkg),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isPremium ? Icons.workspace_premium_rounded : Icons.star_outline_rounded,
                                    color: isPremium ? Colors.amber[800] : colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    pkg.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                pkg.price > 0 ? '৳${pkg.price.toStringAsFixed(0)}' : 'FREE',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: isPremium ? colorScheme.primary : theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              if (pkg.price > 0)
                                Text(
                                  ' / ${pkg.duration}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),

                          // LIMITS & FEATURES
                          Text(
                            '• Customers: ${pkg.maxCustomers == -1 ? "Unlimited" : "Up to ${pkg.maxCustomers}"}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Sales Invoices: ${pkg.maxSales == -1 ? "Unlimited" : "Up to ${pkg.maxSales}"}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          ...pkg.features.map((feat) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('✔ $feat', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              )),

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => _selectPackage(pkg),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPremium ? colorScheme.primary : null,
                                foregroundColor: isPremium ? Colors.white : null,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Select ${pkg.name}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // STEP 2: PAYMENT TRXID FORM
  Widget _buildPaymentFormStep(ThemeData theme, ColorScheme colorScheme, SubscriptionState? state) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // SELECTED PACKAGE SUMMARY BANNER
          if (_selectedPackage != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected: ${_selectedPackage!.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tier: ${_selectedPackage!.tier.toUpperCase()}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    '৳${_selectedPackage!.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          Text(
            _instructions,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 14),

          // PAYMENT METHOD SELECTOR
          const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
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

          // INSTRUCTIONS & MERCHANT NUMBER BOX
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Merchant Account Number (${_selectedMethod.toUpperCase()}):',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  _paymentNumbers[_selectedMethod] ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // TRXID INPUT
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
          const SizedBox(height: 14),

          // AMOUNT INPUT
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
          const SizedBox(height: 24),

          // SUBMIT BUTTON
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: state is SubscriptionLoadingState ? null : _submitPayment,
              icon: state is SubscriptionLoadingState
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.verified_user_rounded),
              label: Text(
                state is SubscriptionLoadingState ? 'Submitting TrxID...' : 'Submit Payment TrxID',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
