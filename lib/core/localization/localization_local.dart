import 'package:flutter/widgets.dart';

import 'features/auth_strings.dart';
import 'features/common_strings.dart';
import 'features/customers_strings.dart';
import 'features/dashboard_strings.dart';
import 'features/inventory_strings.dart';
import 'features/pos_strings.dart';
import 'features/reports_strings.dart';
import 'features/settings_strings.dart';
import 'features/suppliers_strings.dart';

export 'features/auth_strings.dart';
export 'features/common_strings.dart';
export 'features/customers_strings.dart';
export 'features/dashboard_strings.dart';
export 'features/inventory_strings.dart';
export 'features/pos_strings.dart';
export 'features/reports_strings.dart';
export 'features/settings_strings.dart';
export 'features/suppliers_strings.dart';

mixin Bangla {
  // App & Common
  static const String title = CommonStrings.appName;
  static const String appName = CommonStrings.appName;
  static const String save = CommonStrings.save;
  static const String cancel = CommonStrings.cancel;
  static const String delete = CommonStrings.delete;
  static const String edit = CommonStrings.edit;
  static const String search = CommonStrings.search;
  static const String confirm = CommonStrings.confirm;
  static const String back = CommonStrings.back;
  static const String all = CommonStrings.all;
  static const String details = CommonStrings.details;
  static const String filter = CommonStrings.filter;
  static const String total = CommonStrings.total;
  static const String paid = CommonStrings.paid;
  static const String due = CommonStrings.due;
  static const String loading = CommonStrings.loading;
  static const String success = CommonStrings.success;
  static const String error = CommonStrings.error;

  // Auth
  static const String login = AuthStrings.login;
  static const String register = AuthStrings.register;
  static const String email = AuthStrings.email;
  static const String password = AuthStrings.password;
  static const String phone = AuthStrings.phone;
  static const String forgotPassword = AuthStrings.forgotPassword;
  static const String logout = AuthStrings.logout;

  static const String viewAll = CommonStrings.viewAll;

  // Dashboard
  static const String dashboard = DashboardStrings.dashboard;
  static const String todaySales = DashboardStrings.todaySales;
  static const String totalDues = DashboardStrings.totalDues;
  static const String totalStock = DashboardStrings.totalStock;
  static const String lowStockAlert = DashboardStrings.lowStockAlert;
  static const String outOfStock = DashboardStrings.outOfStock;
  static const String quickActions = DashboardStrings.quickActions;
  static const String newSale = DashboardStrings.newSale;
  static const String recentTransactions = DashboardStrings.recentTransactions;
  static const String topSellingItems = DashboardStrings.topSellingItems;
  static const String easyMode = DashboardStrings.easyMode;
  static const String standardMode = DashboardStrings.standardMode;
  static const String easyShopTitle = DashboardStrings.easyShopTitle;
  static const String easyShopSubtitle = DashboardStrings.easyShopSubtitle;
  static const String memoCreated = DashboardStrings.memoCreated;
  static const String successfulSales = DashboardStrings.successfulSales;
  static const String customersDueCount = DashboardStrings.customersDueCount;
  static const String viewDueList = DashboardStrings.viewDueList;
  static const String stockItemsCount = DashboardStrings.stockItemsCount;
  static const String stockLowWarning = DashboardStrings.stockLowWarning;
  static const String stockAllAdequate = DashboardStrings.stockAllAdequate;
  static const String stockWarning = DashboardStrings.stockWarning;
  static const String stockOk = DashboardStrings.stockOk;
  static const String paymentBreakdownEasy = DashboardStrings.paymentBreakdownEasy;
  static const String cashPayment = DashboardStrings.cashPayment;
  static const String digitalPayment = DashboardStrings.digitalPayment;
  static const String dueSalesBadge = DashboardStrings.dueSalesBadge;
  static const String quickActionsEasy = DashboardStrings.quickActionsEasy;
  static const String newSalePos = DashboardStrings.newSalePos;
  static const String addNewProductAction = DashboardStrings.addNewProductAction;
  static const String collectDueAction = DashboardStrings.collectDueAction;
  static const String recentSalesEasy = DashboardStrings.recentSalesEasy;
  static const String noRecentSalesEasy = DashboardStrings.noRecentSalesEasy;
  static const String memoNo = DashboardStrings.memoNo;
  static const String sendDueReminder = DashboardStrings.sendDueReminder;
  static const String goodMorning = DashboardStrings.goodMorning;
  static const String goodAfternoon = DashboardStrings.goodAfternoon;
  static const String goodEvening = DashboardStrings.goodEvening;
  static const String goodNight = DashboardStrings.goodNight;

  // POS
  static const String pos = PosStrings.posTitle;
  static const String posTitle = PosStrings.posTitle;
  static const String barcodeScan = PosStrings.barcodeScan;
  static const String cartItems = PosStrings.cartItems;
  static const String emptyCart = PosStrings.emptyCart;
  static const String clearCart = PosStrings.clearCart;
  static const String checkout = PosStrings.checkout;
  static const String items = PosStrings.items;
  static const String searchProductOrSku = PosStrings.searchProductOrSku;
  static const String scanBarcode = PosStrings.scanBarcode;
  static const String searchingDatabase = PosStrings.searchingDatabase;
  static const String noProductsFound = PosStrings.noProductsFound;
  static const String selectCustomer = PosStrings.selectCustomer;
  static const String walkInCustomer = PosStrings.walkInCustomer;
  static const String subtotal = PosStrings.subtotal;
  static const String discount = PosStrings.discount;
  static const String netTotal = PosStrings.netTotal;
  static const String paidAmount = PosStrings.paidAmount;
  static const String dueAmount = PosStrings.dueAmount;
  static const String paymentMethod = PosStrings.paymentMethod;
  static const String completeSale = PosStrings.completeSale;
  static const String saleSuccess = PosStrings.saleSuccess;
  static const String printReceipt = PosStrings.printReceipt;

  // Inventory
  static const String inventory = InventoryStrings.inventoryTitle;
  static const String inventoryTitle = InventoryStrings.inventoryTitle;
  static const String addNewItem = InventoryStrings.addNewItem;
  static const String itemName = InventoryStrings.itemName;
  static const String category = InventoryStrings.category;
  static const String stockQuantity = InventoryStrings.stockQuantity;
  static const String purchasePrice = InventoryStrings.purchasePrice;
  static const String sellingPrice = InventoryStrings.sellingPrice;

  // Customers
  static const String customers = CustomersStrings.customersTitle;
  static const String customersTitle = CustomersStrings.customersTitle;
  static const String addCustomer = CustomersStrings.addCustomer;
  static const String customerName = CustomersStrings.customerName;
  static const String customerPhone = CustomersStrings.customerPhone;
  static const String currentDue = CustomersStrings.currentDue;
  static const String collectPayment = CustomersStrings.collectPayment;
  static const String statement = CustomersStrings.statement;

  // Suppliers
  static const String suppliers = SuppliersStrings.suppliersTitle;
  static const String suppliersTitle = SuppliersStrings.suppliersTitle;
  static const String addSupplier = SuppliersStrings.addSupplier;
  static const String purchaseOrders = SuppliersStrings.purchaseOrders;
  static const String newPurchaseOrder = SuppliersStrings.newPurchaseOrder;

  // Reports
  static const String reports = ReportsStrings.reportsTitle;
  static const String reportsTitle = ReportsStrings.reportsTitle;
  static const String salesReport = ReportsStrings.salesReport;
  static const String profitLoss = ReportsStrings.profitLoss;

  // Settings
  static const String settings = SettingsStrings.settingsTitle;
  static const String settingsTitle = SettingsStrings.settingsTitle;
  static const String language = SettingsStrings.language;
  static const String subscription = SettingsStrings.subscription;

  // Combined Bengali Map
  static const Map<String, String> BN = {
    ...CommonStrings.bn,
    ...AuthStrings.bn,
    ...DashboardStrings.bn,
    ...PosStrings.bn,
    ...InventoryStrings.bn,
    ...CustomersStrings.bn,
    ...SuppliersStrings.bn,
    ...ReportsStrings.bn,
    ...SettingsStrings.bn,
  };

  // Combined English Map
  static const Map<String, String> EN = {
    ...CommonStrings.en,
    ...AuthStrings.en,
    ...DashboardStrings.en,
    ...PosStrings.en,
    ...InventoryStrings.en,
    ...CustomersStrings.en,
    ...SuppliersStrings.en,
    ...ReportsStrings.en,
    ...SettingsStrings.en,
  };
}

extension BanglaStringExt on String {
  String getString(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    if (langCode == 'en') {
      return Bangla.EN[this] ?? Bangla.BN[this] ?? this;
    }
    return Bangla.BN[this] ?? Bangla.EN[this] ?? this;
  }
}
