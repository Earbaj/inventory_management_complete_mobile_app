import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';
import '../../domain/entities/expense_entity.dart';

class AddEditExpenseSheet extends StatefulWidget {
  final ExpenseEntity? expenseToEdit;
  final Function(ExpenseEntity) onSave;

  const AddEditExpenseSheet({
    super.key,
    this.expenseToEdit,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    ExpenseEntity? expenseToEdit,
    required Function(ExpenseEntity) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditExpenseSheet(
        expenseToEdit: expenseToEdit,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddEditExpenseSheet> createState() => _AddEditExpenseSheetState();
}

class _AddEditExpenseSheetState extends State<AddEditExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = 'utility';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = const [
    {'key': 'utility', 'label': 'Utility (Electricity/Water/Net)', 'icon': Icons.bolt_rounded},
    {'key': 'rent', 'label': 'Shop Rent', 'icon': Icons.storefront_rounded},
    {'key': 'salary', 'label': 'Staff Salary', 'icon': Icons.badge_outlined},
    {'key': 'transport', 'label': 'Transport & Courier', 'icon': Icons.local_shipping_outlined},
    {'key': 'misc', 'label': 'Miscellaneous', 'icon': Icons.receipt_long_outlined},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final e = widget.expenseToEdit!;
      _selectedCategory = e.category.toLowerCase();
      _titleController.text = e.title;
      _amountController.text = e.amount.toStringAsFixed(2);
      _noteController.text = e.note ?? '';
      _selectedDate = e.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final expense = ExpenseEntity(
      id: widget.expenseToEdit?.id ?? '',
      category: _selectedCategory,
      title: _titleController.text.trim(),
      amount: amount,
      date: _selectedDate,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
    );

    widget.onSave(expense);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.expenseToEdit != null;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final dateStr = '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

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
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.receipt_long_rounded, color: Colors.red.shade700, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'Edit Expense Record' : 'Record New Expense',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEditing ? 'Modify recorded expense details' : 'Log shop costs & operating expenses',
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

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _categories.any((c) => c['key'] == _selectedCategory)
                          ? _selectedCategory
                          : 'misc',
                      decoration: InputDecoration(
                        labelText: 'Expense Category *',
                        prefixIcon: const Icon(Icons.category_outlined),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _categories.map((c) {
                        return DropdownMenuItem<String>(
                          value: c['key'] as String,
                          child: Row(
                            children: [
                              Icon(c['icon'] as IconData, size: 18, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(c['label'] as String, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Title / Description
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Title / Description *',
                        hintText: 'e.g. Shop Electricity Bill August',
                        prefixIcon: const Icon(Icons.description_outlined),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter expense title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Amount Field
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount (${MoneyUtil.currencySymbol}) *',
                        hintText: 'e.g. 1500.00',
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter expense amount';
                        }
                        final parsed = double.tryParse(value.trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid positive amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Date Picker
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Expense Date',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.edit_calendar_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Note / Payment Details
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Note / Payment Details (Optional)',
                        hintText: 'e.g. Paid via bKash Merchant',
                        prefixIcon: const Icon(Icons.note_alt_outlined),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Actions: Cancel & Submit
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
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
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
                                : Text(isEditing ? 'Update Expense' : 'Save Expense'),
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
