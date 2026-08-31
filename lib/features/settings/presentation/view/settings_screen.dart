import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../inventory/domain/entities/inventory_item_entity.dart';
import '../../../posbilling/domain/entities/cart_item_entity.dart';
import '../../../posbilling/domain/entities/sale_entity.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../domain/entities/shop_profile_entity.dart';
import '../../../subscription/data/models/payment_model.dart';
import '../widgets/subscription_card.dart';
import '../widgets/payment_history_section.dart';

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
  InvoicePdfFormat _selectedPdfFormat = InvoicePdfFormat.classic;

  final List<Map<String, String>> _currencies = [
    {'code': 'BDT', 'symbol': '৳', 'name': 'BDT (৳ - Taka)'},
    {'code': 'USD', 'symbol': '\$', 'name': 'USD (\$ - US Dollar)'},
    {'code': 'EUR', 'symbol': '€', 'name': 'EUR (€ - Euro)'},
    {'code': 'GBP', 'symbol': '£', 'name': 'GBP (£ - Pound)'},
    {'code': 'INR', 'symbol': '₹', 'name': 'INR (₹ - Rupee)'},
    {'code': 'AED', 'symbol': 'AED ', 'name': 'AED (UAE Dirham)'},
    {'code': 'SAR', 'symbol': 'SAR ', 'name': 'SAR (Saudi Riyal)'},
    {'code': 'CAD', 'symbol': 'CA\$', 'name': 'CAD (CA Dollar)'},
    {'code': 'AUD', 'symbol': 'AU\$', 'name': 'AUD (AU Dollar)'},
    {'code': 'MYR', 'symbol': 'RM ', 'name': 'MYR (Ringgit)'},
    {'code': 'SGD', 'symbol': 'SG\$', 'name': 'SGD (SG Dollar)'},
    {'code': 'PKR', 'symbol': 'Rs ', 'name': 'PKR (PK Rupee)'},
  ];
  String _selectedCurrencyCode = 'BDT';

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _currencyController = TextEditingController(text: 'BDT');
    _vatRateController = TextEditingController(text: '0.0');
    _logoUrlController = TextEditingController();

    // Fetch Initial Settings, Saved PDF Format, and Payment History
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsBloc>().add(const FetchSettingsEvent());
      _loadSavedPdfFormat();
      _fetchPaymentHistory();
    });
  }

  Future<void> _loadSavedPdfFormat() async {
    final format = await PdfExportService.getSavedInvoicePdfFormat();
    if (mounted) {
      setState(() {
        _selectedPdfFormat = format;
      });
    }
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

      final code = profile.currencyCode.isNotEmpty
          ? profile.currencyCode.toUpperCase()
          : (profile.currencySymbol == '\$'
              ? 'USD'
              : (profile.currencySymbol == '€'
                  ? 'EUR'
                  : (profile.currencySymbol == '£' ? 'GBP' : 'BDT')));
      _selectedCurrencyCode = code;
      _currencyController.text = code;
    }
  }

  void _saveSettings(ShopProfileEntity currentProfile) {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      final matchedCurrency = _currencies.firstWhere(
        (c) => c['code'] == _selectedCurrencyCode,
        orElse: () => {'code': _selectedCurrencyCode, 'symbol': '৳', 'name': _selectedCurrencyCode},
      );

      final updated = currentProfile.copyWith(
        shopName: _shopNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        currencyCode: matchedCurrency['code'] ?? 'BDT',
        currencySymbol: matchedCurrency['symbol'] ?? '৳',
        defaultVatRate: double.tryParse(_vatRateController.text.trim()) ?? 0.0,
        logoUrl: _logoUrlController.text.trim().isEmpty ? null : _logoUrlController.text.trim(),
      );

      PdfExportService.saveInvoicePdfFormat(_selectedPdfFormat);
      context.read<SettingsBloc>().add(UpdateShopProfileEvent(updated));
    }
  }

  void _previewPdfFormat(InvoicePdfFormat format, ShopProfileEntity profile) {
    final sampleSale = SaleEntity(
      id: 'sample-001',
      invoiceNo: 'INV-SAMPLE-2026',
      customer: const CustomerEntity(
        id: 'cust-1',
        name: 'Rahim Chowdhury',
        phone: '01812345678',
        openingBalance: 0.0,
      ),
      items: [
        CartItemEntity(
          item: const InventoryItemEntity(
            id: 'item-1',
            name: 'Wireless Bluetooth Mouse',
            sku: 'MOU-001',
            category: 'Electronics',
            unit: 'pcs',
            stockQuantity: 45,
            lowStockQuantity: 5,
            retailSellPrice: 850.0,
            purchasePrice: 600.0,
          ),
          quantity: 2,
        ),
        CartItemEntity(
          item: const InventoryItemEntity(
            id: 'item-2',
            name: 'Mechanical RGB Keyboard',
            sku: 'KEY-002',
            category: 'Electronics',
            unit: 'pcs',
            stockQuantity: 20,
            lowStockQuantity: 3,
            retailSellPrice: 3200.0,
            purchasePrice: 2400.0,
          ),
          quantity: 1,
        ),
      ],
      subtotal: 4900.0,
      discountAmount: 100.0,
      vatAmount: 0.0,
      netTotal: 4800.0,
      paidAmount: 4800.0,
      dueAmount: 0.0,
      paymentMethod: 'cash',
      servedBy: 'Staff Cashier',
      createdAt: DateTime.now(),
    );

    PdfExportService.printOrSaveInvoicePdf(
      context,
      sale: sampleSale,
      shopProfile: profile,
      format: format,
    );
  }

  Widget _buildPdfFormatSection(ThemeData theme, ColorScheme colorScheme, ShopProfileEntity profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Invoice PDF Print Template',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${InvoicePdfFormat.values.length} Formats Available',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Select your preferred invoice PDF layout used for printing and saving receipts.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        ...InvoicePdfFormat.values.map((format) {
          final isSelected = _selectedPdfFormat == format;
          IconData icon;
          switch (format) {
            case InvoicePdfFormat.classic:
              icon = Icons.receipt_long_rounded;
              break;
            case InvoicePdfFormat.modern:
              icon = Icons.auto_awesome_mosaic_rounded;
              break;
            case InvoicePdfFormat.thermalPos:
              icon = Icons.point_of_sale_rounded;
              break;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: isSelected ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isSelected ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.25) : colorScheme.surface,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() => _selectedPdfFormat = format);
                PdfExportService.saveInvoicePdfFormat(format);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected print format: ${format.title}'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                format.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected ? colorScheme.primary : null,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            format.subtitle,
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: () => _previewPdfFormat(format, profile),
                      icon: const Icon(Icons.visibility_outlined, size: 20),
                      tooltip: 'Preview ${format.title}',
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
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
              context.read<SettingsBloc>().add(const FetchSettingsEvent());
              _fetchPaymentHistory();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          developer.log('🔔 [SettingsScreen] BlocConsumer received state: $state', name: 'SettingsScreen');
          if (state is SettingsLoadedState) {
            _populateControllers(state.profile);
          } else if (state is SettingsOperationSuccessState) {
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
        },
        builder: (context, state) {
          developer.log('🔄 [SettingsScreen] BlocConsumer Builder Rebuilding. State: $state', name: 'SettingsScreen');

          if (state is SettingsLoadingState) {
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

          // Double check population in builder in case it's built initially with loaded state
          if (loadedState != null) {
            _populateControllers(loadedState.profile);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SUBSCRIPTION TIER BANNER CARD
                  if (subscription != null) ...[
                    SubscriptionCard(
                      subscription: subscription,
                      onCheckoutSuccess: () {
                        context.read<SettingsBloc>().add(const FetchSettingsEvent());
                        _fetchPaymentHistory();
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // INVOICE PDF PRINT TEMPLATES SECTION
                  _buildPdfFormatSection(theme, colorScheme, profile),
                  const SizedBox(height: 24),

                  // PAYMENT REQUEST HISTORY SECTION
                  PaymentHistorySection(
                    payments: _myPayments,
                    isLoading: _isLoadingPayments,
                    onRefresh: _fetchPaymentHistory,
                  ),
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
                          value: _currencies.any((c) => c['code'] == _selectedCurrencyCode)
                              ? _selectedCurrencyCode
                              : 'BDT',
                          decoration: InputDecoration(
                            labelText: 'Currency',
                            prefixIcon: const Icon(Icons.attach_money_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _currencies.map((c) {
                            return DropdownMenuItem<String>(
                              value: c['code'],
                              child: Text(c['name']!),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCurrencyCode = val;
                                _currencyController.text = val;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
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
