class ReturnCustomer {
  final String id;
  final String name;
  final String phone;

  const ReturnCustomer({
    required this.id,
    required this.name,
    required this.phone,
  });
}

class InvoiceItem {
  final String productId;
  final String productName;
  final String sku;
  final double price;
  final int purchasedQuantity;
  final int alreadyReturnedQuantity;

  const InvoiceItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.price,
    required this.purchasedQuantity,
    this.alreadyReturnedQuantity = 0,
  });

  int get availableQuantity =>
      purchasedQuantity - alreadyReturnedQuantity;
}

class CustomerInvoice {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final DateTime date;
  final List<InvoiceItem> items;

  const CustomerInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.date,
    required this.items,
  });

  double get total {
    return items.fold(
      0,
          (sum, item) =>
      sum +
          item.price * item.purchasedQuantity,
    );
  }
}