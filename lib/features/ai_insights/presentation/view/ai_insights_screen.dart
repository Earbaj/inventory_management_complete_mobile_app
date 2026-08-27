import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/route/app_route.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../bloc/ai_insights_bloc.dart';
import '../bloc/ai_insights_event.dart';
import '../bloc/ai_insights_state.dart';
import '../widget/business_advisor_card.dart';
import '../widget/customer_credit_score_dialog.dart';
import '../widget/demand_forecast_card.dart';

class AiInsightsScreen extends StatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen> {
  CustomerEntity? _selectedCustomerForScore;

  @override
  void initState() {
    super.initState();
    context.read<AiInsightsBloc>().add(const FetchAllAiInsightsEvent());
  }

  void _onCustomerScoreRequested(CustomerEntity? customer) {
    if (customer == null) return;
    setState(() {
      _selectedCustomerForScore = customer;
    });

    context.read<AiInsightsBloc>().add(FetchCustomerCreditScoreEvent(customer.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Fetch customer list for AI credit score lookup
    final custSnapshot = context.watch<CustomerBloc>().state;
    final List<CustomerEntity> customerList = custSnapshot is CustomerLoadedState ? custSnapshot.customers : [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            AppRoute.shellScaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
        ),
        title: Text('AI Insights & Predictions',maxLines: 1,overflow: TextOverflow.ellipsis,),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AiInsightsBloc>().add(const FetchAllAiInsightsEvent());
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Re-run AI Analysis',
          ),
        ],
      ),
      body: BlocConsumer<AiInsightsBloc, AiInsightsState>(
        listener: (context, state) {
          if (state is AiInsightsLoadedState && state.customerCreditScore != null && !state.isCustomerScoreLoading) {
            // Show Credit Score Modal Dialog
            showDialog(
              context: context,
              builder: (_) => CustomerCreditScoreDialog(creditScore: state.customerCreditScore!),
            );
          } else if (state is AiInsightsErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AiInsightsLoadingState) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.purple),
                  SizedBox(height: 16),
                  Text(
                    'Gemini 2.5 Flash AI is analyzing shop sales & customer records...',
                    style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final loadedState = state is AiInsightsLoadedState ? state : null;
          final demandForecast = loadedState?.demandForecast;
          final businessAdvisor = loadedState?.businessAdvisor;
          final isScoreLoading = loadedState?.isCustomerScoreLoading ?? false;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AiInsightsBloc>().add(const FetchAllAiInsightsEvent());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // GEMINI AI BANNER HEADER
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Gemini 2.5 Flash AI',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Smart demand forecasting, customer credit risk assessment & growth advisor.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                // AI CUSTOMER CREDIT SCORE LOOKUP SECTION
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 1.5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.credit_score_rounded, color: Colors.purple, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Check Customer AI Credit Score',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Evaluates customer reliability rating (1-100), risk level & recommended due limit.',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<CustomerEntity?>(
                                value: _selectedCustomerForScore,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  hintText: 'Select Customer',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                items: customerList.map((c) {
                                  return DropdownMenuItem<CustomerEntity?>(
                                    value: c,
                                    child: Text(
                                      '${c.name} (${c.phone})',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedCustomerForScore = val),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.purple,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              ),
                              onPressed: isScoreLoading || _selectedCustomerForScore == null
                                  ? null
                                  : () => _onCustomerScoreRequested(_selectedCustomerForScore),
                              icon: isScoreLoading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.auto_awesome_rounded, size: 18),
                              label: const Text('Assess Score'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // AI DEMAND FORECAST CARD
                if (demandForecast != null)
                  DemandForecastCard(forecast: demandForecast)
                else
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('Demand forecast data unavailable')),
                  ),

                const SizedBox(height: 16),

                // AI BUSINESS ADVISOR CARD
                if (businessAdvisor != null)
                  BusinessAdvisorCard(advisor: businessAdvisor)
                else
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('Business advisor data unavailable')),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
