import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/export_customer_ledger_usecase.dart';
import '../../domain/usecases/export_customers_usecase.dart';
import '../../domain/usecases/export_inventory_usecase.dart';
import '../../domain/usecases/export_sales_usecase.dart';
import 'export_event.dart';
import 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final ExportInventoryUseCase exportInventoryUseCase;
  final ExportCustomersUseCase exportCustomersUseCase;
  final ExportSalesUseCase exportSalesUseCase;
  final ExportCustomerLedgerUseCase exportCustomerLedgerUseCase;

  ExportBloc({
    required this.exportInventoryUseCase,
    required this.exportCustomersUseCase,
    required this.exportSalesUseCase,
    required this.exportCustomerLedgerUseCase,
  }) : super(const ExportInitialState()) {
    on<TriggerExportInventoryEvent>(_onExportInventory);
    on<TriggerExportCustomersEvent>(_onExportCustomers);
    on<TriggerExportSalesEvent>(_onExportSales);
    on<TriggerExportCustomerLedgerEvent>(_onExportCustomerLedger);
  }

  Future<void> _onExportInventory(
    TriggerExportInventoryEvent event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportLoadingState(message: 'Exporting inventory products to CSV...'));
    try {
      final file = await exportInventoryUseCase();
      emit(ExportSuccessState(file));
    } catch (e) {
      emit(ExportErrorState(e.toString()));
    }
  }

  Future<void> _onExportCustomers(
    TriggerExportCustomersEvent event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportLoadingState(message: 'Exporting customers & due balances to CSV...'));
    try {
      final file = await exportCustomersUseCase();
      emit(ExportSuccessState(file));
    } catch (e) {
      emit(ExportErrorState(e.toString()));
    }
  }

  Future<void> _onExportSales(
    TriggerExportSalesEvent event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportLoadingState(message: 'Exporting sales invoices history to CSV...'));
    try {
      final file = await exportSalesUseCase();
      emit(ExportSuccessState(file));
    } catch (e) {
      emit(ExportErrorState(e.toString()));
    }
  }

  Future<void> _onExportCustomerLedger(
    TriggerExportCustomerLedgerEvent event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportLoadingState(message: 'Exporting customer ledger statement to CSV...'));
    try {
      final file = await exportCustomerLedgerUseCase(event.customerId);
      emit(ExportSuccessState(file));
    } catch (e) {
      emit(ExportErrorState(e.toString()));
    }
  }
}
