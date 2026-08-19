/// Data Transfer Object (DTO) for Merchant Payment Info JSON payload from GET /api/subscriptions/payment-info.
class PaymentInfoModel {
  final String bkashNumber;
  final String nagadNumber;
  final String rocketNumber;
  final String bankAccount;
  final String instructions;

  const PaymentInfoModel({
    required this.bkashNumber,
    required this.nagadNumber,
    required this.rocketNumber,
    required this.bankAccount,
    required this.instructions,
  });

  factory PaymentInfoModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> dataMap = json['data'] is Map<String, dynamic>
        ? json['data']
        : json;

    final bkash = dataMap['bkashNumber']?.toString() ?? dataMap['bkash']?.toString() ?? '01700000000 (Merchant)';
    final nagad = dataMap['nagadNumber']?.toString() ?? dataMap['nagad']?.toString() ?? '01700000000 (Merchant)';
    final rocket = dataMap['rocketNumber']?.toString() ?? dataMap['rocket']?.toString() ?? '01700000000 (Personal)';

    String bankStr = 'Dutch Bangla Bank Ltd - A/C 123-456-7890123';
    if (dataMap['bankDetails'] is Map<String, dynamic>) {
      final bankMap = dataMap['bankDetails'] as Map<String, dynamic>;
      final name = bankMap['bankName']?.toString() ?? 'Bank';
      final accNo = bankMap['accountNumber']?.toString() ?? '';
      final accName = bankMap['accountName']?.toString() ?? '';
      final branch = bankMap['branch']?.toString() ?? '';
      bankStr = '$name\nA/C: $accNo ($accName)\nBranch: $branch';
    } else if (dataMap['bank'] != null) {
      bankStr = dataMap['bank'].toString();
    }

    String instructionsStr = '';
    if (dataMap['instructions'] is List) {
      instructionsStr = (dataMap['instructions'] as List).map((e) => e.toString()).join('\n');
    } else if (dataMap['instructions'] != null) {
      instructionsStr = dataMap['instructions'].toString();
    }

    if (instructionsStr.isEmpty) {
      instructionsStr = 'Send money to our merchant number and submit TrxID below.';
    }

    return PaymentInfoModel(
      bkashNumber: bkash,
      nagadNumber: nagad,
      rocketNumber: rocket,
      bankAccount: bankStr,
      instructions: instructionsStr,
    );
  }

  Map<String, String> toNumbersMap() {
    return {
      'bkash': bkashNumber,
      'nagad': nagadNumber,
      'rocket': rocketNumber,
      'bank': bankAccount,
    };
  }
}
