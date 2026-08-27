import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isGeminiUsedThisMonth = false;

  @override
  void initState() {
    super.initState();
    _checkGeminiStatus();
    context.read<AiInsightsBloc>().add(const FetchAllAiInsightsEvent(forceGemini: false));
  }

  Future<void> _checkGeminiStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchStr = prefs.getString('last_gemini_fetch_date');
      if (lastFetchStr != null) {
        final lastFetch = DateTime.tryParse(lastFetchStr);
        if (lastFetch != null) {
          final now = DateTime.now();
          if (lastFetch.year == now.year && lastFetch.month == now.month) {
            setState(() {
              _isGeminiUsedThisMonth = true;
            });
          }
        }
      }
    } catch (_) {}
  }

  void _onCustomerScoreRequested(CustomerEntity? customer) {
    if (customer == null) return;
    setState(() {
      _selectedCustomerForScore = customer;
    });

    context.read<AiInsightsBloc>().add(FetchCustomerCreditScoreEvent(
      customer.id,
      forceGemini: !_isGeminiUsedThisMonth,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              context.read<AiInsightsBloc>().add(const FetchAllAiInsightsEvent(forceGemini: false));
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Local Analytics',
          ),
        ],
      ),
      body: BlocConsumer<AiInsightsBloc, AiInsightsState>(
        listener: (context, state) {
          if (state is AiInsightsLoadedState) {
            _checkGeminiStatus();
          }
          if (state is AiInsightsLoadedState && state.customerCreditScore != null && !state.isCustomerScoreLoading) {
            // Show Credit Score Modal Dialog
            showDialog(
              context: context,
              builder: (_) => CustomerCreditScoreDialog(creditScore: state.customerCreditScore!),
            );
          } else if (state is AiInsightsErrorState) {
            final isLimitErr = state.message.toLowerCase().contains('limit');
            final errMsg = isLimitErr
                ? 'Monthly Gemini AI limit reached for this shop. Heuristic engine will continue to run.'
                : state.message;

            if (isLimitErr) {
              setState(() {
                _isGeminiUsedThisMonth = true;
              });
              SharedPreferences.getInstance().then((prefs) {
                prefs.setString('last_gemini_fetch_date', DateTime.now().toIso8601String());
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errMsg),
                backgroundColor: isLimitErr ? Colors.orange.shade800 : Colors.red.shade700,
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
          final isAi = demandForecast?.isAiPowered ?? true;

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
                                Text(
                                  isAi ? 'Gemini 2.5 Flash AI' : 'Heuristic Prediction',
                                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isAi ? Colors.amber : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isAi ? 'PRO' : 'LOCAL',
                                    style: TextStyle(color: isAi ? Colors.black : Colors.blue.shade900, fontSize: 9, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAi
                                  ? 'Smart demand forecasting, customer credit risk assessment & growth advisor.'
                                  : 'Offline rules engine generating analytics based on local transaction metrics.',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                 ),
 
                 const SizedBox(height: 12),
                 if (!_isGeminiUsedThisMonth) ...[
                   Card(
                     color: Colors.purple.shade50,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.stretch,
                         children: [
                           Row(
                             children: [
                               const Icon(Icons.info_outline_rounded, color: Colors.purple),
                               const SizedBox(width: 8),
                               Expanded(
                                 child: Text(
                                   'Monthly Gemini AI analysis is available! Run it now to update store predictions.',
                                   style: TextStyle(color: Colors.purple.shade900, fontWeight: FontWeight.w600, fontSize: 13),
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 10),
                           FilledButton.icon(
                             style: FilledButton.styleFrom(
                               backgroundColor: Colors.purple,
                               padding: const EdgeInsets.symmetric(vertical: 14),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                             ),
                             onPressed: () {
                               context.read<AiInsightsBloc>().add(const FetchAllAiInsightsEvent(forceGemini: true));
                             },
                             icon: const Icon(Icons.auto_awesome_rounded),
                             label: const Text('Run Gemini AI Analysis (1 Limit/Month)'),
                           ),
                         ],
                       ),
                     ),
                   ),
                 ] else ...[
                   Card(
                     color: Colors.green.shade50,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                       child: Row(
                         children: [
                           const Icon(Icons.check_circle_rounded, color: Colors.green),
                           const SizedBox(width: 10),
                           Expanded(
                            child: Text(
                              'Gemini AI analysis limit reached for this month. (Next run available next month).',
                              style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                         ],
                       ),
                     ),
                   ),
                 ],

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
