import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/localization_local.dart';
import '../../data/models/staff_model.dart';
import '../../domain/entities/staff_entity.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';

class ManagePermissionsSheet extends StatefulWidget {
  final StaffEntity staff;

  const ManagePermissionsSheet({
    super.key,
    required this.staff,
  });

  @override
  State<ManagePermissionsSheet> createState() => _ManagePermissionsSheetState();
}

class _ManagePermissionsSheetState extends State<ManagePermissionsSheet> {
  late bool canViewBuyPrice;
  late bool canEditCustomers;
  late bool canProcessReturn;
  late bool canExportExcel;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    canViewBuyPrice = widget.staff.permissions.canViewBuyPrice;
    canEditCustomers = widget.staff.permissions.canEditCustomers;
    canProcessReturn = widget.staff.permissions.canProcessReturn;
    canExportExcel = widget.staff.permissions.canExportExcel;
  }

  Future<void> _savePermissions() async {
    if (isSaving) return;
    setState(() {
      isSaving = true;
    });

    final updatedPermissions = StaffPermissions(
      canViewBuyPrice: canViewBuyPrice,
      canEditCustomers: canEditCustomers,
      canProcessReturn: canProcessReturn,
      canExportExcel: canExportExcel,
    );

    final updatedStaff = widget.staff.copyWith(
      permissions: updatedPermissions,
    );

    final completer = Completer<void>();
    context.read<StaffBloc>().add(UpdateStaffEvent(updatedStaff, completer: completer));

    try {
      await completer.future;
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StaffStrings.permissionsSaved.getString(context)),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return PopScope(
      canPop: !isSaving,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.admin_panel_settings_rounded, color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StaffStrings.managePermissions.getString(context),
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${StaffStrings.manager.getString(context)}: ${widget.staff.name}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            SwitchListTile(
              secondary: const Icon(Icons.sell_outlined),
              title: const Text('View Purchase / Cost Price', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Allow manager to see product buy price and profit margin'),
              value: canViewBuyPrice,
              onChanged: (val) => setState(() => canViewBuyPrice = val),
            ),

            SwitchListTile(
              secondary: const Icon(Icons.people_outline_rounded),
              title: const Text('Edit Customer Profiles', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Allow manager to modify customer names and contacts'),
              value: canEditCustomers,
              onChanged: (val) => setState(() => canEditCustomers = val),
            ),

            SwitchListTile(
              secondary: const Icon(Icons.assignment_return_outlined),
              title: const Text('Process Returns & Refunds', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Allow manager to approve product return requests'),
              value: canProcessReturn,
              onChanged: (val) => setState(() => canProcessReturn = val),
            ),

            SwitchListTile(
              secondary: const Icon(Icons.table_chart_outlined),
              title: const Text('Export Excel Reports', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Allow manager to download inventory & sales spreadsheets'),
              value: canExportExcel,
              onChanged: (val) => setState(() => canExportExcel = val),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: isSaving ? null : _savePermissions,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  disabledBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Updating Permissions...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_rounded),
                          const SizedBox(width: 8),
                          Text(
                            Bangla.save.getString(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
