import '../../../../core/utils/money_util.dart';

/// Data Transfer Object (DTO) for Return Item JSON payload.
class ReturnItemModel {
  final String id;
  final String saleId;
  final String invoiceNo;
  final String itemId;
  final String itemName;
  final String? customerId;
  final String? customerName;
  final int returnQuantity;
  final double unitPrice;
  final double totalRefundAmount;
  final String refundMethod;
  final bool isRestocked;
  final String? reason;
  final String? createdAt;

  const ReturnItemModel({
    required this.id,
    this.saleId = '',
    required this.invoiceNo,
    required this.itemId,
    required this.itemName,
    this.customerId,
    this.customerName,
    required this.returnQuantity,
    required this.unitPrice,
    required this.totalRefundAmount,
    required this.refundMethod,
    this.isRestocked = true,
    this.reason,
    this.createdAt,
  });

  static double _parseDouble(dynamic val) => MoneyUtil.parseMoney(val);

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> itemMap = json;
    if (json['data'] is Map<String, dynamic>) {
      itemMap = json['data'] as Map<String, dynamic>;
    } else if (json['return'] is Map<String, dynamic>) {
      itemMap = json['return'] as Map<String, dynamic>;
    }

    if (itemMap['returnedItems'] is List && (itemMap['returnedItems'] as List).isNotEmpty) {
      final firstItem = (itemMap['returnedItems'] as List).first;
      if (firstItem is Map<String, dynamic>) {
        itemMap = Map<String, dynamic>.from(itemMap)..addAll(firstItem);
      }
    }

    final dynamic restockedVal = itemMap['isRestocked'] ?? itemMap['is_restocked'] ?? itemMap['restocked'];
    final bool restocked = restockedVal == null ? true : (restockedVal == true || restockedVal.toString() == 'true');

    String? parsedCustomerId;
    String? parsedCustomerName;

    if (itemMap['customer'] is Map<String, dynamic>) {
      final custMap = itemMap['customer'] as Map<String, dynamic>;
      parsedCustomerId = custMap['_id']?.toString() ?? custMap['id']?.toString();
      parsedCustomerName = custMap['name']?.toString();
    } else if (itemMap['customerId'] is Map<String, dynamic>) {
      final custMap = itemMap['customerId'] as Map<String, dynamic>;
      parsedCustomerId = custMap['_id']?.toString() ?? custMap['id']?.toString();
      parsedCustomerName = custMap['name']?.toString();
    } else if (itemMap['sale'] is Map<String, dynamic> && (itemMap['sale'] as Map<String, dynamic>)['customer'] is Map) {
      final custMap = (itemMap['sale'] as Map<String, dynamic>)['customer'] as Map<String, dynamic>;
      parsedCustomerId = custMap['_id']?.toString() ?? custMap['id']?.toString();
      parsedCustomerName = custMap['name']?.toString();
    } else if (itemMap['saleId'] is Map<String, dynamic> && (itemMap['saleId'] as Map<String, dynamic>)['customer'] is Map) {
      final custMap = (itemMap['saleId'] as Map<String, dynamic>)['customer'] as Map<String, dynamic>;
      parsedCustomerId = custMap['_id']?.toString() ?? custMap['id']?.toString();
      parsedCustomerName = custMap['name']?.toString();
    } else {
      parsedCustomerId = (itemMap['customerId'] ?? itemMap['customer_id'] ?? (itemMap['customer'] is String ? itemMap['customer'] : null))?.toString();
      parsedCustomerName = (itemMap['customerName'] ?? itemMap['customer_name'])?.toString();
    }

    return ReturnItemModel(
      id: itemMap['id']?.toString() ?? itemMap['_id']?.toString() ?? '',
      saleId: (itemMap['saleId'] is Map ? itemMap['saleId']['_id'] : itemMap['saleId'])?.toString() ??
          (itemMap['sale_id'] is Map ? itemMap['sale_id']['_id'] : itemMap['sale_id'])?.toString() ??
          (itemMap['sale'] is Map ? itemMap['sale']['_id'] : itemMap['sale'])?.toString() ??
          '',
      invoiceNo: itemMap['invoiceNo']?.toString() ??
          itemMap['invoice_no']?.toString() ??
          itemMap['invoiceNumber']?.toString() ??
          (itemMap['sale'] is Map ? itemMap['sale']['invoiceNo'] : null)?.toString() ??
          (itemMap['saleId'] is Map ? itemMap['saleId']['invoiceNo'] : null)?.toString() ??
          '',
      itemId: itemMap['itemId']?.toString() ?? itemMap['item_id']?.toString() ?? '',
      itemName: itemMap['itemName']?.toString() ?? itemMap['item_name']?.toString() ?? itemMap['name']?.toString() ?? '',
      customerId: parsedCustomerId,
      customerName: parsedCustomerName,
      returnQuantity: _parseInt(itemMap['returnQuantity'] ?? itemMap['quantity'] ?? itemMap['qty'] ?? 1),
      unitPrice: _parseDouble(itemMap['unitPrice'] ?? itemMap['unit_price'] ?? itemMap['price']),
      totalRefundAmount: _parseDouble(itemMap['totalRefundAmount'] ?? itemMap['refundAmount'] ?? itemMap['refund_amount'] ?? itemMap['totalPrice'] ?? itemMap['totalRefund']),
      refundMethod: itemMap['refundMethod']?.toString() ?? itemMap['refund_method']?.toString() ?? itemMap['paymentMethod']?.toString() ?? 'cash',
      isRestocked: restocked,
      reason: itemMap['reason']?.toString(),
      createdAt: itemMap['createdAt']?.toString() ?? itemMap['created_at']?.toString() ?? itemMap['date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final String targetSaleId = saleId.isNotEmpty ? saleId : (id.isNotEmpty ? id : invoiceNo);

    final String custId = customerId ?? '';
    final String custName = customerName ?? '';

    return {
      'saleId': targetSaleId,
      'invoiceNo': invoiceNo,
      'returnedItems': [
        {
          'itemId': itemId,
          'quantity': returnQuantity,
          'returnQuantity': returnQuantity,
          'unitPrice': unitPrice,
          'refundAmount': totalRefundAmount,
          'totalRefundAmount': totalRefundAmount,
        }
      ],
      'itemId': itemId,
      'itemName': itemName,
      if (custId.isNotEmpty) 'customerId': custId,
      if (custId.isNotEmpty) 'customer_id': custId,
      if (custId.isNotEmpty) 'customer': custId,
      if (custName.isNotEmpty) 'customerName': custName,
      if (custName.isNotEmpty) 'customer_name': custName,
      'returnQuantity': returnQuantity,
      'unitPrice': unitPrice,
      'totalRefundAmount': totalRefundAmount,
      'refundMethod': refundMethod,
      'refund_method': refundMethod,
      'paymentMethod': refundMethod,
      'isRestocked': isRestocked,
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
