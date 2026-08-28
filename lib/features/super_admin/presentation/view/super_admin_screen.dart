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
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Icon Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Sign Out',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Are you sure you want to sign out from the Super Admin portal?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Sign Out Button
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        // Add a small delay for smooth animation
                        Future.delayed(const Duration(milliseconds: 300), () {
                          InjectionContainer.authBloc.add(const LogoutRequestedEvent());
                          context.go('/login');
                        });
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  void _showRejectDialog(BuildContext context, String paymentId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Reject Payment Request'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter a reason for rejecting this payment submission (Optional):'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'e.g. Invalid TrxID or Amount mismatch',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogCtx);
              InjectionContainer.superAdminBloc.add(
                RejectPaymentEvent(paymentId, reason: reasonController.text.trim()),
              );
            },
            child: const Text('Reject Payment'),
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
        centerTitle: false,
        title: const Text('Super Admin Portal', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // Helper Widget for Decorative Dots
  Widget _buildDot(BuildContext context, Color color) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
  Widget _buildPaymentsTab(List<PaymentEntity> payments, ColorScheme colorScheme, ThemeData theme) {
    if (payments.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Container with Gradient
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.width * 0.35,
                constraints: const BoxConstraints(
                  minWidth: 100,
                  minHeight: 100,
                  maxWidth: 200,
                  maxHeight: 200,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.2),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.verified_rounded,
                  size: MediaQuery.of(context).size.width * 0.12,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 28),

              // Main Title
              Text(
                'All Caught Up! 🎉',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 22,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'No Pending Payment Submissions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 15,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                'All shop subscriptions are currently up-to-date\nand fully verified.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.6,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 14,
                ),
              ),

              const SizedBox(height: 30),

              // Animated Decorative Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(context, Colors.green),
                  const SizedBox(width: 8),
                  _buildDot(context, Colors.green.shade300),
                  const SizedBox(width: 8),
                  _buildDot(context, Colors.green.shade100),
                ],
              ),
            ],
          ),
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
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRejectDialog(context, payment.id),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        label: const Text('Reject', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          InjectionContainer.superAdminBloc.add(ApprovePaymentEvent(payment.id));
                        },
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                        ),
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
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Container with Gradient
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.width * 0.35,
                constraints: const BoxConstraints(
                  minWidth: 100,
                  minHeight: 100,
                  maxWidth: 200,
                  maxHeight: 200,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.2),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.store_rounded,
                  size: MediaQuery.of(context).size.width * 0.12,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 28),

              // Main Title
              Text(
                'No Shops Yet! 🏪',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 22,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'No Shops Registered Yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 15,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                'When People register and create shop than those list will be shown here',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.6,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 14,
                ),
              ),

              const SizedBox(height: 20),

              // Animated Decorative Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(context, Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  _buildDot(context, Theme.of(context).primaryColor.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  _buildDot(context, Theme.of(context).primaryColor.withOpacity(0.2)),
                ],
              ),
            ],
          ),
        ),
      );
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
