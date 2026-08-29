import 'package:flutter/material.dart';
import '../../domain/entities/supplier_entity.dart';

class AddEditSupplierSheet extends StatefulWidget {
  final SupplierEntity? supplierToEdit;
  final Future<void> Function(SupplierEntity) onSave;

  const AddEditSupplierSheet({
    super.key,
    this.supplierToEdit,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    SupplierEntity? supplierToEdit,
    required Future<void> Function(SupplierEntity) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditSupplierSheet(
        supplierToEdit: supplierToEdit,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddEditSupplierSheet> createState() => _AddEditSupplierSheetState();
}

class _AddEditSupplierSheetState extends State<AddEditSupplierSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final s = widget.supplierToEdit;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _companyCtrl = TextEditingController(text: s?.companyName ?? '');
    _phoneCtrl = TextEditingController(text: s?.phone ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
    _addressCtrl = TextEditingController(text: s?.address ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final s = widget.supplierToEdit;
    final supplier = SupplierEntity(
      id: s?.id ?? 'sup_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      companyName: _companyCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      totalPurchases: s?.totalPurchases ?? 0.0,
      dueAmount: s?.dueAmount ?? 0.0,
      createdAt: s?.createdAt ?? DateTime.now(),
    );

    try {
      await widget.onSave(supplier);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.supplierToEdit != null;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
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
                            color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEditing ? Icons.edit_note_rounded : Icons.person_add_alt_1_rounded,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'মহাজনের তথ্য আপডেট' : 'নতুন মহাজন প্রোফাইল',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEditing ? 'সাপ্লায়ার তথ্য সংশোধন করুন' : 'নতুন পাইকারি মহাজন বা সাপ্লায়ার যুক্ত করুন',
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

                    // Supplier Name
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'মহাজনের নাম (Supplier Name) *',
                        hintText: 'e.g. মো: রফিকুল ইসলাম',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'মহাজনের নাম দেওয়া আবশ্যক';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Company Name
                    TextFormField(
                      controller: _companyCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'কোম্পানি / ব্যবসার নাম',
                        hintText: 'e.g. মেসার্স ইসলাম ট্রেডার্স',
                        prefixIcon: const Icon(Icons.business_outlined),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Mobile Number
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'মোবাইল নম্বর (Phone) *',
                        hintText: 'e.g. 01712345678',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'মোবাইল নম্বর দেওয়া আবশ্যক';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Email Address
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'ইমেইল (Email - ঐচ্ছিক)',
                        hintText: 'e.g. supplier@example.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Address
                    TextFormField(
                      controller: _addressCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'ঠিকানা (Address - ঐচ্ছিক)',
                        hintText: 'e.g. চকবাজার, ঢাকা',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Actions
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
                            child: const Text('বাতিল'),
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
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(isEditing ? 'আপডেট করুন' : 'সংরক্ষণ করুন'),
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
    );
  }
}
