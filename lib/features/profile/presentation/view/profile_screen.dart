import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserEntity? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final saved = await InjectionContainer.authRepository.getSavedUser();
      setState(() {
        _user = saved;
        _isLoading = false;
      });
      // Refresh from server
      final latest = await InjectionContainer.authRepository.getMe();
      if (mounted) {
        setState(() {
          _user = latest;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile / ইউজার প্রোফাইল'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('প্রোফাইলের তথ্য লোড করা সম্ভব হয়নি।'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Avatar Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: colorScheme.primary,
                                child: Text(
                                  _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _user!.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(
                                  _user!.role.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                                backgroundColor: _user!.role.toLowerCase() == 'superadmin'
                                    ? Colors.purple
                                    : _user!.role.toLowerCase() == 'admin'
                                        ? Colors.blue.shade700
                                        : Colors.teal,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // User Details Card
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.email_outlined, color: Colors.blue),
                              title: const Text('ইমেইল অ্যাড্রেস'),
                              subtitle: Text(_user!.email),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.phone_outlined, color: Colors.green),
                              title: const Text('মোবাইল নম্বর'),
                              subtitle: Text(_user!.phone.isNotEmpty ? _user!.phone : 'N/A'),
                            ),
                            if (_user!.shopName != null && _user!.shopName!.isNotEmpty) ...[
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.storefront_outlined, color: Colors.orange),
                                title: const Text('দোকান / ব্যবসার নাম'),
                                subtitle: Text(_user!.shopName!),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Account Actions Section
                      Card(
                        color: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.red.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Danger Zone / অ্যাকাউন্ট ডিলিট',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'আপনার প্রোফাইল ও অ্যাকাউন্ট স্থায়ীভাবে ডিলিট করলে সকল অ্যাক্সেস বাতিল হবে।',
                                style: TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  icon: const Icon(Icons.delete_forever),
                                  label: const Text('প্রোফাইল অ্যাকাউন্ট ডিলিট করুন'),
                                  onPressed: () => _confirmDeleteAccount(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('প্রোফাইল অ্যাকাউন্ট ডিলিট নিশ্চিতকরণ'),
        content: const Text(
          'আপনি কি নিশ্চিত যে আপনার প্রোফাইল স্থায়ীভাবে মুছে ফেলতে চান? আপনি অ্যাপ থেকে লগআউট হবেন।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              setState(() => _isLoading = true);
              await InjectionContainer.authRepository.deleteAccount();
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text('হ্যাঁ, ডিলিট করুন'),
          ),
        ],
      ),
    );
  }
}
