import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../customer.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

class AddCustomerSheet extends StatefulWidget {
  final Customer? existingCustomer;
  final ValueChanged<Customer>? onSave;

  const AddCustomerSheet({
    super.key,
    this.existingCustomer,
    this.onSave,
  });

  @override
  State<AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<AddCustomerSheet> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController balanceController;

  @override
  void initState() {
    super.initState();

    final customer = widget.existingCustomer;

    nameController = TextEditingController(text: customer?.name ?? '');
    phoneController = TextEditingController(text: customer?.phone ?? '');
    addressController = TextEditingController(text: customer?.address ?? '');
    balanceController = TextEditingController(
      text: customer?.openingBalance.toString() ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    balanceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final editing = widget.existingCustomer != null;

    return BlocConsumer<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomerOperationSuccessState) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is CustomerActionLoadingState;

        return PopScope(
          canPop: !isLoading,
          child: Container(
            height: MediaQuery.sizeOf(context).height * 0.78,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ======================
                  // HEADER
                  // ======================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            editing ? 'Edit Customer' : 'Add Customer',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  Expanded(
                    child: Form(
                      key: formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        children: [
                          // ==================
                          // NAME
                          // ==================
                          TextFormField(
                            controller: nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Customer Name',
                              hintText: 'e.g. Rahim Jahid',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Customer name is required';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // ==================
                          // PHONE
                          // ==================
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              hintText: 'e.g. 01712345678',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // ==================
                          // ADDRESS
                          // ==================
                          TextFormField(
                            controller: addressController,
                            maxLines: 3,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              hintText: 'Customer address',
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(bottom: 35),
                                child: Icon(Icons.location_on_outlined),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ==================
                          // OPENING BALANCE
                          // ==================
                          TextFormField(
                            controller: balanceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Opening Balance',
                              hintText: 'e.g. 2500',
                              prefixText: '${MoneyUtil.currencySymbol} ',
                              prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Opening balance is required';
                              }

                              final amount = double.tryParse(value);

                              if (amount == null) {
                                return 'Enter a valid amount';
                              }

                              if (amount < 0) {
                                return 'Amount cannot be negative';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 25),

                          // ==================
                          // SAVE BUTTON WITH LOADER
                          // ==================
                          SizedBox(
                            height: 54,
                            child: FilledButton(
                              onPressed: isLoading ? null : _saveCustomer,
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isLoading
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          editing ? 'Updating Customer...' : 'Adding Customer...',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          editing
                                              ? Icons.save_outlined
                                              : Icons.person_add_alt_1_rounded,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          editing ? 'Update Customer' : 'Add Customer',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveCustomer() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final oldCustomer = widget.existingCustomer;

    final customer = Customer(
      id: oldCustomer?.id ?? '',
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      openingBalance: double.tryParse(balanceController.text) ?? 0.0,
    );

    if (widget.onSave != null) {
      widget.onSave!(customer);
    } else {
      if (oldCustomer == null) {
        context.read<CustomerBloc>().add(AddCustomerEvent(customer));
      } else {
        context.read<CustomerBloc>().add(UpdateCustomerEvent(customer));
      }
    }
  }
}
