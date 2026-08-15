import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      width: MediaQuery.sizeOf(context).width *
          0.82,

      child: SafeArea(
        child: Column(
          children: [
            // =========================
            // PROFILE HEADER
            // =========================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                24,
              ),

              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Container(
                    width: 58,
                    height: 58,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        17,
                      ),
                    ),

                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Inventory Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,

                        decoration:
                        const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 2),

                          Text(
                            'admin@example.com',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // =========================
            // MENU
            // =========================

            Expanded(
              child: ListView(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),

                children: [
                  _DrawerItem(
                    title: 'Dashboard',
                    icon: Icons.dashboard_outlined,
                    activeIcon:
                    Icons.dashboard_rounded,
                    route: '/dashboard',
                    currentRoute: currentRoute,
                  ),

                  _DrawerItem(
                    title: 'POS Billing',
                    icon: Icons.point_of_sale_outlined,
                    activeIcon:
                    Icons.point_of_sale_rounded,
                    route: '/pos-billing',
                    currentRoute: currentRoute,
                  ),

                  _DrawerItem(
                    title: 'Inventory',
                    icon: Icons.inventory_2_outlined,
                    activeIcon:
                    Icons.inventory_2_rounded,
                    route: '/inventory',
                    currentRoute: currentRoute,
                  ),

                  _DrawerItem(
                    title: 'Customers',
                    icon: Icons.people_outline,
                    activeIcon:
                    Icons.people_rounded,
                    route: '/customers',
                    currentRoute: currentRoute,
                  ),

                  _DrawerItem(
                    title: 'Returns',
                    icon: Icons.assignment_return_outlined,
                    activeIcon:
                    Icons.assignment_return_rounded,
                    route: '/returns',
                    currentRoute: currentRoute,
                  ),

                  _DrawerItem(
                    title: 'Reports',
                    icon: Icons.bar_chart_outlined,
                    activeIcon:
                    Icons.bar_chart_rounded,
                    route: '/reports',
                    currentRoute: currentRoute,
                  ),

                  _DrawerItem(
                    title: 'Staff / Managers',
                    icon: Icons.manage_accounts_outlined,
                    activeIcon:
                    Icons.manage_accounts_rounded,
                    route: '/staff-managers',
                    currentRoute: currentRoute,
                  ),

                  _DrawerItem(
                    title: 'Settings',
                    icon: Icons.settings_outlined,
                    activeIcon:
                    Icons.settings_rounded,
                    route: '/settings',
                    currentRoute: currentRoute,
                  ),
                ],
              ),
            ),

            // =========================
            // SIGN OUT
            // =========================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                4,
                12,
                16,
              ),

              child: Column(
                children: [
                  Divider(
                    color: theme.dividerColor,
                  ),

                  const SizedBox(height: 4),

                  ListTile(
                    onTap: () {
                      _showLogoutDialog(context);
                    },

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),

                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                    ),

                    title: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(
      BuildContext context,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Sign Out',
          ),

          content: const Text(
            'Are you sure you want to sign out?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
              ),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                // Firebase sign out এখানে হবে

                context.go('/login');
              },

              child: const Text(
                'Sign Out',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final String currentRoute;

  const _DrawerItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.route,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 4,
      ),

      child: ListTile(
        onTap: () {
          Navigator.pop(context);

          if (!isActive) {
            context.go(route);
          }
        },

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12,
          ),
        ),

        tileColor: isActive
            ? colorScheme.primary
            .withValues(alpha: 0.10)
            : null,

        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive
              ? colorScheme.primary
              : theme.iconTheme.color,
        ),

        title: Text(
          title,
          style: theme.textTheme.bodyMedium
              ?.copyWith(
            fontWeight: isActive
                ? FontWeight.w700
                : FontWeight.w500,

            color: isActive
                ? colorScheme.primary
                : null,
          ),
        ),

        trailing: isActive
            ? Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
        )
            : null,
      ),
    );
  }
}