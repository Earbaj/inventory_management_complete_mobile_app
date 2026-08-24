import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../branches/domain/entities/branch_entity.dart';
import '../../domain/entities/staff_entity.dart';
import '../../staff_manager_model.dart';
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
  bool _isLoadingBranches = false;
  List<BranchEntity> _branches = [];
  String? _selectedBranchId;
  String? _selectedBranchName;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoadingBranches = true;
    });
    try {
      final list = await InjectionContainer.getBranchesUseCase();
      if (mounted) {
        setState(() {
          _branches = list;
          if (list.isNotEmpty) {
            _selectedBranchId = list.first.id;
            _selectedBranchName = list.first.name;
          }
          _isLoadingBranches = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingBranches = false;
        });
      }
    }
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

    try {
      final savedStaff = await InjectionContainer.addStaffMemberUseCase(newStaffEntity);
      InjectionContainer.staffBloc.add(AddStaffEvent(savedStaff));

      if (widget.onAdd != null) {
        widget.onAdd!(
          StaffMember(
            id: savedStaff.id,
            name: savedStaff.name,
            email: savedStaff.email,
            phone: savedStaff.phone,
            role: _selectedRole,
            status: StaffStatus.active,
            joinedDate: savedStaff.createdAt,
            assignedBranch: _selectedBranchName ?? 'Main Branch',
            salesServedCount: 0,
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSaving = false;
        });

        final rawMsg = e is Failure ? e.message : e.toString();
        final cleanMsg = rawMsg
            .replaceAll('Exception: ', '')
            .replaceAll('ServerFailure: ', '')
            .replaceAll('NetworkFailure: ', '');

        final isFreeTierLimit = cleanMsg.toLowerCase().contains('free tier') ||
            cleanMsg.toLowerCase().contains('limited to 1') ||
            cleanMsg.toLowerCase().contains('upgrade');

        if (isFreeTierLimit) {
          _showFreeTierLimitDialog(context, cleanMsg);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Text(cleanMsg)),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

    return Dialog(
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
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Account Password *',
                          hintText: 'Minimum 6 characters',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
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
                        value: _selectedRole,
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
                        onChanged: (role) {
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
                          value: _selectedBranchId,
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
                          onChanged: (branchId) {
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
                          FilledButton.icon(
                            onPressed: isSaving ? null : _submitForm,
                            icon: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.check_rounded),
                            label: Text(isSaving ? 'Saving...' : 'Save Staff'),
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
    );
  }
}
