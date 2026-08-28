import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
import '../../customer.dart';
import 'customer_info.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStatement;
  final VoidCallback? onCollectPayment;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
    required this.onStatement,
    this.onCollectPayment,
  });

  Future<void> _launchWhatsAppReminder(BuildContext context) async {
    try {
      final res = await InjectionContainer.customerRepository.getDueReminderLink(customer.id);
      final rawUrl = res['whatsappUrl']?.toString() ?? res['url']?.toString() ?? '';

      String targetUrl = rawUrl;
      if (targetUrl.isEmpty) {
        final cleanPhone = customer.phone.replaceAll(RegExp(r'[^0-9]'), '');
        final formattedPhone = cleanPhone.startsWith('88') ? cleanPhone : '88$cleanPhone';
        final text = Uri.encodeComponent('Dear ${customer.name}, your due payment of Tk ${customer.totalDue.toStringAsFixed(0)} is pending. Please clear your due payment.');
        targetUrl = 'https://api.whatsapp.com/send?phone=$formattedPhone&text=$text';
      }

      final uri = Uri.parse(targetUrl);
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }

      if (!launched) {
        // Fallback: SMS
        final cleanPhone = customer.phone.replaceAll(RegExp(r'[^0-9]'), '');
        final smsUri = Uri.parse('sms:$cleanPhone?body=${Uri.encodeComponent("Dear ${customer.name}, your due payment of Tk ${customer.totalDue.toStringAsFixed(0)} is pending.")}');
        await launchUrl(smsUri);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp reminder: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AVATAR
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(customer.name),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // CUSTOMER INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 15,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            customer.phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    if (customer.address?.isNotEmpty == true) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              customer.address!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // MORE POPUP MENU
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'pay':
                      if (onCollectPayment != null) onCollectPayment!();
                      break;
                    case 'whatsapp':
                      _launchWhatsAppReminder(context);
                      break;
                    case 'statement':
                      onStatement();
                      break;
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    if (customer.hasDue) ...[
                      const PopupMenuItem(
                        value: 'pay',
                        child: Row(
                          children: [
                            Icon(Icons.payments_outlined, color: Colors.green),
                            SizedBox(width: 10),
                            Text('Receive Payment', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'whatsapp',
                        child: Row(
                          children: [
                            Icon(Icons.chat_outlined, color: Colors.teal),
                            SizedBox(width: 10),
                            Text('WhatsApp Due Reminder', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                    const PopupMenuItem(
                      value: 'statement',
                      child: Row(
                        children: [
                          Icon(Icons.receipt_long_outlined),
                          SizedBox(width: 10),
                          Text('View Statement'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 11),

          // BALANCE & ACTIONS
          Row(
            children: [
              Expanded(
                child: CustomerInfo(
                  title: 'Opening Balance',
                  value: '৳ ${customer.openingBalance.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: CustomerInfo(
                  title: customer.isAdvanceCredit
                      ? 'Advance Credit'
                      : (customer.hasDue ? 'Current Due' : 'Balance'),
                  value: '৳ ${(customer.isAdvanceCredit ? customer.advanceCredit : customer.totalDue).toStringAsFixed(0)}',
                  valueColor: customer.isAdvanceCredit
                      ? Colors.green[700]
                      : (customer.hasDue ? Colors.orange[900] : Colors.grey),
                ),
              ),
              if (customer.hasDue) ...[
                IconButton(
                  onPressed: () => _launchWhatsAppReminder(context),
                  icon: const Icon(Icons.chat_outlined, color: Colors.teal, size: 22),
                  tooltip: 'WhatsApp Due Reminder',
                ),
              ],
              if (onCollectPayment != null && customer.hasDue) ...[
                FilledButton.icon(
                  onPressed: onCollectPayment,
                  icon: const Icon(Icons.payments_outlined, size: 16),
                  label: const Text('Pay'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length > 1 ? 2 : 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}