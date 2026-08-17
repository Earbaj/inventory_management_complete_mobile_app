import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../domain/entities/shop_profile_entity.dart';

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

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _currencyController = TextEditingController(text: '৳');
    _vatRateController = TextEditingController(text: '0.0');

    // Fetch Initial Settings from BLoC
    InjectionContainer.settingsBloc.add(const FetchSettingsEvent());
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _currencyController.dispose();
    _vatRateController.dispose();
    super.dispose();
  }

  void _populateControllers(ShopProfileEntity profile) {
    if (_shopNameController.text.isEmpty) {
      _shopNameController.text = profile.shopName;
      _phoneController.text = profile.phone;
      _emailController.text = profile.email ?? '';
      _addressController.text = profile.address ?? '';
      _currencyController.text = profile.currencySymbol;
      _vatRateController.text = profile.defaultVatRate.toString();
    }
  }

  void _saveSettings(ShopProfileEntity currentProfile) {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = currentProfile.copyWith(
        shopName: _shopNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        currencySymbol: _currencyController.text.trim(),
        defaultVatRate: double.tryParse(_vatRateController.text.trim()) ?? 0.0,
      );

      InjectionContainer.settingsBloc.add(UpdateShopProfileEvent(updated));
    }
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

          if (state is SettingsErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      InjectionContainer.settingsBloc.add(const FetchSettingsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final loadedState = state is SettingsLoadedState ? state : null;
          final profile = loadedState?.profile ??
              const ShopProfileEntity(
                id: '1',
                shopName: 'My Enterprise Store',
                phone: '01700000000',
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
                              Row(
                                children: [
                                  Icon(
                                    subscription.isPremium ? Icons.workspace_premium_rounded : Icons.star_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${subscription.tier.toUpperCase()} TIER',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              if (subscription.isFreeTier)
                                ElevatedButton(
                                  onPressed: () {
                                    InjectionContainer.settingsBloc.add(const UpgradeSubscriptionEvent('premium'));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: colorScheme.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('UPGRADE', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Customers Limit: ${subscription.customerCount} / ${subscription.maxCustomers == -1 ? "Unlimited" : subscription.maxCustomers}',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              Text(
                                'Sales Limit: ${subscription.salesCount} / ${subscription.maxSales == -1 ? "Unlimited" : subscription.maxSales}',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

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

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _currencyController,
                          decoration: InputDecoration(
                            labelText: 'Currency Symbol',
                            prefixIcon: const Icon(Icons.attach_money_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _vatRateController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Default VAT (%)',
                            prefixIcon: const Icon(Icons.percent_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _saveSettings(profile),
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
