import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../posbilling/presentation/widget/section_tile.dart';
import '../../domain/entities/return_item_entity.dart';
import '../bloc/returns_event.dart';
import '../bloc/returns_state.dart';
import '../../return_models.dart';
import '../widget/invoic_header.dart';
import '../widget/return_header.dart';
import '../widget/return_item_card.dart';
import '../widget/return_summary.dart';

class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  final TextEditingController searchController = TextEditingController();

  ReturnCustomer? selectedCustomer;
  CustomerInvoice? selectedInvoice;
  final Map<String, int> returnQuantities = {};

  final List<ReturnCustomer> customers = const [
    ReturnCustomer(id: 'c1', name: 'Rahim', phone: '01712345678'),
    ReturnCustomer(id: 'c2', name: 'Jahid', phone: '01812345678'),
  ];

  final List<CustomerInvoice> invoices = [
    CustomerInvoice(
      id: 'inv1',
      invoiceNumber: 'INV-1001',
      customerId: 'c1',
      date: DateTime(2026, 8, 10),
      items: const [
        InvoiceItem(
          productId: 'p1',
          productName: 'Rice 5KG',
          sku: 'RICE-005',
          price: 450,
          purchasedQuantity: 3,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch event to ReturnsBloc
    InjectionContainer.returnsBloc.add(const FetchReturnLogsEvent());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    InjectionContainer.returnsBloc.add(FetchReturnLogsEvent(query));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            AppRoute.shellScaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
        ),
        title: const Text('Returns & Restock'),
        actions: [
          IconButton(
            onPressed: () {
              InjectionContainer.returnsBloc.add(FetchReturnLogsEvent(searchController.text));
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: StreamBuilder<ReturnsState>(
        stream: InjectionContainer.returnsBloc.stream,
        initialData: InjectionContainer.returnsBloc.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is ReturnsLoadingState && state is! ReturnsLoadedState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReturnsErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_off_rounded,
                        color: colorScheme.error,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Something Went Wrong',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message.isNotEmpty
                          ? state.message
                          : 'Unable to load return logs. Cache expired or network connection failed.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        InjectionContainer.returnsBloc.add(FetchReturnLogsEvent(searchController.text));
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final loadedState = state is ReturnsLoadedState ? state : null;
          final returnLogs = loadedState?.filteredLogs ?? [];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            children: [
              // HEADER
              const ReturnHeader(),
              const SizedBox(height: 16),

              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by invoice number or item name',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // RETURN TRANSACTION LOGS
              const SectionTitle(title: 'Return Logs History'),
              const SizedBox(height: 10),

              if (returnLogs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No return logs found.', style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: returnLogs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = returnLogs[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.invoiceNo,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Refund: ৳${item.totalRefundAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Item: ${item.itemName} (Qty: ${item.returnQuantity})',
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (item.customerName != null && item.customerName!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Customer: ${item.customerName}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}