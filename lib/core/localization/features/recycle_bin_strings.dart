class RecycleBinStrings {
  static const String recycleBinTitle = 'recycle_bin_title';
  static const String searchDeleted = 'recycle_bin_search';
  static const String allRecords = 'recycle_bin_all';
  static const String products = 'recycle_bin_products';
  static const String customers = 'recycle_bin_customers';
  static const String salesInvoices = 'recycle_bin_sales';
  static const String returns = 'recycle_bin_returns';
  static const String restoreItem = 'recycle_bin_restore';
  static const String permanentDelete = 'recycle_bin_perm_delete';
  static const String restoreConfirm = 'recycle_bin_restore_confirm';
  static const String restorePrompt = 'recycle_bin_restore_prompt';
  static const String permDeleteConfirm = 'recycle_bin_delete_confirm';
  static const String permDeletePrompt = 'recycle_bin_delete_prompt';
  static const String emptyBin = 'recycle_bin_empty';
  static const String emptyBinSubtitle = 'recycle_bin_empty_sub';
  static const String emptyTrashTooltip = 'recycle_bin_empty_tooltip';
  static const String emptyTrashConfirm = 'recycle_bin_empty_confirm';
  static const String emptyTrashPrompt = 'recycle_bin_empty_prompt';
  static const String emptyTrashBtn = 'recycle_bin_empty_btn';
  static const String cleanLogsTooltip = 'recycle_bin_clean_logs_tooltip';
  static const String cleanLogsConfirm = 'recycle_bin_clean_logs_confirm';
  static const String cleanLogsPrompt = 'recycle_bin_clean_logs_prompt';
  static const String cleanLogsBtn = 'recycle_bin_clean_logs_btn';
  static const String deletedPrefix = 'recycle_bin_deleted_prefix';
  static const String deletedByPrefix = 'recycle_bin_by_prefix';

  static const Map<String, String> bn = {
    recycleBinTitle: 'রিসাইকেল বিন',
    searchDeleted: 'মুছে ফেলা আইটেম খুঁজুন...',
    allRecords: 'সকল তথ্য',
    products: 'পণ্যসমূহ',
    customers: 'কাস্টমারগণ',
    salesInvoices: 'বিক্রির চালান',
    returns: 'ফেরতের খতিয়ান',
    restoreItem: 'পুনরুদ্ধার (রিস্টোর)',
    permanentDelete: 'স্থায়ীভাবে মুছুন',
    restoreConfirm: 'পুনরুদ্ধার নিশ্চিতকরণ',
    restorePrompt: 'আপনি কি এই আইটেমটি পুনরায় সক্রিয় করতে চান?',
    permDeleteConfirm: 'স্থায়ীভাবে মুছে ফেলার সতর্কতা',
    permDeletePrompt: 'এটি স্থায়ীভাবে মুছে যাবে এবং আর কখনো ফেরত পাওয়া যাবে না!',
    emptyBin: 'রিসাইকেল বিন সম্পূর্ণ খালি',
    emptyBinSubtitle: 'সাম্প্রতিক কোনো মুছে ফেলা রেকর্ড নেই।',
    emptyTrashTooltip: 'রিসাইকেল বিন খালি করুন',
    emptyTrashConfirm: 'রিসাইকেল বিন খালি করবেন?',
    emptyTrashPrompt: 'আপনি কি নিশ্চিত যে রিসাইকেল বিনের সব আইটেম স্থায়ীভাবে মুছে ফেলতে চান?\n\n⚠️ সতর্কতা: এটি আর ফিরিয়ে আনা সম্ভব নয়।',
    emptyTrashBtn: 'বিন খালি করুন',
    cleanLogsTooltip: 'পুরাতন অডিট লগ মুছুন',
    cleanLogsConfirm: 'পুরাতন অডিট লগ মুছবেন?',
    cleanLogsPrompt: 'ডাটাবেজের জায়গা খালি করতে ৯০ দিনের বেশি পুরোনো অডিট লগ মুছে ফেলতে চান?',
    cleanLogsBtn: 'লগ মুছুন',
    deletedPrefix: 'মুছে ফেলা হয়েছে: ',
    deletedByPrefix: 'দ্বারা: ',
  };

  static const Map<String, String> en = {
    recycleBinTitle: 'Recycle Bin',
    searchDeleted: 'Search deleted items...',
    allRecords: 'All Records',
    products: 'Products',
    customers: 'Customers',
    salesInvoices: 'Sales Invoices',
    returns: 'Returns',
    restoreItem: 'Restore',
    permanentDelete: 'Delete Permanently',
    restoreConfirm: 'Confirm Restore',
    restorePrompt: 'Are you sure you want to restore this item back to your active list?',
    permDeleteConfirm: 'Permanent Delete Warning',
    permDeletePrompt: 'This item will be permanently wiped out and cannot be recovered!',
    emptyBin: 'Recycle Bin is Empty',
    emptyBinSubtitle: 'No recently deleted records found.',
    emptyTrashTooltip: 'Empty Recycle Bin',
    emptyTrashConfirm: 'Empty Recycle Bin?',
    emptyTrashPrompt: 'Are you sure you want to permanently delete all items in the Recycle Bin?\n\n⚠️ WARNING: This action cannot be undone.',
    emptyTrashBtn: 'Empty Bin',
    cleanLogsTooltip: 'Clean 90-day Audit Logs',
    cleanLogsConfirm: 'Cleanup Old Audit Logs?',
    cleanLogsPrompt: 'Are you sure you want to purge audit activity logs older than 90 days to free up database storage?',
    cleanLogsBtn: 'Purge Logs',
    deletedPrefix: 'Deleted: ',
    deletedByPrefix: 'By: ',
  };
}
