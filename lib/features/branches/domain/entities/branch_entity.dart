/// Domain Entity representing a Shop Branch.
class BranchEntity {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String shopId;
  final bool isDeleted;

  const BranchEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.shopId,
    this.isDeleted = false,
  });
}
