import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../branches/domain/entities/branch_entity.dart';
import '../../../branches/presentation/bloc/branch_bloc.dart';
import '../../../branches/presentation/bloc/branch_event.dart';
import '../../domain/entities/staff_entity.dart';
import '../../staff_manager_model.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';

class AddStaffDialog extends StatefulWidget {
  final Function(StaffMember)? onAdd;

  const AddStaffDialog({
    super.key,
    this.onAdd,
  });

  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  StaffRole _selectedRole = StaffRole.manager;
  bool _obscurePassword = true;
  bool isSaving = false;

  List<BranchEntity> _branches = [];
  String? _selectedBranchId;
  String? _selectedBranchName;
  bool _isLoadingBranches = false;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  void _loadBranches() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final branchBloc = context.read<BranchBloc>();
        final list = branchBloc.branches;
        if (list.isNotEmpty) {
          setState(() {
            _branches = list;
            _selectedBranchId = list.first.id;
            _selectedBranchName = list.first.name;
            _isLoadingBranches = false;
          });
        } else {
          branchBloc.add(const FetchBranchesEvent());
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (isSaving) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final roleStr = switch (_selectedRole) {
      StaffRole.seniorManager => 'admin',
      StaffRole.manager => 'manager',
      StaffRole.cashier => 'cashier',
      StaffRole.inventoryStaff => 'staff',
    };

    final newStaffEntity = StaffEntity(
      id: '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      role: roleStr,
      branchId: _selectedBranchId,
      isActive: true,
      createdAt: DateTime.now(),
    );

    final completer = Completer<void>();
    context.read<StaffBloc>().add(AddStaffEvent(newStaffEntity, completer: completer));

    try {
      await completer.future;
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
        final errorMsg = e.toString();
        if (errorMsg.toLowerCase().contains('limit') ||
            errorMsg.toLowerCase().contains('upgrade') ||
            errorMsg.toLowerCase().contains('plan')) {
          _showFreeTierLimitDialog(context, errorMsg);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg.replaceAll('Exception: ', '')),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showFreeTierLimitDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Manager Limit Reached',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.star_rounded, color: Colors.amber),
              label: const Text('Upgrade Plan'),
              onPressed: () {
                Navigator.pop(dialogContext);
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

    return PopScope(
      canPop: !isSaving,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_add_rounded, color: Colors.white, size: 26),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Add Manager / Staff',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: isSaving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        enabled: !isSaving,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          hintText: 'e.g. John Doe',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter staff name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        enabled: !isSaving,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address *',
                          hintText: 'e.g. manager@store.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter email address';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        enabled: !isSaving,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Account Password *',
                          hintText: 'Minimum 6 characters',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                            onPressed: isSaving
                                ? null
                                : () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter password';
                          }
                          if (value.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        enabled: !isSaving,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          hintText: 'e.g. 01700000000',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Role Dropdown
                      DropdownButtonFormField<StaffRole>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role *',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        items: StaffRole.values.map((role) {
                          return DropdownMenuItem<StaffRole>(
                            value: role,
                            child: Row(
                              children: [
                                Icon(role.icon, size: 20, color: role.color),
                                const SizedBox(width: 8),
                                Text(role.label),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: isSaving
                            ? null
                            : (role) {
                                if (role != null) {
                                  setState(() {
                                    _selectedRole = role;
                                  });
                                }
                              },
                      ),
                      const SizedBox(height: 14),

                      // Select Branch Dropdown
                      if (_isLoadingBranches)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: LinearProgressIndicator(),
                        )
                      else if (_branches.isNotEmpty)
                        DropdownButtonFormField<String>(
                          initialValue: _selectedBranchId,
                          decoration: const InputDecoration(
                            labelText: 'Select Branch *',
                            prefixIcon: Icon(Icons.store_outlined),
                          ),
                          items: _branches.map((branch) {
                            return DropdownMenuItem<String>(
                              value: branch.id,
                              child: Text(branch.name),
                            );
                          }).toList(),
                          onChanged: isSaving
                              ? null
                              : (branchId) {
                                  if (branchId != null) {
                                    setState(() {
                                      _selectedBranchId = branchId;
                                      final b = _branches.firstWhere((element) => element.id == branchId);
                                      _selectedBranchName = b.name;
                                    });
                                  }
                                },
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'No branches created yet. (Main Branch will be assigned)',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: isSaving ? null : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: isSaving ? null : _submitForm,
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.75),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSaving
                                ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Saving Staff...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_rounded, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Save Staff',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
