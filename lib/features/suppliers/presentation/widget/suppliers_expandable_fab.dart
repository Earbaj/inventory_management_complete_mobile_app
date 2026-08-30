import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_state.dart';

class SuppliersExpandableFab extends StatelessWidget {
  final Animation<double> expandAnimation;
  final bool isFabOpen;
  final VoidCallback onToggle;
  final VoidCallback onAddSupplier;
  final VoidCallback onNewPurchaseOrder;

  const SuppliersExpandableFab({
    super.key,
    required this.expandAnimation,
    required this.isFabOpen,
    required this.onToggle,
    required this.onAddSupplier,
    required this.onNewPurchaseOrder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<SupplierBloc, SupplierState>(
      builder: (context, state) {
        final hasSuppliers = state is SupplierLoadedState && state.suppliers.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Button 1: Buy Items / Purchase Order
            ScaleTransition(
              scale: expandAnimation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black87,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Buy Items',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    heroTag: 'fab_purchase',
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      onToggle();
                      if (hasSuppliers) {
                        onNewPurchaseOrder();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please create a supplier first!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.add_shopping_cart_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Button 2: Add Supplier Profile
            ScaleTransition(
              scale: expandAnimation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black87,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'New Supplier',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    heroTag: 'fab_supplier',
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      onToggle();
                      onAddSupplier();
                    },
                    child: const Icon(Icons.person_add_alt_1_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Main Trigger FAB
            FloatingActionButton(
              heroTag: 'fab_main_toggle',
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: onToggle,
              child: AnimatedRotation(
                turns: isFabOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            ),
          ],
        );
      },
    );
  }
}
