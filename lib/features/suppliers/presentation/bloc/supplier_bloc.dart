import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/supplier_repository_impl.dart';
import 'supplier_event.dart';
import 'supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final SupplierRepository repository;

  SupplierBloc({required this.repository}) : super(const SupplierInitialState()) {
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
      final suppliers = await repository.getSuppliers(search: event.search);
      final orders = await repository.getPurchaseOrders();
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
      await repository.createSupplier(event.supplier);
      final suppliers = await repository.getSuppliers();
      final orders = await repository.getPurchaseOrders();
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
      await repository.updateSupplier(event.supplier);
      final suppliers = await repository.getSuppliers();
      final orders = await repository.getPurchaseOrders();
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
      await repository.deleteSupplier(event.id);
      final suppliers = await repository.getSuppliers();
      final orders = await repository.getPurchaseOrders();
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
      await repository.createPurchaseOrder(event.order);
      final suppliers = await repository.getSuppliers();
      final orders = await repository.getPurchaseOrders();
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
        final orders = await repository.getPurchaseOrders(supplierId: event.supplierId);
        emit(currentState.copyWith(purchaseOrders: orders));
      } catch (e) {
        emit(SupplierErrorState('ক্রয়ের ইতিহাস লোড করা যায়নি: ${e.toString()}'));
      }
    }
  }
}
