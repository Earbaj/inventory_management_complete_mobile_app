import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../domain/entities/staff_entity.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import '../../staff_manager_model.dart';
import '../widget/add_staff_dialog.dart';
import '../widget/manage_permissions_sheet.dart';
import '../widget/staff_card.dart';

class StaffManagersScreen extends StatefulWidget {
  const StaffManagersScreen({super.key});

  @override
  State<StaffManagersScreen> createState() => _StaffManagersScreenState();
}

class _StaffManagersScreenState extends State<StaffManagersScreen> {
  final TextEditingController _searchController = TextEditingController();
  StaffRole? _selectedRoleFilter;
  StreamSubscription<StaffState>? _staffSubscription;

  @override
  void initState() {
    super.initState();
    _staffSubscription = InjectionContainer.staffBloc.stream.listen((state) {
      if (!mounted) return;
      if (state is StaffOperationSuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (state is StaffErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // Dispatch initial fetch to StaffBloc
    InjectionContainer.staffBloc.add(const FetchStaffEvent());
  }

  @override
  void dispose() {
    _staffSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    InjectionContainer.staffBloc.add(FetchStaffEvent(query));
  }

  void _openAddStaffDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const AddStaffDialog(),
    );
  }

  void _openManagePermissions(BuildContext context, StaffEntity staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ManagePermissionsSheet(staff: staff),
    );
  }

  void _confirmDeleteStaff(BuildContext context, String staffId, String staffName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Delete Staff Member?'),
            ],
          ),
          content: Text(
            'Are you sure you want to remove "$staffName" from your shop staff list?\n\nThis action will delete their account permanently.',
          ),
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
              label: const Text('Delete'),
              onPressed: () {
                Navigator.pop(dialogContext);
                InjectionContainer.staffBloc.add(DeleteStaffEvent(staffId));
              },
            ),
          ],
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
        label: const Text('Add Manager'),
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
          // Filter out Admin/SuperAdmin accounts so only Managers appear
          final staffEntities = (loadedState?.filteredStaff ?? [])
              .where((e) => e.role.toLowerCase() != 'admin' && e.role.toLowerCase() != 'superadmin')
              .toList();

          final List<StaffMember> staffList = staffEntities.map((e) {
            return StaffMember(
              id: e.id,
              name: e.name,
              email: e.email,
              phone: e.phone,
              role: switch (e.role.toLowerCase()) {
                'admin' || 'senior_manager' => StaffRole.seniorManager,
                'manager' => StaffRole.manager,
                'staff' || 'inventory_staff' => StaffRole.inventoryStaff,
                _ => StaffRole.cashier,
              },
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
                    hintText: 'Search manager by name, phone or email',
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
                      label: const Text('All Managers'),
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
                        child: Text('No managers found.', style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: staffList.length,
                        itemBuilder: (context, index) {
                          final staff = staffList[index];
                          final entity = staffEntities[index];
                          return StaffCard(
                            staff: staff,
                            onToggleStatus: () {
                              InjectionContainer.staffBloc.add(UpdateStaffEvent(
                                entity.copyWith(isActive: !entity.isActive),
                              ));
                            },
                            onManagePermissions: () {
                              _openManagePermissions(context, entity);
                            },
                            onEdit: () {
                              _openManagePermissions(context, entity);
                            },
                            onDelete: () {
                              _confirmDeleteStaff(context, entity.id, entity.name);
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
