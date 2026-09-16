class ReturnsStrings {
  static const String returnsTitle = 'returns_title';
  static const String processReturn = 'process_return';
  static const String returnLogs = 'return_logs';
  static const String searchReturns = 'search_returns';
  static const String selectCustomer = 'returns_select_customer';
  static const String allCustomersAndWalkIn = 'returns_all_customers_walk_in';
  static const String selectInvoice = 'returns_select_invoice';
  static const String chooseInvoice = 'returns_choose_invoice';
  static const String noInvoicesFound = 'returns_no_invoices_found';
  static const String returnItems = 'returns_items';
  static const String reasonForReturn = 'returns_reason';
  static const String refundMethod = 'returns_refund_method';
  static const String adjustDue = 'returns_adjust_due';
  static const String cashRefund = 'returns_cash_refund';
  static const String onlineWallet = 'returns_online_wallet';
  static const String restockToInventory = 'returns_restock_inventory';
  static const String fullReturned = 'returns_full_returned';
  static const String partialReturn = 'returns_partial_return';
  static const String refundTotal = 'returns_refund_total';
  static const String submitReturn = 'returns_submit';
  static const String returnSuccess = 'returns_success';
  static const String returnFailed = 'returns_failed';
  static const String selectReturnQty = 'returns_select_qty';
  static const String totalReturnUnits = 'returns_total_units';
  static const String restockSubtitle = 'returns_restock_sub';
  static const String returnQuantity = 'returns_qty_label';
  static const String selectCustInvoicePrompt = 'returns_select_prompt';
  static const String invoiceSummary = 'returns_invoice_summary';
  static const String noReturnLogs = 'returns_no_logs';

  static const Map<String, String> bn = {
    returnsTitle: 'ফেরত ও সমন্বয়',
    processReturn: 'পণ্য ফেরত নিন',
    returnLogs: 'ফেরতের খতিয়ান',
    searchReturns: 'চালান বা কারণ দিয়ে খুঁজুন...',
    selectCustomer: '১. কাস্টমার নির্বাচন করুন',
    allCustomersAndWalkIn: 'সকল কাস্টমার ও সাধারণ ক্রেতার চালান',
    selectInvoice: '২. যে চালানের পণ্য ফেরত হবে তা নির্বাচন করুন',
    chooseInvoice: 'একটি চালান বাছুন',
    noInvoicesFound: 'এই কাস্টমারের কোনো চালান পাওয়া যায়নি',
    returnItems: 'ফেরতের পণ্যসমূহ',
    reasonForReturn: 'ফেরতের কারণ (যেমন: ত্রুটিযুক্ত, ভুল সাইজ)',
    refundMethod: 'মূল্য ফেরতের মাধ্যম',
    adjustDue: 'বাকি থেকে সমন্বয়',
    cashRefund: 'নগদ ফেরত',
    onlineWallet: 'বিকাশ / ওয়ালেট',
    restockToInventory: 'ফেরত পণ্য পুনরায় স্টকে যোগ করুন',
    fullReturned: 'সম্পূর্ণ ফেরত',
    partialReturn: 'আংশিক ফেরত',
    refundTotal: 'মোট ফেরত মূল্য:',
    submitReturn: 'পণ্য ফেরত সম্পন্ন করুন',
    returnSuccess: 'পণ্য সফলভাবে ফেরত নেওয়া হয়েছে!',
    returnFailed: 'পণ্য ফেরত প্রক্রিয়া ব্যর্থ হয়েছে',
    noReturnLogs: 'কোনো ফেরতের রেকর্ড পাওয়া যায়নি',
    selectReturnQty: '৩. ফেরত পণ্যের পরিমাণ নির্ধারণ করুন',
    totalReturnUnits: 'মোট ফেরত পণ্য:',
    restockSubtitle: 'গুদামে পণ্যের মজুদ পুনরায় বৃদ্ধি পাবে',
    returnQuantity: 'ফেরতের পরিমাণ:',
    selectCustInvoicePrompt: 'পণ্য ফেরত নিতে অনুগ্রহ করে একজন কাস্টমার এবং একটি চালান নির্বাচন করুন।',
    invoiceSummary: 'চালানের সারসংক্ষেপ',
  };

  static const Map<String, String> en = {
    returnsTitle: 'Returns & Restock',
    processReturn: 'Process Return',
    returnLogs: 'Return Logs & History',
    searchReturns: 'Search returns by invoice or reason...',
    selectCustomer: '1. Select Customer',
    allCustomersAndWalkIn: 'All Customers & Walk-in Invoices',
    selectInvoice: '2. Select Invoice to Return Items From',
    chooseInvoice: 'Choose an invoice',
    noInvoicesFound: 'No invoices found for this customer',
    returnItems: 'Return Items',
    reasonForReturn: 'Reason for Return (e.g. Damaged, Wrong size)',
    refundMethod: 'Refund Method',
    adjustDue: 'Due Adjust',
    cashRefund: 'Cash Refund',
    onlineWallet: 'bKash / Wallet',
    restockToInventory: 'Restock Product(s) back into Inventory',
    fullReturned: 'FULL RETURNED',
    partialReturn: 'PARTIAL RETURN',
    refundTotal: 'Total Refund Amount:',
    submitReturn: 'Complete Return Process',
    returnSuccess: 'Return processed successfully!',
    returnFailed: 'Failed to process return',
    noReturnLogs: 'No return logs found',
    selectReturnQty: '3. Select Return Quantity for Purchased Items',
    totalReturnUnits: 'Total Return Items:',
    restockSubtitle: 'Increases available stock in warehouse',
    returnQuantity: 'Return Quantity:',
    selectCustInvoicePrompt: 'Please select a customer and an invoice to process product return.',
    invoiceSummary: 'Invoice Summary',
  };
}
