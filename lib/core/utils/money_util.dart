/// Global Financial Utility for precision rounding and monetary formatting.
///
/// Mirrors backend `money.util.ts` logic to ensure strict 2-decimal precision
/// and safe String-to-double parsing across sales, returns, customers, expenses, and dashboard.
class MoneyUtil {
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

  /// Formats currency with Taka symbol (e.g. "৳ 790.00").
  static String formatCurrency(dynamic value) {
    return '৳ ${formatMoney(value)}';
  }
}
