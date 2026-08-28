enum TransactionType {
  sale,
  payment,
  returnInvoice,
  opening,
}

class CustomerTransaction {
  final String id;
  final DateTime date;
  final String reference;
  final TransactionType type;
  final double amount;
  final double runningBalance;
  final String note;

  const CustomerTransaction({
    required this.id,
    required this.date,
    required this.reference,
    required this.type,
    required this.amount,
    required this.runningBalance,
    this.note = '',
  });
}