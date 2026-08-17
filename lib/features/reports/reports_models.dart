import 'package:flutter/material.dart';

enum PaymentStatus {
  paid,
  partial,
  unpaid;

  String get label => switch (this) {
        PaymentStatus.paid => 'Paid',
        PaymentStatus.partial => 'Partial',
        PaymentStatus.unpaid => 'Unpaid',
      };

  Color get color => switch (this) {
        PaymentStatus.paid => const Color(0xFF2E7D32),
        PaymentStatus.partial => const Color(0xFFED6C02),
        PaymentStatus.unpaid => const Color(0xFFD32F2F),
      };

  Color get backgroundColor => switch (this) {
        PaymentStatus.paid => const Color(0xFFE8F5E9),
        PaymentStatus.partial => const Color(0xFFFFF3E0),
        PaymentStatus.unpaid => const Color(0xFFFFEBEE),
      };
}

enum DateFilterType {
  allTime('All Time'),
  today('Today'),
  yesterday('Yesterday'),
  last7Days('Last 7 Days'),
  last30Days('Last 30 Days'),
  custom('Custom Range');

  final String label;
  const DateFilterType(this.label);
}

class ReportItemSold {
  final String itemId;
  final String name;
  final String category;
  final String soldBy;
  final double unitPrice;
  final int quantity;

  const ReportItemSold({
    required this.itemId,
    required this.name,
    required this.category,
    required this.soldBy,
    required this.unitPrice,
    required this.quantity,
  });

  double get totalRevenue => unitPrice * quantity;

  ReportItemSold copyWith({
    String? itemId,
    String? name,
    String? category,
    String? soldBy,
    double? unitPrice,
    int? quantity,
  }) {
    return ReportItemSold(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      category: category ?? this.category,
      soldBy: soldBy ?? this.soldBy,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}

class InvoiceLog {
  final String id;
  final String invoiceNumber;
  final DateTime date;
  final String customerName;
  final String customerPhone;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final PaymentStatus paymentStatus;
  final String servedBy;
  final List<ReportItemSold> items;

  const InvoiceLog({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.customerName,
    required this.customerPhone,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentStatus,
    required this.servedBy,
    required this.items,
  });

  InvoiceLog copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? date,
    String? customerName,
    String? customerPhone,
    double? totalAmount,
    double? paidAmount,
    double? dueAmount,
    PaymentStatus? paymentStatus,
    String? servedBy,
    List<ReportItemSold>? items,
  }) {
    return InvoiceLog(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      servedBy: servedBy ?? this.servedBy,
      items: items ?? this.items,
    );
  }
}
