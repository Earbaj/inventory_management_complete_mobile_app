abstract class BranchEvent {
  const BranchEvent();
}

/// Event: Fetch registered branches list.
class FetchBranchesEvent extends BranchEvent {
  const FetchBranchesEvent();
}

/// Event: Create a new branch.
class CreateBranchEvent extends BranchEvent {
  final String name;
  final String address;
  final String phone;

  const CreateBranchEvent({
    required this.name,
    required this.address,
    required this.phone,
  });
}
