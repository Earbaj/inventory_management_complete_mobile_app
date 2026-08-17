import 'package:flutter/material.dart';
import '../../../../core/route/app_route.dart';
import '../../staff_manager_model.dart';
import '../widget/add_staff_dialog.dart';
import '../widget/staff_card.dart';

class StaffManagersScreen extends StatefulWidget {
  const StaffManagersScreen({super.key});

  @override
  State<StaffManagersScreen> createState() => _StaffManagersScreenState();
}

class _StaffManagersScreenState extends State<StaffManagersScreen> {
  final TextEditingController _searchController = TextEditingController();

  StaffRole? _selectedRoleFilter;
  late List<StaffMember> _staffList;

  @override
  void initState() {
    super.initState();
    _initDemoData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initDemoData() {
    final now = DateTime.now();
    _staffList = [
      StaffMember(
        id: '1',
        name: 'Manager Dave',
        email: 'dave.manager@store.com',
        phone: '01711223344',
        role: StaffRole.seniorManager,
        status: StaffStatus.active,
        joinedDate: now.subtract(const Duration(days: 365)),
        assignedBranch: 'Main Branch',
        salesServedCount: 142,
      ),
      StaffMember(
        id: '2',
        name: 'Rahim Ahmed',
        email: 'rahim@store.com',
        phone: '01899887766',
        role: StaffRole.manager,
        status: StaffStatus.active,
        joinedDate: now.subtract(const Duration(days: 180)),
        assignedBranch: 'Gulshan Branch',
        salesServedCount: 98,
      ),
      StaffMember(
        id: '3',
        name: 'Sarah Jenkins',
        email: 'sarah.staff@store.com',
        phone: '01955443322',
        role: StaffRole.cashier,
        status: StaffStatus.active,
        joinedDate: now.subtract(const Duration(days: 90)),
        assignedBranch: 'Main Branch',
        salesServedCount: 210,
      ),
      StaffMember(
        id: '4',
        name: 'Kamal Hossain',
        email: 'kamal.inventory@store.com',
        phone: '01677889900',
        role: StaffRole.inventoryStaff,
        status: StaffStatus.active,
        joinedDate: now.subtract(const Duration(days: 45)),
        assignedBranch: 'Central Warehouse',
        salesServedCount: 15,
      ),
      StaffMember(
        id: '5',
        name: 'Tariq Islam',
        email: 'tariq.m@store.com',
        phone: '01511335577',
        role: StaffRole.manager,
        status: StaffStatus.inactive,
        joinedDate: now.subtract(const Duration(days: 300)),
        assignedBranch: 'Dhanmondi Outlet',
        salesServedCount: 45,
      ),
    ];
  }

  List<StaffMember> get _filteredStaff {
    final query = _searchController.text.trim().toLowerCase();

    return _staffList.where((staff) {
      final matchesSearch = query.isEmpty ||
          staff.name.toLowerCase().contains(query) ||
          staff.email.toLowerCase().contains(query) ||
          staff.phone.toLowerCase().contains(query) ||
          staff.assignedBranch.toLowerCase().contains(query) ||
          staff.role.label.toLowerCase().contains(query);

      final matchesRole = _selectedRoleFilter == null || staff.role == _selectedRoleFilter;

      return matchesSearch && matchesRole;
    }).toList();
  }

  void _handleAddStaff(StaffMember staff) {
    setState(() {
      _staffList.insert(0, staff);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${staff.name} (${staff.role.label}) added successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleDeleteStaff(StaffMember staff) {
    setState(() {
      _staffList.removeWhere((item) => item.id == staff.id);
    });
  }

  void _handleToggleStatus(StaffMember staff, StaffStatus newStatus) {
    setState(() {
      final index = _staffList.indexWhere((item) => item.id == staff.id);
      if (index != -1) {
        _staffList[index] = staff.copyWith(status: newStatus);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${staff.name} status changed to ${newStatus.label}.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openAddStaffDialog() {
    showDialog(
      context: context,
      builder: (context) => AddStaffDialog(onAdd: _handleAddStaff),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filteredList = _filteredStaff;

    // Metrics
    final totalStaff = _staffList.length;
    final managersCount = _staffList.where((s) =>
        s.role == StaffRole.manager || s.role == StaffRole.seniorManager).length;
    final activeCount = _staffList.where((s) => s.status == StaffStatus.active).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            AppRoute.shellScaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
        ),
        title: const Text('Staff & Managers'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddStaffDialog,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Staff'),
      ),
      body: Column(
        children: [
          // ===================================
          // SUMMARY METRICS CARDS
          // ===================================
          Container(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Staff',
                    value: '$totalStaff Member(s)',
                    icon: Icons.people_alt_rounded,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    title: 'Managers',
                    value: '$managersCount Manager(s)',
                    icon: Icons.manage_accounts_rounded,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    title: 'Active Status',
                    value: '$activeCount Active',
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // ===================================
          // SEARCH & ROLE FILTER
          // ===================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search manager name, email, phone or role...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Role Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('All Roles'),
                          selected: _selectedRoleFilter == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedRoleFilter = null;
                              });
                            }
                          },
                        ),
                      ),
                      ...StaffRole.values.map((role) {
                        final isSelected = _selectedRoleFilter == role;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar: Icon(role.icon, size: 16, color: isSelected ? Colors.white : role.color),
                            label: Text(role.label),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedRoleFilter = selected ? role : null;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // ===================================
          // STAFF LIST
          // ===================================
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.manage_accounts_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Managers / Staff Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search term or role filter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final staff = filteredList[index];
                      return StaffCard(
                        staff: staff,
                        onDelete: () => _handleDeleteStaff(staff),
                        onToggleStatus: (newStatus) => _handleToggleStatus(staff, newStatus),
                      );
                    },
                  ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
