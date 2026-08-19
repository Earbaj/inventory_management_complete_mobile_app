import '../repositories/customer_repository.dart';

/// UseCase to generate WhatsApp due payment reminder chat link from API.
class GetDueReminderLinkUseCase {
  final CustomerRepository repository;

  GetDueReminderLinkUseCase(this.repository);

  Future<Map<String, dynamic>> call(String customerId) async {
    return await repository.getDueReminderLink(customerId);
  }
}
