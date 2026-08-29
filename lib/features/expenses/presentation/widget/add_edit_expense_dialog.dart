import 'package:flutter/material.dart';
import '../../domain/entities/expense_entity.dart';

class AddEditExpenseDialog extends StatefulWidget {
  final ExpenseEntity? expenseToEdit;
  final Function(ExpenseEntity) onSave;

  const AddEditExpenseDialog({
    super.key,
    this.expenseToEdit,
    required this.onSave,
  });

  @override
  State<AddEditExpenseDialog> createState() => _AddEditExpenseDialogState();
}

class _AddEditExpenseDialogState extends State<AddEditExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = 'utility';
  DateTime _selectedDate = DateTime.now();
  bool isSaving = false;

  final List<Map<String, String>> _categories = const [
    {'key': 'utility', 'label': 'Utility (Electricity/Water/Net)'},
    {'key': 'rent', 'label': 'Shop Rent'},
    {'key': 'salary', 'label': 'Staff Salary'},
    {'key': 'transport', 'label': 'Transport & Courier'},
    {'key': 'misc', 'label': 'Miscellaneous'},
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
    if (!_formKey.currentState!.validate()) return;

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

    final dateStr = '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Expense Record' : 'Record New Shop Expense',
                        style: const TextStyle(
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
                      // Category
                      DropdownButtonFormField<String>(
                        initialValue: _categories.any((c) => c['key'] == _selectedCategory) ? _selectedCategory : 'misc',
                        decoration: const InputDecoration(
                          labelText: 'Expense Category *',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _categories.map((c) {
                          return DropdownMenuItem<String>(
                            value: c['key'],
                            child: Text(c['label']!),
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

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title / Description *',
                          hintText: 'e.g. Shop Electricity Bill August',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter expense title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Amount
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Amount (৳) *',
                          hintText: 'e.g. 1500.00',
                          prefixIcon: Icon(Icons.attach_money_rounded),
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
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expense Date *',
                            prefixIcon: Icon(Icons.calendar_today_rounded),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w600)),
                              const Icon(Icons.edit_calendar_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Note
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Note / Payment Details (Optional)',
                          hintText: 'e.g. Paid via bKash Merchant',
                          prefixIcon: Icon(Icons.note_alt_outlined),
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
                            onPressed: _submit,
                            icon: const Icon(Icons.check_rounded),
                            label: Text(isEditing ? 'Update Expense' : 'Save Expense'),
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
