import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/global_empty_placeholder.dart';
import '../../domain/entities/supplier_entity.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';
import 'supplier_item_card.dart';
import 'suppliers_shimmer.dart';

class SuppliersListTabView extends StatelessWidget {
  final SupplierState state;
  final bool isInitialLoading;
  final bool isRefreshing;
  final Function(SupplierEntity supplier) onSupplierTap;
  final Function(SupplierEntity supplier) onSupplierEdit;
  final Function(SupplierEntity supplier) onSupplierDelete;

  const SuppliersListTabView({
    super.key,
    required this.state,
    required this.isInitialLoading,
    required this.isRefreshing,
    required this.onSupplierTap,
    required this.onSupplierEdit,
    required this.onSupplierDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isInitialLoading || isRefreshing) {
      return const SuppliersShimmerView();
    }

    if (state is SupplierErrorState && (state as SupplierErrorState).previousSuppliers.isEmpty) {
      final errorState = state as SupplierErrorState;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, color: Colors.red.shade400, size: 48),
              const SizedBox(height: 16),
              Text(
                errorState.message,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  context.read<SupplierBloc>().add(const LoadSuppliersEvent(forceRefresh: true));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final List<SupplierEntity> suppliers = state is SupplierLoadedState
        ? (state as SupplierLoadedState).suppliers
        : (state is SupplierErrorState ? (state as SupplierErrorState).previousSuppliers : []);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SupplierBloc>().add(const LoadSuppliersEvent(forceRefresh: true));
      },
      child: suppliers.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: const GlobalEmptyPlaceholder(
                    title: 'NO Suppliers Found',
                    subtitle: 'Add Suppliers To Start Your Business.',
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];
                return SupplierItemCard(
                  supplier: supplier,
                  onTap: () => onSupplierTap(supplier),
                  onEdit: () => onSupplierEdit(supplier),
                  onDelete: () => onSupplierDelete(supplier),
                );
              },
            ),
    );
  }
}
