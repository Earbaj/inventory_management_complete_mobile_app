import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
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
  final _branchController = TextEditingController(text: 'Main Branch');

  StaffRole _selectedRole = StaffRole.manager;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
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
        isActive: true,
        createdAt: DateTime.now(),
      );

      InjectionContainer.staffBloc.add(AddStaffEvent(newStaffEntity));

      if (widget.onAdd != null) {
        widget.onAdd!(
          StaffMember(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            role: _selectedRole,
            status: StaffStatus.active,
            joinedDate: DateTime.now(),
            assignedBranch: _branchController.text.trim().isEmpty
                ? 'Main Branch'
                : _branchController.text.trim(),
            salesServedCount: 0,
          ),
        );
      }

      Navigator.pop(context, true);
    }
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
                      onPressed: () => Navigator.pop(context),
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

                      // Branch / Department
                      TextFormField(
                        controller: _branchController,
                        decoration: const InputDecoration(
                          labelText: 'Assigned Branch / Dept',
                          hintText: 'e.g. Main Outlet',
                          prefixIcon: Icon(Icons.store_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _submitForm,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Save Staff'),
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
