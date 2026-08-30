import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

/// Global Financial Utility for precision rounding and dynamic currency formatting.
///
/// Mirrors backend monetary logic and supports shop-configured currency
/// (e.g. USD -> $, BDT -> ৳, EUR -> €, GBP -> £, etc.) across the entire application.
class MoneyUtil {
  static const String _currencyStorageKey = 'app_shop_currency_symbol';
  static const String _currencyCodeStorageKey = 'app_shop_currency_code';

  static String _currencySymbol = '৳';
  static String _currencyCode = 'BDT';

  /// Active currency symbol (e.g. "$", "৳", "€", "£", "₹", "AED ").
  static String get currencySymbol => _currencySymbol;

  /// Active currency code (e.g. "USD", "BDT", "EUR", "GBP").
  static String get currencyCode => _currencyCode;

  /// Maps standard ISO currency codes or symbols to appropriate display symbols.
  static String mapCurrencyToSymbol(String? rawCurrency) {
    if (rawCurrency == null || rawCurrency.trim().isEmpty) return '৳';
    final cleaned = rawCurrency.trim();
    switch (cleaned.toUpperCase()) {
      case 'USD':
      case 'US DOLLAR':
      case 'DOLLAR':
        return '\$';
      case 'BDT':
      case 'TAKA':
      case 'TK':
        return '৳';
      case 'EUR':
      case 'EURO':
        return '€';
      case 'GBP':
      case 'POUND':
        return '£';
      case 'INR':
      case 'RUPEE':
        return '₹';
      case 'AED':
      case 'DIRHAM':
        return 'AED ';
      case 'SAR':
      case 'RIYAL':
        return 'SAR ';
      case 'CAD':
        return 'CA\$';
      case 'AUD':
        return 'AU\$';
      case 'JPY':
      case 'CNY':
      case 'YEN':
      case 'YUAN':
        return '¥';
      case 'MYR':
        return 'RM ';
      case 'SGD':
        return 'SG\$';
      case 'PKR':
        return 'Rs ';
      default:
        return cleaned;
    }
  }

  /// Sets global currency in memory.
  static void setCurrency(String? rawCurrency) {
    if (rawCurrency == null || rawCurrency.trim().isEmpty) return;
    _currencyCode = rawCurrency.trim().toUpperCase();
    _currencySymbol = mapCurrencyToSymbol(rawCurrency);
    developer.log(
      '💲 [MoneyUtil] Currency set to symbol: "$_currencySymbol", code: "$_currencyCode"',
      name: 'MoneyUtil',
    );
  }

  /// Loads locally cached currency from SharedPreferences during app startup.
  static Future<void> loadSavedCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSymbol = prefs.getString(_currencyStorageKey);
      final savedCode = prefs.getString(_currencyCodeStorageKey);
      if (savedSymbol != null && savedSymbol.isNotEmpty) {
        _currencySymbol = savedSymbol;
      }
      if (savedCode != null && savedCode.isNotEmpty) {
        _currencyCode = savedCode;
      }
      developer.log(
        '💲 [MoneyUtil] Loaded cached currency: "$_currencySymbol" ($_currencyCode)',
        name: 'MoneyUtil',
      );
    } catch (e) {
      developer.log('⚠️ [MoneyUtil] Failed to load saved currency: $e', name: 'MoneyUtil');
    }
  }

  /// Persists the active currency code and symbol to SharedPreferences.
  static Future<void> persistCurrency(String? rawCurrency) async {
    if (rawCurrency == null || rawCurrency.trim().isEmpty) return;
    setCurrency(rawCurrency);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyStorageKey, _currencySymbol);
      await prefs.setString(_currencyCodeStorageKey, _currencyCode);
      developer.log(
        '💾 [MoneyUtil] Persisted currency "$_currencySymbol" ($_currencyCode) to storage',
        name: 'MoneyUtil',
      );
    } catch (e) {
      developer.log('⚠️ [MoneyUtil] Failed to persist currency: $e', name: 'MoneyUtil');
    }
  }

  /// Safely parses a dynamic JSON monetary value (num, String, or null) to double.
  static double parseMoney(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return roundMoney(value.toDouble());
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      return roundMoney(parsed ?? 0.0);
    }
    return 0.0;
  }

  /// Rounds monetary value to 2 decimal places (e.g. 308.33025 -> 308.33).
  static double roundMoney(double value) {
    return (value * 100.0).roundToDouble() / 100.0;
  }

  /// Formats monetary value into a fixed 2-decimal string (e.g. 790 -> "790.00").
  static String formatMoney(dynamic value) {
    final double amount = parseMoney(value);
    return amount.toStringAsFixed(2);
  }

  /// Formats monetary value into an integer or 2-decimal string if has cents (e.g. 790 -> "790", 790.5 -> "790.50").
  static String formatSmartMoney(dynamic value) {
    final double amount = parseMoney(value);
    if (amount % 1 == 0) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  /// Formats currency with the active symbol (e.g. "$790.00", "৳790.00").
  static String formatCurrency(dynamic value, {String? customSymbol, bool withSpace = false}) {
    final symbol = customSymbol ?? _currencySymbol;
    final space = withSpace ? ' ' : '';
    return '$symbol$space${formatMoney(value)}';
  }

  /// Formats currency with smart integer/decimal formatting (e.g. "$790", "৳790").
  static String formatSmartCurrency(dynamic value, {String? customSymbol, bool withSpace = false}) {
    final symbol = customSymbol ?? _currencySymbol;
    final space = withSpace ? ' ' : '';
    return '$symbol$space${formatSmartMoney(value)}';
  }
}
