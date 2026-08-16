import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../customer.dart';

class AddCustomerSheet
    extends StatefulWidget {

  final Customer? existingCustomer;

  final ValueChanged<Customer>
  onSave;

  const AddCustomerSheet({
    this.existingCustomer,
    required this.onSave,
  });

  @override
  State<AddCustomerSheet> createState() =>
      _AddCustomerSheetState();
}

class _AddCustomerSheetState
    extends State<AddCustomerSheet> {

  final formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  nameController;

  late final TextEditingController
  phoneController;

  late final TextEditingController
  addressController;

  late final TextEditingController
  balanceController;

  @override
  void initState() {
    super.initState();

    final customer =
        widget.existingCustomer;

    nameController =
        TextEditingController(
          text: customer?.name ?? '',
        );

    phoneController =
        TextEditingController(
          text: customer?.phone ?? '',
        );

    addressController =
        TextEditingController(
          text: customer?.address ?? '',
        );

    balanceController =
        TextEditingController(
          text: customer?.openingBalance
              .toString() ??
              '',
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

    final theme =
    Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final editing =
        widget.existingCustomer !=
            null;

    return Container(

      height:
      MediaQuery.sizeOf(context)
          .height *
          0.78,

      decoration:
      BoxDecoration(

        color:
        colorScheme.surface,

        borderRadius:
        const BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),

      child: SafeArea(

        child: Column(
          children: [

            const SizedBox(
              height: 10,
            ),

            Container(
              width: 42,
              height: 4,

              decoration:
              BoxDecoration(
                color:
                theme.dividerColor,

                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // ======================
            // HEADER
            // ======================

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Row(
                children: [

                  Expanded(
                    child: Text(
                      editing
                          ? 'Edit Customer'
                          : 'Add Customer',

                      style:
                      const TextStyle(
                        fontSize: 21,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },

                    icon:
                    const Icon(
                      Icons.close_rounded,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Expanded(

              child: Form(
                key: formKey,

                child: ListView(
                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    20,
                  ),

                  children: [

                    // ==================
                    // NAME
                    // ==================

                    TextFormField(
                      controller:
                      nameController,

                      textInputAction:
                      TextInputAction.next,

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Customer Name',

                        hintText:
                        'e.g. Rahim Jahid',

                        prefixIcon:
                        Icon(
                          Icons
                              .person_outline,
                        ),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.trim().isEmpty) {

                          return
                            'Customer name is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ==================
                    // PHONE
                    // ==================

                    TextFormField(
                      controller:
                      phoneController,

                      keyboardType:
                      TextInputType.phone,

                      textInputAction:
                      TextInputAction.next,

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Phone Number',

                        hintText:
                        'e.g. 01712345678',

                        prefixIcon:
                        Icon(
                          Icons
                              .phone_outlined,
                        ),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.trim().isEmpty) {

                          return
                            'Phone number is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ==================
                    // ADDRESS
                    // ==================

                    TextFormField(
                      controller:
                      addressController,

                      maxLines: 3,

                      textInputAction:
                      TextInputAction.next,

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Address',

                        hintText:
                        'Customer address',

                        prefixIcon:
                        Padding(
                          padding:
                          EdgeInsets.only(
                            bottom: 35,
                          ),

                          child: Icon(
                            Icons
                                .location_on_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ==================
                    // OPENING BALANCE
                    // ==================

                    TextFormField(
                      controller:
                      balanceController,

                      keyboardType:
                      const TextInputType
                          .numberWithOptions(
                        decimal: true,
                      ),

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Opening Balance',

                        hintText:
                        'e.g. 2500',

                        prefixText:
                        '৳ ',

                        prefixIcon:
                        Icon(
                          Icons
                              .account_balance_wallet_outlined,
                        ),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.trim().isEmpty) {

                          return
                            'Opening balance is required';
                        }

                        final amount =
                        double.tryParse(
                          value,
                        );

                        if (amount == null) {
                          return
                            'Enter a valid amount';
                        }

                        if (amount < 0) {
                          return
                            'Amount cannot be negative';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================
                    // SAVE
                    // ==================

                    SizedBox(
                      height: 54,

                      child:
                      FilledButton.icon(

                        onPressed:
                        _saveCustomer,

                        icon: Icon(
                          editing
                              ? Icons
                              .save_outlined
                              : Icons
                              .person_add_alt_1_rounded,
                        ),

                        label: Text(
                          editing
                              ? 'Update Customer'
                              : 'Add Customer',

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w700,
                          ),
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
    );
  }

  void _saveCustomer() {

    if (!formKey.currentState!
        .validate()) {
      return;
    }

    final oldCustomer =
        widget.existingCustomer;

    final customer = Customer(

      id: oldCustomer?.id ??
          DateTime.now()
              .millisecondsSinceEpoch
              .toString(),

      name:
      nameController.text.trim(),

      phone:
      phoneController.text.trim(),

      address:
      addressController.text.trim(),

      openingBalance:
      double.parse(
        balanceController.text,
      ),
    );

    widget.onSave(customer);
  }
}