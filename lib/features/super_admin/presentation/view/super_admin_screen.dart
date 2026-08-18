import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../../data/models/shop_item_model.dart';
import '../../data/models/shop_detail_model.dart';
import '../../../subscription/domain/entities/payment_entity.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    InjectionContainer.superAdminBloc.add(const FetchSuperAdminDashboardEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Sign Out SuperAdmin'),
          ],
        ),
        content: const Text('Are you sure you want to sign out from the Super Admin portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              InjectionContainer.authBloc.add(const LogoutRequestedEvent());
              context.go('/login');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteShop(BuildContext context, ShopItemModel shop) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Shop?'),
          ],
        ),
        content: Text('Are you sure you want to delete "${shop.name}" (ID: ${shop.id})?\n\nThis action will trigger DELETE /api/admin/shops/${shop.id}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_forever_rounded),
            label: const Text('Delete Shop'),
            onPressed: () {
              Navigator.pop(dialogContext);
              InjectionContainer.superAdminBloc.add(DeleteShopEvent(shop.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Shop deletion requested for ${shop.name}'),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showShopDetailsModal(BuildContext context, String shopId) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Pre-instantiate Future once to preserve state across scroll/drag rebuilds
    final shopDetailsFuture = InjectionContainer.superAdminRemoteDataSource.getShopDetails(shopId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          height: MediaQuery.sizeOf(context).height * 0.75,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.storefront_rounded, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Shop Profile & Details',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder<ShopDetailModel>(
                  future: shopDetailsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Error loading shop details:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    final shopDetail = snapshot.data;
                    if (shopDetail == null) {
                      return const Center(child: Text('No details found for this shop.'));
                    }

                    final isPremium = shopDetail.subscriptionTier.toLowerCase() == 'premium';

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: isPremium ? Colors.amber.shade700 : colorScheme.primary,
                                  child: Icon(
                                    isPremium ? Icons.workspace_premium_rounded : Icons.storefront_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(shopDetail.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      const SizedBox(height: 4),
                                      Text('Owner: ${shopDetail.email}', style: const TextStyle(fontSize: 13)),
                                      const SizedBox(height: 4),
                                      Chip(
                                        label: Text(
                                          '${shopDetail.subscriptionTier.toUpperCase()} TIER',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isPremium ? Colors.amber.shade900 : colorScheme.primary,
                                          ),
                                        ),
                                        backgroundColor: isPremium ? Colors.amber.shade100 : colorScheme.primaryContainer,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Metadata list
                          Text('Shop Information', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.fingerprint_rounded),
                            title: const Text('Shop ID'),
                            subtitle: SelectableText(shopDetail.shopId),
                          ),
                          if (shopDetail.subscriptionExpiresAt != null)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.event_available_rounded),
                              title: const Text('Subscription Expiry Date'),
                              subtitle: Text(shopDetail.subscriptionExpiresAt!),
                            ),
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.calendar_today_rounded),
                            title: const Text('Registration Date'),
                            subtitle: Text(shopDetail.createdAt),
                          ),
                          const SizedBox(height: 20),

                          // Managers section
                          Text(
                            'Registered Managers (${shopDetail.managers.length})',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (shopDetail.managers.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('No managers registered under this shop yet.', style: TextStyle(color: Colors.grey)),
                            )
                          else
                            ...shopDetail.managers.map((m) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person_rounded, size: 20),
                                  ),
                                  title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text(m.email, style: const TextStyle(fontSize: 12)),
                                ),
                              );
                            }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Portal 👑', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Refresh Overview',
            onPressed: () {
              InjectionContainer.superAdminBloc.add(const FetchSuperAdminDashboardEvent());
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Sign Out',
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions_rounded), text: 'Payment Requests'),
            Tab(icon: Icon(Icons.storefront_rounded), text: 'Shops Management'),
          ],
        ),
      ),
      body: StreamBuilder<SuperAdminState>(
        stream: InjectionContainer.superAdminBloc.stream,
        initialData: InjectionContainer.superAdminBloc.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is SuperAdminLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SuperAdminErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error: ${state.message}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => InjectionContainer.superAdminBloc.add(const FetchSuperAdminDashboardEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SuperAdminDashboardLoadedState) {
            final metrics = state.metrics;
            final payments = state.payments;
            final shops = state.shops;

            return Column(
              children: [
                // ===================================
                // PLATFORM METRICS OVERVIEW CARDS
                // ===================================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: Border(bottom: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.insights_rounded, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Platform Metrics Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _MetricCard(
                              title: 'Total Shops',
                              value: '${metrics.totalRegisteredShops}',
                              icon: Icons.storefront_rounded,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 10),
                            _MetricCard(
                              title: 'Subscription Revenue',
                              value: '৳ ${metrics.totalSubscriptionRevenue.toStringAsFixed(0)}',
                              icon: Icons.payments_rounded,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 10),
                            _MetricCard(
                              title: 'Premium / Free',
                              value: '${metrics.premiumTierShopsCount} / ${metrics.freeTierShopsCount}',
                              icon: Icons.workspace_premium_rounded,
                              color: Colors.amber.shade800,
                            ),
                            const SizedBox(width: 10),
                            _MetricCard(
                              title: 'Pending Payments',
                              value: '${metrics.pendingPaymentRequestsCount}',
                              icon: Icons.hourglass_top_rounded,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 10),
                            _MetricCard(
                              title: 'Platform Items',
                              value: '${metrics.platformTotalItems}',
                              icon: Icons.inventory_2_rounded,
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ===================================
                // TAB VIEWS (PAYMENTS & SHOPS)
                // ===================================
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: PENDING PAYMENTS
                      _buildPaymentsTab(payments, colorScheme, theme),

                      // TAB 2: SHOPS MANAGEMENT & DELETION
                      _buildShopsTab(shops, colorScheme, theme),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPaymentsTab(List<PaymentEntity> payments, ColorScheme colorScheme, ThemeData theme) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_rounded, size: 64, color: colorScheme.primary),
            const SizedBox(height: 12),
            const Text('No Pending Payment Submissions!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('All shop subscriptions are up-to-date.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(payment.method.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      backgroundColor: colorScheme.primaryContainer,
                    ),
                    Text(
                      '৳ ${payment.amount.toStringAsFixed(0)}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('TrxID: ${payment.transactionId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text('Shop ID: ${payment.shopId} | Target Tier: ${payment.targetTier.toUpperCase()}'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        InjectionContainer.superAdminBloc.add(RejectPaymentEvent(payment.id));
                      },
                      icon: const Icon(Icons.close_rounded, color: Colors.red),
                      label: const Text('Reject', style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        InjectionContainer.superAdminBloc.add(ApprovePaymentEvent(payment.id));
                      },
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Approve Upgrade', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopsTab(List<ShopItemModel> shops, ColorScheme colorScheme, ThemeData theme) {
    if (shops.isEmpty) {
      return const Center(child: Text('No Shops Registered Yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shops.length,
      itemBuilder: (context, index) {
        final shop = shops[index];
        final isPremium = shop.subscriptionTier.toLowerCase() == 'premium';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showShopDetailsModal(context, shop.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isPremium ? Colors.amber.shade700 : colorScheme.primary,
                    child: Icon(
                      isPremium ? Icons.workspace_premium_rounded : Icons.storefront_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Owner: ${shop.ownerEmail}', style: const TextStyle(fontSize: 13)),
                        if (shop.phone != null) Text('Phone: ${shop.phone}', style: const TextStyle(fontSize: 12)),
                        Text('Managers: ${shop.managerCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        if (shop.subscriptionExpiresAt != null)
                          Text('Expiry: ${shop.subscriptionExpiresAt!.split('T').first}', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isPremium ? Colors.amber.shade100 : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                shop.subscriptionTier.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isPremium ? Colors.amber.shade900 : Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('ID: ${shop.id}', style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete Shop',
                    icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                    onPressed: () => _confirmDeleteShop(context, shop),
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
