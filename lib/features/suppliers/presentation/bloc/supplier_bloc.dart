import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/purchase_order_entity.dart';
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
    final currentState = state;
    if (currentState is SupplierLoadedState) {
      emit(currentState.copyWith(isListLoading: true));
    } else {
      emit(const SupplierLoadingState());
    }

    try {
      final suppliers = await getSuppliersUseCase(search: event.search, forceRefresh: event.forceRefresh);
      final orders = await getPurchaseOrdersUseCase(forceRefresh: event.forceRefresh);
      emit(SupplierLoadedState(
        suppliers: suppliers,
        purchaseOrders: orders,
        isListLoading: false,
      ));
    } catch (e) {
      final prevSuppliers = currentState is SupplierLoadedState ? currentState.suppliers : <SupplierEntity>[];
      final prevOrders = currentState is SupplierLoadedState ? currentState.purchaseOrders : <PurchaseOrderEntity>[];
      emit(SupplierErrorState(
        'Failed to load suppliers: ${e.toString()}',
        previousSuppliers: prevSuppliers,
        previousPurchaseOrders: prevOrders,
      ));
    }
  }

  Future<void> _onCreateSupplier(
    CreateSupplierEvent event,
    Emitter<SupplierState> emit,
  ) async {
    final currentState = state;
    if (currentState is SupplierLoadedState) {
      emit(currentState.copyWith(isSaving: true, isListLoading: true));
    }
    try {
      await createSupplierUseCase(event.supplier);
      final suppliers = await getSuppliersUseCase(forceRefresh: true);
      final orders = await getPurchaseOrdersUseCase(forceRefresh: true);
      emit(SupplierLoadedState(
        suppliers: suppliers,
        purchaseOrders: orders,
        successMessage: 'নতুন মহাজন প্রোফাইল সফলভাবে তৈরি হয়েছে।',
        isSaving: false,
        isListLoading: false,
      ));
    } catch (e) {
      if (currentState is SupplierLoadedState) {
        emit(currentState.copyWith(isSaving: false, isListLoading: false));
      }
      emit(SupplierErrorState('মহাজন তৈরি করা সম্ভব হয়নি: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateSupplier(
    UpdateSupplierEvent event,
    Emitter<SupplierState> emit,
  ) async {
    final currentState = state;
    if (currentState is SupplierLoadedState) {
      emit(currentState.copyWith(isSaving: true, isListLoading: true));
    }
    try {
      await updateSupplierUseCase(event.supplier);
      final suppliers = await getSuppliersUseCase(forceRefresh: true);
      final orders = await getPurchaseOrdersUseCase(forceRefresh: true);
      emit(SupplierLoadedState(
        suppliers: suppliers,
        purchaseOrders: orders,
        successMessage: 'মহাজনের তথ্য আপডেট হয়েছে।',
        isSaving: false,
        isListLoading: false,
      ));
    } catch (e) {
      if (currentState is SupplierLoadedState) {
        emit(currentState.copyWith(isSaving: false, isListLoading: false));
      }
      emit(SupplierErrorState('তথ্য আপডেট করতে ব্যর্থ: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteSupplier(
    DeleteSupplierEvent event,
    Emitter<SupplierState> emit,
  ) async {
    final currentState = state;
    if (currentState is SupplierLoadedState) {
      emit(currentState.copyWith(isSaving: true, isListLoading: true));
    }
    try {
      await deleteSupplierUseCase(event.id);
      final suppliers = await getSuppliersUseCase(forceRefresh: true);
      final orders = await getPurchaseOrdersUseCase(forceRefresh: true);
      emit(SupplierLoadedState(
        suppliers: suppliers,
        purchaseOrders: orders,
        successMessage: 'মহাজন প্রোফাইল ডিলিট করা হয়েছে।',
        isSaving: false,
        isListLoading: false,
      ));
    } catch (e) {
      if (currentState is SupplierLoadedState) {
        emit(currentState.copyWith(isSaving: false, isListLoading: false));
      }
      emit(SupplierErrorState('মহাজন ডিলিট করতে ব্যর্থ: ${e.toString()}'));
    }
  }

  Future<void> _onCreatePurchaseOrder(
    CreatePurchaseOrderEvent event,
    Emitter<SupplierState> emit,
  ) async {
    final currentState = state;
    if (currentState is SupplierLoadedState) {
      emit(currentState.copyWith(isSaving: true, isListLoading: true));
    }
    try {
      await createPurchaseOrderUseCase(event.order);
      final suppliers = await getSuppliersUseCase(forceRefresh: true);
      final orders = await getPurchaseOrdersUseCase(forceRefresh: true);
      emit(SupplierLoadedState(
        suppliers: suppliers,
        purchaseOrders: orders,
        successMessage: 'পাইকারি ক্রয়ের মেমো তৈরি ও ইনভেন্টরি স্টক সফলভাবে বাড়ানো হয়েছে! 🚚',
        isSaving: false,
        isListLoading: false,
      ));
    } catch (e) {
      if (currentState is SupplierLoadedState) {
        emit(currentState.copyWith(isSaving: false, isListLoading: false));
      }
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
        final orders = await getPurchaseOrdersUseCase(supplierId: event.supplierId, forceRefresh: event.forceRefresh);
        emit(currentState.copyWith(purchaseOrders: orders));
      } catch (e) {
        emit(SupplierErrorState('ক্রয়ের ইতিহাস লোড করা যায়নি: ${e.toString()}'));
      }
    }
  }
}
