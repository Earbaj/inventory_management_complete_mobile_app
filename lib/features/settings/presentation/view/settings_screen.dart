import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../domain/entities/shop_profile_entity.dart';
import '../../../subscription/presentation/widget/payment_checkout_modal.dart';
import '../../../subscription/data/models/payment_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _currencyController;
  late TextEditingController _vatRateController;
  late TextEditingController _logoUrlController;

  List<PaymentModel> _myPayments = [];
  bool _isLoadingPayments = false;
  bool _isSaving = false;

  final List<Map<String, String>> _currencies = [
    {'symbol': '৳', 'name': 'BDT (৳)'},
    {'symbol': '\$', 'name': 'USD (\$)'},
    {'symbol': '€', 'name': 'EUR (€)'},
    {'symbol': '£', 'name': 'GBP (£)'},
  ];
  String _selectedCurrencySymbol = '৳';

  StreamSubscription<SettingsState>? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _currencyController = TextEditingController(text: '৳');
    _vatRateController = TextEditingController(text: '0.0');
    _logoUrlController = TextEditingController();

    // Fetch Initial Settings and Payment History
    InjectionContainer.settingsBloc.add(const FetchSettingsEvent());
    _fetchPaymentHistory();

    _settingsSubscription = InjectionContainer.settingsBloc.stream.listen((state) {
      if (!mounted) return;
      if (state is SettingsOperationSuccessState) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.green),
        );
      } else if (state is SettingsErrorState) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
        );
      }
    });
  }

  Future<void> _fetchPaymentHistory() async {
    setState(() => _isLoadingPayments = true);
    try {
      final payments = await InjectionContainer.subscriptionRemoteDataSource.getPaymentLogs();
      if (mounted) {
        setState(() {
          _myPayments = payments;
          _isLoadingPayments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPayments = false);
    }
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    _shopNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _currencyController.dispose();
    _vatRateController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  void _populateControllers(ShopProfileEntity profile) {
    if (_shopNameController.text.isEmpty) {
      _shopNameController.text = profile.shopName;
      _phoneController.text = profile.phone;
      _emailController.text = profile.email ?? '';
      _addressController.text = profile.address ?? '';
      _vatRateController.text = profile.defaultVatRate.toString();
      _logoUrlController.text = profile.logoUrl ?? '';

      final symbol = profile.currencySymbol.isNotEmpty ? profile.currencySymbol : '৳';
      _selectedCurrencySymbol = symbol;
      _currencyController.text = symbol;
    }
  }

  void _saveSettings(ShopProfileEntity currentProfile) {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      final updated = currentProfile.copyWith(
        shopName: _shopNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        currencySymbol: _currencyController.text.trim(),
        defaultVatRate: double.tryParse(_vatRateController.text.trim()) ?? 0.0,
        logoUrl: _logoUrlController.text.trim().isEmpty ? null : _logoUrlController.text.trim(),
      );

      InjectionContainer.settingsBloc.add(UpdateShopProfileEvent(updated));
    }
  }

  void _openCheckoutModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PaymentCheckoutModal(),
    ).then((res) {
      if (res == true) {
        InjectionContainer.settingsBloc.add(const FetchSettingsEvent());
        _fetchPaymentHistory();
      }
    });
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
        title: const Text('Shop Settings & Subscription'),
        actions: [
          IconButton(
            onPressed: () {
              InjectionContainer.settingsBloc.add(const FetchSettingsEvent());
              _fetchPaymentHistory();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: StreamBuilder<SettingsState>(
        stream: InjectionContainer.settingsBloc.stream,
        initialData: InjectionContainer.settingsBloc.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is SettingsLoadingState && state is! SettingsLoadedState) {
            return const Center(child: CircularProgressIndicator());
          }

          final loadedState = state is SettingsLoadedState ? state : null;
          final profile = loadedState?.profile ??
              const ShopProfileEntity(
                id: '1',
                shopName: 'Smart Inventory POS Store',
                phone: '01700000000',
                email: 'earbaj@gmail.com',
                address: 'Dhaka, Bangladesh',
                currencySymbol: '৳',
              );
          final subscription = loadedState?.subscription;

          _populateControllers(profile);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SUBSCRIPTION TIER BANNER CARD
                  if (subscription != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: subscription.isPremium
                              ? [Colors.amber.shade700, Colors.orange.shade800]
                              : [colorScheme.primary, colorScheme.tertiary],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
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
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      subscription.isPremium ? Icons.workspace_premium_rounded : Icons.star_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '${subscription.tier.toUpperCase()} TIER',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          letterSpacing: 1.2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 130, minWidth: 80),
                                child: ElevatedButton(
                                  onPressed: () => _openCheckoutModal(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: colorScheme.primary,
                                    minimumSize: const Size(80, 36),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: Text(
                                    subscription.isFreeTier ? 'UPGRADE' : 'EXTEND',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Customers Limit: ${subscription.customerCount} / ${subscription.maxCustomers == -1 ? "Unlimited" : subscription.maxCustomers}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Sales Limit: ${subscription.salesCount} / ${subscription.maxSales == -1 ? "Unlimited" : subscription.maxSales}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // PAYMENT REQUEST HISTORY SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Request History',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: _fetchPaymentHistory,
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        tooltip: 'Refresh Payment History',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_isLoadingPayments) ...[
                    const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                  ] else if (_myPayments.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.grey, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No manual bKash/Nagad payment requests submitted yet.',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Column(
                      children: _myPayments.map((payment) {
                        final isApproved = payment.status.toLowerCase() == 'approved';
                        final isRejected = payment.status.toLowerCase() == 'rejected';

                        final Color statusColor = isApproved
                            ? Colors.green[700]!
                            : (isRejected ? Colors.red[700]! : Colors.orange[800]!);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'TrxID: ${payment.transactionId}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        payment.status.toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Method: ${payment.method.toUpperCase()} | Tier: ${payment.targetTier.toUpperCase()}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      '৳${payment.amount.toStringAsFixed(0)}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                                    ),
                                  ],
                                ),
                                if (isRejected && payment.rejectionReason != null && payment.rejectionReason!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 16),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Reason: ${payment.rejectionReason}',
                                            style: const TextStyle(color: Colors.red, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // SHOP PROFILE EDIT FORM
                  Text(
                    'Shop Details & Configuration',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _shopNameController,
                    decoration: InputDecoration(
                      labelText: 'Shop Name',
                      prefixIcon: const Icon(Icons.store_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter shop name' : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter phone number' : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address (Optional)',
                      prefixIcon: const Icon(Icons.email_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Shop Address (Optional)',
                      prefixIcon: const Icon(Icons.location_on_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _logoUrlController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'Logo URL (Optional)',
                      prefixIcon: const Icon(Icons.image_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'https://example.com/logo.png',
                    ),
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty) {
                        final uri = Uri.tryParse(val.trim());
                        if (uri == null || !uri.hasAbsolutePath) {
                          return 'Enter a valid URL';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _currencies.any((c) => c['symbol'] == _selectedCurrencySymbol)
                              ? _selectedCurrencySymbol
                              : '৳',
                          decoration: InputDecoration(
                            labelText: 'Currency',
                            prefixIcon: const Icon(Icons.attach_money_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _currencies.map((c) {
                            return DropdownMenuItem<String>(
                              value: c['symbol'],
                              child: Text(c['name']!),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCurrencySymbol = val;
                                _currencyController.text = val;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _vatRateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Default VAT (%)',
                            prefixIcon: const Icon(Icons.percent_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              final parsed = double.tryParse(val.trim());
                              if (parsed == null || parsed < 0) {
                                return 'Enter a valid positive number';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _saveSettings(profile),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_rounded),
                                SizedBox(width: 8),
                                Text('Save Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
