import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
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

  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch to StaffBloc
    InjectionContainer.staffBloc.add(const FetchStaffEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    InjectionContainer.staffBloc.add(FetchStaffEvent(query));
  }

  void _openAddStaffDialog() async {
    final result = await showDialog<StaffMember>(
      context: context,
      builder: (context) => const AddStaffDialog(),
    );

    if (result != null) {
      InjectionContainer.staffBloc.add(FetchStaffEvent(_searchController.text));
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
        title: const Text('Staff & Managers'),
        actions: [
          IconButton(
            onPressed: () {
              InjectionContainer.staffBloc.add(FetchStaffEvent(_searchController.text));
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddStaffDialog,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Staff'),
      ),
      body: StreamBuilder<StaffState>(
        stream: InjectionContainer.staffBloc.stream,
        initialData: InjectionContainer.staffBloc.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is StaffLoadingState && state is! StaffLoadedState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StaffErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_off_rounded,
                        color: colorScheme.error,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Something Went Wrong',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message.isNotEmpty
                          ? state.message
                          : 'Unable to load staff list. Cache expired or network connection failed.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        InjectionContainer.staffBloc.add(FetchStaffEvent(_searchController.text));
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final loadedState = state is StaffLoadedState ? state : null;
          final staffEntities = loadedState?.filteredStaff ?? [];

          final List<StaffMember> staffList = staffEntities.map((e) {
            return StaffMember(
              id: e.id,
              name: e.name,
              email: e.email,
              phone: e.phone,
              role: e.role.toLowerCase() == 'admin'
                  ? StaffRole.seniorManager
                  : (e.role.toLowerCase() == 'manager' ? StaffRole.manager : StaffRole.cashier),
              status: e.isActive ? StaffStatus.active : StaffStatus.inactive,
              joinedDate: e.createdAt,
              assignedBranch: 'Main Branch',
              salesServedCount: 12,
            );
          }).toList();

          return Column(
            children: [
              // SEARCH & FILTER HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search staff by name, phone or role',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // ROLE FILTER CHIPS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Roles'),
                      selected: _selectedRoleFilter == null,
                      onSelected: (_) {
                        setState(() => _selectedRoleFilter = null);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...StaffRole.values.map((role) {
                      final isSelected = _selectedRoleFilter == role;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(role.label),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedRoleFilter = isSelected ? null : role);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // STAFF MEMBERS LIST
              Expanded(
                child: staffList.isEmpty
                    ? const Center(
                        child: Text('No staff members found.', style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: staffList.length,
                        itemBuilder: (context, index) {
                          final staff = staffList[index];
                          return StaffCard(
                            staff: staff,
                            onToggleStatus: () {
                              // Toggle Active/Inactive Status in StaffBloc
                              InjectionContainer.staffBloc.add(UpdateStaffEvent(
                                staffEntities[index].copyWith(isActive: !staffEntities[index].isActive),
                              ));
                            },
                            onEdit: () {
                              // Edit staff dialog
                            },
                            onDelete: () {
                              InjectionContainer.staffBloc.add(DeleteStaffEvent(staff.id));
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
