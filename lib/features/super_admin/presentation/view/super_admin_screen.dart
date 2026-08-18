import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  @override
  void initState() {
    super.initState();
    InjectionContainer.superAdminBloc.add(const FetchPendingPaymentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Portal 👑', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              InjectionContainer.superAdminBloc.add(const FetchPendingPaymentsEvent());
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: StreamBuilder<SuperAdminState>(
        stream: InjectionContainer.superAdminBloc.stream,
        initialData: InjectionContainer.superAdminBloc.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is SuperAdminLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SuperAdminLoadedState) {
            final payments = state.payments;

            if (payments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_rounded, size: 64, color: colorScheme.primary),
                    const SizedBox(height: 12),
                    const Text('No Pending Payment Submissions!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('All shop subscriptions are up-to-date.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(payment.method.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              backgroundColor: colorScheme.primaryContainer,
                            ),
                            Text(
                              '৳ ${payment.amount.toStringAsFixed(0)}',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('TrxID: ${payment.transactionId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('Shop ID: ${payment.shopId} | Target Tier: ${payment.targetTier.toUpperCase()}'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                InjectionContainer.superAdminBloc.add(RejectPaymentEvent(payment.id));
                              },
                              icon: const Icon(Icons.close_rounded, color: Colors.red),
                              label: const Text('Reject', style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                InjectionContainer.superAdminBloc.add(ApprovePaymentEvent(payment.id));
                              },
                              icon: const Icon(Icons.check_circle_rounded),
                              label: const Text('Approve Upgrade', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
