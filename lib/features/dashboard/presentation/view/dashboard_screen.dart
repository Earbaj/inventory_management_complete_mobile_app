import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import '../widgets/profit_chart.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/sales_chart.dart';
import '../widgets/stat_card.dart';
import '../widgets/top_selling_items.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedPeriod = 'This Week';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      drawer: const AppDrawer(
        currentRoute: '/dashboard',
      ),

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // =========================
            // HEADER
            // =========================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  10,
                ),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) {
                        return IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor:
                            colorScheme.surface,
                          ),
                          icon: const Icon(
                            Icons.menu_rounded,
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning, Admin 👋',
                            style: theme
                                .textTheme
                                .titleLarge,
                          ),

                          const SizedBox(height: 3),

                          Text(
                            "Here's what's happening "
                                "with your business today.",
                            style: theme
                                .textTheme
                                .bodySmall,
                          ),
                        ],
                      ),
                    ),

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: () {
                            // Notifications
                          },
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                          ),
                        ),

                        Positioned(
                          right: 5,
                          top: 3,
                          child: Container(
                            width: 19,
                            height: 19,
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
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

            // =========================
            // FILTER
            // =========================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  20,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterButton(
                        icon: Icons.calendar_month_outlined,
                        title: '18 May - 24 May',
                        onTap: () {},
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _FilterButton(
                        icon: Icons.keyboard_arrow_down_rounded,
                        title: selectedPeriod,
                        iconAtEnd: true,
                        onTap: () {
                          _showPeriodPicker();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =========================
            // STAT CARDS
            // =========================

            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate(
                  [
                    StatCard(
                      title: 'Total Sell',
                      value: '৳ 1,24,580',
                      icon: Icons.shopping_bag_outlined,
                      iconBackground:
                      const Color(0xFFE8F0FF),
                      iconColor:
                      const Color(0xFF2563EB),
                      percentage: '14.5%',
                      isPositive: true,
                    ),

                    StatCard(
                      title: 'Total Profit',
                      value: '৳ 28,450',
                      icon: Icons.trending_up_rounded,
                      iconBackground:
                      const Color(0xFFE7F9EF),
                      iconColor:
                      const Color(0xFF10B981),
                      percentage: '18.7%',
                      isPositive: true,
                    ),

                    StatCard(
                      title: 'Outstanding Due',
                      value: '৳ 54,780',
                      icon: Icons.account_balance_wallet_outlined,
                      iconBackground:
                      const Color(0xFFFFF2E5),
                      iconColor:
                      const Color(0xFFF97316),
                      percentage: '8.3%',
                      isPositive: true,
                    ),

                    StatCard(
                      title: 'Low Stock Alert',
                      value: '12',
                      icon: Icons.warning_amber_rounded,
                      iconBackground:
                      const Color(0xFFFFE9EC),
                      iconColor:
                      const Color(0xFFEF4444),
                      subtitle: 'Items need attention',
                    ),

                    StatCard(
                      title: 'Items Sold',
                      value: '1,245',
                      icon: Icons.inventory_2_outlined,
                      iconBackground:
                      const Color(0xFFF0E9FF),
                      iconColor:
                      const Color(0xFF8B5CF6),
                      percentage: '12.2%',
                      isPositive: true,
                    ),

                    StatCard(
                      title: 'Net Profit',
                      value: '৳ 24,350',
                      icon: Icons.pie_chart_outline_rounded,
                      iconBackground:
                      const Color(0xFFE7F8F5),
                      iconColor:
                      const Color(0xFF14B8A6),
                      percentage: '16.9%',
                      isPositive: true,
                    ),

                    StatCard(
                      title: 'Discount / Losses',
                      value: '৳ 4,350',
                      icon: Icons.sell_outlined,
                      iconBackground:
                      const Color(0xFFFFE9EC),
                      iconColor:
                      const Color(0xFFEF4444),
                      percentage: '6.4%',
                      isPositive: false,
                    ),

                    StatCard(
                      title: 'Return Invoice',
                      value: '18',
                      icon: Icons.assignment_return_outlined,
                      iconBackground:
                      const Color(0xFFEAF2FF),
                      iconColor:
                      const Color(0xFF3B82F6),
                      percentage: '10.2%',
                      isPositive: true,
                    ),
                  ],
                ),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.28,
                ),
              ),
            ),

            // =========================
            // CHARTS
            // =========================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  0,
                ),
                child: Column(
                  children: const [
                    SalesChart(),
                    SizedBox(height: 16),
                    ProfitChart(),
                  ],
                ),
              ),
            ),

            // =========================
            // TOP SELLING
            // =========================

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  0,
                ),
                child: TopSellingItems(),
              ),
            ),

            // =========================
            // RECENT TRANSACTIONS
            // =========================

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  30,
                ),
                child: RecentTransactions(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final options = [
          'Today',
          'This Week',
          'This Month',
          'This Year',
        ];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),

              const Text(
                'Select Period',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              ...options.map(
                    (option) {
                  return ListTile(
                    title: Text(option),
                    trailing:
                    selectedPeriod == option
                        ? const Icon(
                      Icons.check,
                    )
                        : null,
                    onTap: () {
                      setState(() {
                        selectedPeriod = option;
                      });

                      Navigator.pop(context);
                    },
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool iconAtEnd;
  final VoidCallback onTap;

  const _FilterButton({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconAtEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            if (!iconAtEnd)
              Icon(
                icon,
                size: 19,
              ),

            if (!iconAtEnd)
              const SizedBox(width: 8),

            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),

            if (iconAtEnd)
              Icon(
                icon,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}