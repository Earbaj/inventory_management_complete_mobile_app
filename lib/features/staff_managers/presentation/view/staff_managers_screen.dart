import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_local.dart';
import '../../../../core/route/app_route.dart';
import '../../../../core/widgets/global_empty_placeholder.dart';
import '../../../../core/widgets/global_warning_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/staff_entity.dart';
import '../../staff_manager_model.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import '../widget/add_staff_dialog.dart';
import '../widget/manage_permissions_sheet.dart';
import '../widget/staff_card.dart';
import '../widget/staff_shimmer.dart';

class StaffManagersScreen extends StatefulWidget {
  const StaffManagersScreen({super.key});

  @override
  State<StaffManagersScreen> createState() => _StaffManagersScreenState();
}

class _StaffManagersScreenState extends State<StaffManagersScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  String? _deletingStaffId;

  @override
  void initState() {
    super.initState();
    context.read<StaffBloc>().add(const FetchStaffEvent());
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    if (query.isEmpty) {
      context.read<StaffBloc>().add(const FetchStaffEvent(''));
      return;
    }
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<StaffBloc>().add(FetchStaffEvent(query));
      }
    });
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

  void _confirmDeleteStaff(String staffId, String staffName) {
    GlobalWarningDialog.show(
      context,
      title: StaffStrings.deleteStaffConfirm.getString(context),
      message:
          '${StaffStrings.deleteStaffWarning.getString(context)}\n\n($staffName)',
      confirmText: Bangla.delete.getString(context),
      cancelText: Bangla.cancel.getString(context),
      icon: Icons.delete_forever_rounded,
      confirmColor: Colors.red,
      onConfirm: () async {
        setState(() => _deletingStaffId = staffId);
        final completer = Completer<void>();
        context.read<StaffBloc>().add(
              DeleteStaffEvent(staffId, completer: completer),
            );
        try {
          await completer.future;
        } finally {
          if (mounted) {
            setState(() => _deletingStaffId = null);
          }
        }
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
        title: Text(StaffStrings.staffTitle.getString(context)),
        actions: [
          IconButton(
            onPressed: () {
              context.read<StaffBloc>().add(FetchStaffEvent(_searchController.text));
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: Bangla.details.getString(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddStaffDialog,
        icon: const Icon(Icons.person_add_rounded),
        label: Text(StaffStrings.addStaff.getString(context)),
      ),
      body: BlocConsumer<StaffBloc, StaffState>(
        listenWhen: (previous, current) =>
        current is StaffOperationSuccessState || current is StaffErrorState,
        buildWhen: (previous, current) => current is! StaffOperationSuccessState,
        listener: (context, state) {
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
        },
        builder: (context, snapshot) {
          final state = snapshot;
          final bool isInitialLoading = state is StaffLoadingState && state is! StaffLoadedState;
          final bool isRefreshing = state is StaffLoadedState && state.isListLoading;

          if (isInitialLoading) {
            return const StaffShimmerView();
          }

          if (state is StaffErrorState && state.previousStaff.isEmpty) {
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
                        context.read<StaffBloc>().add(FetchStaffEvent(_searchController.text));
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

          final authState = context.watch<AuthBloc>().state;
          final String? currentUserId = authState is AuthenticatedState ? authState.user?.id : null;

          final List<StaffEntity> staffEntitiesSource = (state is StaffLoadedState)
              ? state.filteredStaff
              : (state is StaffErrorState ? state.previousStaff : []);

          // 1. Filter raw entities excluding the logged-in user and superadmin
          final List<StaffEntity> staffEntities = staffEntitiesSource
              .where((e) {
            if (currentUserId != null) {
              return e.id != currentUserId && e.role.toLowerCase() != 'superadmin';
            }
            return e.role.toLowerCase() != 'admin' && e.role.toLowerCase() != 'superadmin';
          })
              .toList();

          return Column(
            children: [
              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: StaffStrings.searchStaff.getString(context),
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // STAFF MEMBERS LIST
              Expanded(
                child: (isInitialLoading || isRefreshing)
                    ? const StaffShimmerView()
                    : RefreshIndicator(
                        onRefresh: () async {
                          context.read<StaffBloc>().add(FetchStaffEvent(_searchController.text));
                        },
                        child: staffEntities.isEmpty
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.6,
                                  child: GlobalEmptyPlaceholder(
                                    title: StaffStrings.noStaffFound.getString(context),
                                    subtitle: StaffStrings.addStaff.getString(context),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                                itemCount: staffEntities.length,
                                itemBuilder: (context, index) {
                                  final entity = staffEntities[index];
                                  final staff = StaffMember(
                                    id: entity.id,
                                    name: entity.name,
                                    email: entity.email,
                                    phone: entity.phone,
                                    role: switch (entity.role.toLowerCase()) {
                                      'admin' || 'senior_manager' => StaffRole.seniorManager,
                                      'manager' => StaffRole.manager,
                                      'staff' || 'inventory_staff' => StaffRole.inventoryStaff,
                                      _ => StaffRole.cashier,
                                    },
                                    status: entity.isActive ? StaffStatus.active : StaffStatus.inactive,
                                    joinedDate: entity.createdAt,
                                    assignedBranch: 'Main Branch',
                                    salesServedCount: 12,
                                  );

                                  return StaffCard(
                                    staff: staff,
                                    isDeleting: _deletingStaffId == entity.id,
                                    onToggleStatus: () {
                                      context.read<StaffBloc>().add(UpdateStaffEvent(
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
                                      _confirmDeleteStaff(entity.id, entity.name);
                                    },
                                  );
                                },
                              ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
