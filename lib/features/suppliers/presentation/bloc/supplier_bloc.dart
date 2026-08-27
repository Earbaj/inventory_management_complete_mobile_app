import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_suppliers_usecase.dart';
import '../../domain/usecases/create_supplier_usecase.dart';
import '../../domain/usecases/update_supplier_usecase.dart';
import '../../domain/usecases/delete_supplier_usecase.dart';
import '../../domain/usecases/create_purchase_order_usecase.dart';
import '../../domain/usecases/get_purchase_orders_usecase.dart';
import 'supplier_event.dart';
import 'supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final GetSuppliersUseCase getSuppliersUseCase;
  final CreateSupplierUseCase createSupplierUseCase;
  final UpdateSupplierUseCase updateSupplierUseCase;
  final DeleteSupplierUseCase deleteSupplierUseCase;
  final CreatePurchaseOrderUseCase createPurchaseOrderUseCase;
  final GetPurchaseOrdersUseCase getPurchaseOrdersUseCase;

  SupplierBloc({
    required this.getSuppliersUseCase,
    required this.createSupplierUseCase,
    required this.updateSupplierUseCase,
    required this.deleteSupplierUseCase,
    required this.createPurchaseOrderUseCase,
    required this.getPurchaseOrdersUseCase,
  }) : super(const SupplierInitialState()) {
    on<LoadSuppliersEvent>(_onLoadSuppliers);
    on<CreateSupplierEvent>(_onCreateSupplier);
    on<UpdateSupplierEvent>(_onUpdateSupplier);
    on<DeleteSupplierEvent>(_onDeleteSupplier);
    on<CreatePurchaseOrderEvent>(_onCreatePurchaseOrder);
    on<LoadPurchaseOrdersEvent>(_onLoadPurchaseOrders);
  }

  Future<void> _onLoadSuppliers(
    LoadSuppliersEvent event,
    Emitter<SupplierState> emit,
  ) async {
    emit(const SupplierLoadingState());
    try {
      final suppliers = await getSuppliersUseCase(search: event.search);
      final orders = await getPurchaseOrdersUseCase();
      emit(SupplierLoadedState(
        suppliers: suppliers,
        purchaseOrders: orders,
      ));
    } catch (e) {
      emit(SupplierErrorState('Failed to load suppliers: ${e.toString()}'));
    }
  }

  Future<void> _onCreateSupplier(
    CreateSupplierEvent event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      await createSupplierUseCase(event.supplier);
      final suppliers = await getSuppliersUseCase();
      final orders = await getPurchaseOrdersUseCase();
      emit(SupplierLoadedState(
        suppliers: suppliers,
        purchaseOrders: orders,
        successMessage: 'নতুন মহাজন প্রোফাইল সফলভাবে তৈরি হয়েছে।',
      ));
    } catch (e) {
      emit(SupplierErrorState('মহাজন তৈরি করা সম্ভব হয়নি: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateSupplier(
    UpdateSupplierEvent event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      await updateSupplierUseCase(event.supplier);
      final suppliers = await getSuppliersUseCase();
      final orders = await getPurchaseOrdersUseCase();
      emit(SupplierLoadedState(
        suppliers: suppliers,
        purchaseOrders: orders,
        successMessage: 'মহাজনের তথ্য আপডেট হয়েছে।',
      ));
    } catch (e) {
      emit(SupplierErrorState('তথ্য আপডেট করতে ব্যর্থ: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteSupplier(
    DeleteSupplierEvent event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      await deleteSupplierUseCase(event.id);
      final suppliers = await getSuppliersUseCase();
      final orders = await getPurchaseOrdersUseCase();
      emit(SupplierLoadedState(
        suppliers: suppliers,
        purchaseOrders: orders,
        successMessage: 'মহাজন প্রোফাইল ডিলিট করা হয়েছে।',
      ));
    } catch (e) {
      emit(SupplierErrorState('মহাজন ডিলিট করতে ব্যর্থ: ${e.toString()}'));
    }
  }

  Future<void> _onCreatePurchaseOrder(
    CreatePurchaseOrderEvent event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      await createPurchaseOrderUseCase(event.order);
      final suppliers = await getSuppliersUseCase();
      final orders = await getPurchaseOrdersUseCase();
      emit(SupplierLoadedState(
        suppliers: suppliers,
        purchaseOrders: orders,
        successMessage: 'পাইকারি ক্রয়ের মেমো তৈরি ও ইনভেন্টরি স্টক সফলভাবে বাড়ানো হয়েছে! 🚚',
      ));
    } catch (e) {
      emit(SupplierErrorState('ক্রয়ের মেমো তৈরি ব্যর্থ: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPurchaseOrders(
    LoadPurchaseOrdersEvent event,
    Emitter<SupplierState> emit,
  ) async {
    if (state is SupplierLoadedState) {
      final currentState = state as SupplierLoadedState;
      try {
        final orders = await getPurchaseOrdersUseCase(supplierId: event.supplierId);
        emit(currentState.copyWith(purchaseOrders: orders));
      } catch (e) {
        emit(SupplierErrorState('ক্রয়ের ইতিহাস লোড করা যায়নি: ${e.toString()}'));
      }
    }
  }
}
