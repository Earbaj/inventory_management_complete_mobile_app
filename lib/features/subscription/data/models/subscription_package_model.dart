/// Data Transfer Object (DTO) for Subscription Package JSON payloads from GET /api/subscriptions/packages.
class SubscriptionPackageModel {
  final String id;
  final String name;
  final String tier; // 'free', 'premium', 'enterprise'
  final double price; // e.g. 0.0 or 1000.0
  final int maxCustomers; // -1 for unlimited
  final int maxSales; // -1 for unlimited
  final List<String> features;
  final String duration; // '30 Days', '365 Days'

  const SubscriptionPackageModel({
    required this.id,
    required this.name,
    required this.tier,
    required this.price,
    required this.maxCustomers,
    required this.maxSales,
    required this.features,
    this.duration = '30 Days',
  });

  factory SubscriptionPackageModel.fromJson(Map<String, dynamic> json) {
    final String packageId = json['id']?.toString() ?? 'free';
    final String derivedTier = json['tier']?.toString() ??
        (packageId.contains('premium')
            ? 'premium'
            : (packageId.contains('free') ? 'free' : packageId));

    final Map<String, dynamic> limitsMap = json['limits'] is Map<String, dynamic>
        ? (json['limits'] as Map<String, dynamic>)
        : {};

    int parseLimit(dynamic val) {
      if (val == null || val.toString().toLowerCase() == 'unlimited') return -1;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? -1;
      return -1;
    }

    final int customers = limitsMap.containsKey('customers')
        ? parseLimit(limitsMap['customers'])
        : (json['maxCustomers'] != null ? parseLimit(json['maxCustomers']) : 50);

    final int sales = limitsMap.containsKey('sales')
        ? parseLimit(limitsMap['sales'])
        : (json['maxSales'] != null ? parseLimit(json['maxSales']) : 100);

    final String desc = json['description']?.toString() ?? '';
    final int days = json['durationDays'] is num ? (json['durationDays'] as num).toInt() : 30;
    final String durationStr = days > 0 ? '$days Days' : 'Monthly';

    final List<String> parsedFeatures = [];
    if (desc.isNotEmpty) parsedFeatures.add(desc);
    if (json['features'] is List) {
      parsedFeatures.addAll((json['features'] as List).map((e) => e.toString()));
    }

    return SubscriptionPackageModel(
      id: packageId,
      name: json['name']?.toString() ?? json['title']?.toString() ?? 'Standard Package',
      tier: derivedTier,
      price: (json['price'] ?? 0.0).toDouble(),
      maxCustomers: customers,
      maxSales: sales,
      features: parsedFeatures,
      duration: durationStr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tier': tier,
      'price': price,
      'maxCustomers': maxCustomers,
      'maxSales': maxSales,
      'features': features,
      'duration': duration,
    };
  }
}
