import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../../core/utils/money_util.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';
import '../../../inventory/presentation/bloc/inventory_state.dart';
import '../../../posbilling/domain/entities/sale_entity.dart';
import '../../../reports/presentation/bloc/reports_bloc.dart';
import '../../../reports/presentation/bloc/reports_state.dart';

class EasyDashboardView extends StatelessWidget {
  final bool isAdmin;

  const EasyDashboardView({
    super.key,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. SIMPLE GREETING & MODE BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.storefront_rounded, color: colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'দোকানের সহজ হিসাব 📋',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'সব তথ্য সহজে এক নজরে দেখুন',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. THREE BIG PRIMARY CARDS (HIGH CONTRAST)
          // CARD 1: TOTAL SALES (মোট বিক্রি)
          BlocBuilder<ReportsBloc, ReportsState>(
            builder: (context, snapshot) {
              final summary = snapshot is ReportsLoadedState ? snapshot.summary : null;
              final double revenue = summary != null ? summary.totalRevenue : 0.0;
              final int count = summary != null ? summary.totalSalesCount : 0;

              return _buildHeroCard(
                context,
                title: 'আজকের মোট বিক্রি',
                subtitle: '$count টি মেমো তৈরি হয়েছে',
                value: '${MoneyUtil.currencySymbol} ${revenue.toStringAsFixed(0)}',
                badgeText: 'সফল বিক্রি',
                icon: Icons.point_of_sale_rounded,
                bgColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F9F0),
                accentColor: const Color(0xFF059669),
                onTap: () {
                  AppRoute.shellScaffoldKey.currentState?.openDrawer();
                },
              );
            },
          ),
          const SizedBox(height: 12),

          // CARD 2: CUSTOMER DUE (কাস্টমারদের কাছে বাকি)
          BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, snapshot) {
              final custState = snapshot is CustomerLoadedState
                  ? snapshot
                  : InjectionContainer.customerBloc.state;

              double due = 0.0;
              int dueCustomersCount = 0;
              if (custState is CustomerLoadedState && custState.customers.isNotEmpty) {
                for (final c in custState.customers) {
                  if (c.totalDue > 0) {
                    due += c.totalDue;
                    dueCustomersCount++;
                  }
                }
              }

              if (due == 0.0) {
                final reportsState = InjectionContainer.reportsBloc.state;
                if (reportsState is ReportsLoadedState) {
                  due = reportsState.summary.totalDue > 0
                      ? reportsState.summary.totalDue
                      : reportsState.summary.dueRevenue;
                }
              }

              return _buildHeroCard(
                context,
                title: 'কাস্টমারদের কাছে বাকি আছে',
                subtitle: dueCustomersCount > 0
                    ? '$dueCustomersCount জন কাস্টমারের বকেয়া'
                    : 'বাকি আদায়ের তালিকা দেখুন',
                value: '${MoneyUtil.currencySymbol} ${due.toStringAsFixed(0)}',
                badgeText: 'তাগাদা দিন',
                icon: Icons.account_balance_wallet_rounded,
                bgColor: isDark ? const Color(0xFF431407) : const Color(0xFFFFF4EC),
                accentColor: const Color(0xFFEA580C),
                onTap: () {
                  AppRoute.shellScaffoldKey.currentState?.openDrawer();
                },
              );
            },
          ),
          const SizedBox(height: 12),

          // CARD 3: STOCK & INVENTORY (দোকানের মালামাল ও স্টক)
          BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, snapshot) {
              final state = snapshot is InventoryLoadedState
                  ? snapshot
                  : InjectionContainer.inventoryBloc.state;
              final int totalItems = state is InventoryLoadedState ? state.items.length : 0;
              final int lowStock = state is InventoryLoadedState
                  ? state.items.where((i) => i.isLowStock || i.isOutOfStock).length
                  : 0;

              return _buildHeroCard(
                context,
                title: 'দোকানের মোট মালামাল',
                subtitle: lowStock > 0
                    ? '⚠️ $lowStock টি পণ্য শেষ হওয়ার পথে!'
                    : 'সব পণ্য স্টকে পর্যাপ্ত আছে',
                value: '$totalItems টি আইটেম',
                badgeText: lowStock > 0 ? 'স্টক সতর্কবার্তা' : 'স্টক ওকে',
                icon: Icons.inventory_2_rounded,
                bgColor: isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF),
                accentColor: const Color(0xFF2563EB),
                onTap: () {
                  AppRoute.shellScaffoldKey.currentState?.openDrawer();
                },
              );
            },
          ),
          const SizedBox(height: 20),

          // 3. SIMPLE CASH & PAYMENT BREAKDOWN CARD
          BlocBuilder<ReportsBloc, ReportsState>(
            builder: (context, snapshot) {
              final summary = snapshot is ReportsLoadedState ? snapshot.summary : null;
              final cash = summary != null ? summary.cashRevenue : 0.0;
              final digital = summary != null ? summary.digitalRevenue : 0.0;
              final due = summary != null ? summary.dueRevenue : 0.0;

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pie_chart_outline_rounded, color: Colors.indigo, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'টাকা কীভাবে এসেছে (সহজ হিসাব)',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniBreakdownTile(
                            label: 'নগদ ক্যাশ 💵',
                            amount: '${MoneyUtil.currencySymbol} ${cash.toStringAsFixed(0)}',
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMiniBreakdownTile(
                            label: 'বিকাশ/কার্ড 📱',
                            amount: '${MoneyUtil.currencySymbol} ${digital.toStringAsFixed(0)}',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMiniBreakdownTile(
                            label: 'বাকি বিক্রি ⏳',
                            amount: '${MoneyUtil.currencySymbol} ${due.toStringAsFixed(0)}',
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // 4. BIG ONE-TOUCH ACTION BUTTONS
          Text(
            'সরাসরি কাজ করুন 🚀',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildBigActionButton(
                  context,
                  icon: Icons.add_shopping_cart_rounded,
                  label: 'নতুন বিক্রি\n(POS)',
                  color: const Color(0xFF059669),
                  onTap: () {
                    AppRoute.shellScaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBigActionButton(
                  context,
                  icon: Icons.add_box_rounded,
                  label: 'নতুন পণ্য\nযোগ করুন',
                  color: const Color(0xFF2563EB),
                  onTap: () {
                    AppRoute.shellScaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBigActionButton(
                  context,
                  icon: Icons.people_alt_rounded,
                  label: 'কাস্টমারদের\nবাকি তুলুন',
                  color: const Color(0xFFEA580C),
                  onTap: () {
                    AppRoute.shellScaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 5. RECENT SALES IN PLAIN WORDS
          StreamBuilder<ReportsState>(
            stream: InjectionContainer.reportsBloc.stream,
            initialData: InjectionContainer.reportsBloc.state,
            builder: (context, snapshot) {
              final state = snapshot.data is ReportsLoadedState
                  ? snapshot.data
                  : InjectionContainer.reportsBloc.state;
              final List<SaleEntity> logs = state is ReportsLoadedState ? state.invoiceLogs : [];
              final recentList = logs.take(5).toList();

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded, color: Colors.teal, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'শেষ কয়েকটি বিক্রি 🧾',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/reports'),
                          child: const Text('সব দেখুন'),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    if (recentList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            'আজকের কোনো বিক্রি পাওয়া যায়নি।\nনতুন বিক্রি করতে উপরের বাটন চাপুন।',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentList.length,
                        separatorBuilder: (_, _) => const Divider(height: 12),
                        itemBuilder: (context, index) {
                          final sale = recentList[index];
                          final isPaid = sale.dueAmount <= 0;
                          final customerName = sale.customer?.name ?? 'সাধারণ খরিদ্দার';

                          return Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isPaid ? Icons.check_circle_outline_rounded : Icons.pending_actions_rounded,
                                  color: isPaid ? Colors.green : Colors.orange,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customerName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'মেমো #${sale.invoiceNo} • ${sale.paymentMethod.toUpperCase()}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${MoneyUtil.currencySymbol} ${sale.netTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    isPaid ? 'পরিশোধিত' : 'বাকি আছে',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isPaid ? Colors.green : Colors.deepOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required String badgeText,
    required IconData icon,
    required Color bgColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: accentColor.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBreakdownTile({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
