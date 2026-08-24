import '../../domain/entities/branch_entity.dart';

/// DTO Model for Branch JSON payload.
class BranchModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String shopId;
  final bool isDeleted;

  const BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.shopId,
    this.isDeleted = false,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? json['shop_id']?.toString() ?? '',
      isDeleted: json['isDeleted'] == true || json['is_deleted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
    };
  }

  BranchEntity toEntity() {
    return BranchEntity(
      id: id,
      name: name,
      address: address,
      phone: phone,
      shopId: shopId,
      isDeleted: isDeleted,
    );
  }
}
