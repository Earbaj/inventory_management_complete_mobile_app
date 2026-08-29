import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/branch_bloc.dart';
import '../bloc/branch_event.dart';
import '../bloc/branch_state.dart';

class AddBranchSheet extends StatefulWidget {
  const AddBranchSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddBranchSheet(),
    );
  }

  @override
  State<AddBranchSheet> createState() => _AddBranchSheetState();
}

class _AddBranchSheetState extends State<AddBranchSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    context.read<BranchBloc>().add(
      CreateBranchEvent(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<BranchBloc, BranchState>(
      listener: (context, state) {
        if (state is BranchOperationSuccessState) {
          setState(() => _isSubmitting = false);
          Navigator.pop(context);
        } else if (state is BranchErrorState) {
          setState(() => _isSubmitting = false);
        }
      },
      child: PopScope(
        canPop: !_isSubmitting,
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Drag Handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.storefront_rounded, color: colorScheme.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create New Branch',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Add a new store branch location',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 18),

                      // Branch Name Field
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Branch Name *',
                          hintText: 'e.g. Mirpur Branch',
                          prefixIcon: const Icon(Icons.store_outlined),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter branch name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Address Field
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address *',
                          hintText: 'e.g. Mirpur-10, Dhaka',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter branch address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Phone Field
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number *',
                          hintText: 'e.g. 01711000001',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),

                      // Actions: Cancel & Save Branch
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: _isSubmitting ? null : _submitForm,
                              child: _isSubmitting
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : const Text('Save Branch'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
