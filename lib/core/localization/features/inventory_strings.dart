class InventoryStrings {
  static const String inventoryTitle = 'inventory_title';
  static const String addNewItem = 'add_new_item';
  static const String editItem = 'edit_item';
  static const String itemName = 'item_name';
  static const String sku = 'sku';
  static const String category = 'category';
  static const String allCategories = 'all_categories';
  static const String selectCategory = 'select_category';
  static const String addCategory = 'add_category';
  static const String unit = 'unit';
  static const String stockQuantity = 'stock_quantity';
  static const String lowStockThreshold = 'low_stock_threshold';
  static const String purchasePrice = 'purchase_price';
  static const String sellingPrice = 'selling_price';
  static const String importCsv = 'import_csv';
  static const String exportCsv = 'export_csv';
  static const String deleteItemConfirm = 'delete_item_confirm';
  static const String inStock = 'in_stock';
  static const String outOfStockTag = 'out_of_stock_tag';

  static const Map<String, String> bn = {
    inventoryTitle: 'ইনভেন্টরি ও মালামাল',
    addNewItem: 'নতুন পণ্য যোগ করুন',
    editItem: 'পণ্য পরিবর্তন করুন',
    itemName: 'পণ্যের নাম',
    sku: 'বারকোড / কোড (SKU)',
    category: 'ক্যাটাগরি',
    allCategories: 'সব ক্যাটাগরি',
    selectCategory: 'ক্যাটাগরি বাছাই করুন',
    addCategory: 'নতুন ক্যাটাগরি',
    unit: 'একক (Unit)',
    stockQuantity: 'স্টকের পরিমাণ',
    lowStockThreshold: 'কম স্টকের সতর্কবার্তা সীমা',
    purchasePrice: 'কেনা দাম (ক্রয়মূল্য)',
    sellingPrice: 'বিক্রি দাম (বিক্রয়মূল্য)',
    importCsv: 'CSV ফাইল থেকে আমদানি',
    exportCsv: 'CSV ফাইল রপ্তানি',
    deleteItemConfirm: 'আপনি কি নিশ্চিত যে পণ্যটি মুছে ফেলতে চান?',
    inStock: 'স্টক আছে',
    outOfStockTag: 'স্টক শেষ',
  };

  static const Map<String, String> en = {
    inventoryTitle: 'Inventory & Stock',
    addNewItem: 'Add New Item',
    editItem: 'Edit Item',
    itemName: 'Item Name',
    sku: 'Barcode / SKU',
    category: 'Category',
    allCategories: 'All Categories',
    selectCategory: 'Select Category',
    addCategory: 'Add Category',
    unit: 'Unit',
    stockQuantity: 'Stock Quantity',
    lowStockThreshold: 'Low Stock Alert Limit',
    purchasePrice: 'Purchase / Cost Price',
    sellingPrice: 'Selling Price',
    importCsv: 'Import from CSV',
    exportCsv: 'Export CSV',
    deleteItemConfirm: 'Are you sure you want to delete this item?',
    inStock: 'In Stock',
    outOfStockTag: 'Out of Stock',
  };
}
