import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/localization_local.dart';
import '../../../../core/route/app_route.dart';
import '../../../../core/widgets/global_warning_dialog.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const GetMeRequestedEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(ProfileStrings.profileTitle.getString(context)),
        leading: IconButton(
          onPressed: () {
            AppRoute.shellScaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UnauthenticatedState) {
            context.go('/login');
          } else if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          final user = state is AuthenticatedState ? state.user : null;
          final bool isLoading = state is AuthLoadingState && user == null;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (user == null) {
            return Center(child: Text(ProfileStrings.loadFailed.getString(context)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Avatar Card
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: colorScheme.primary,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          user.role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        backgroundColor:
                        user.role.toLowerCase() == 'superadmin'
                            ? Colors.purple
                            : user.role.toLowerCase() == 'admin'
                            ? Colors.blue.shade700
                            : Colors.teal,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // User Details Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.email_outlined,
                          color: Colors.blue,
                        ),
                        title: Text(ProfileStrings.emailAddress.getString(context)),
                        subtitle: Text(user.email),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.phone_outlined,
                          color: Colors.green,
                        ),
                        title: Text(ProfileStrings.mobileNumber.getString(context)),
                        subtitle: Text(
                          (user.phone != null && user.phone!.isNotEmpty) ? user.phone! : 'N/A',
                        ),
                      ),
                      if (user.shopName != null &&
                          user.shopName!.isNotEmpty) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.storefront_outlined,
                            color: Colors.orange,
                          ),
                          title: Text(ProfileStrings.shopName.getString(context)),
                          subtitle: Text(user.shopName!),
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
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              ProfileStrings.dangerZone.getString(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ProfileStrings.dangerZoneWarning.getString(context),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.delete_forever),
                            label: Text(
                              ProfileStrings.deleteAccount.getString(context),
                            ),
                            onPressed: () => _confirmDeleteAccount(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    GlobalWarningDialog.show(
      context,
      title: ProfileStrings.deleteAccountConfirm.getString(context),
      message: ProfileStrings.deleteAccountPrompt.getString(context),
      confirmText: Bangla.delete.getString(context),
      cancelText: Bangla.cancel.getString(context),
      icon: Icons.delete_forever_rounded,
      confirmColor: Colors.red,
      onConfirm: () {
        context.read<AuthBloc>().add(const DeleteAccountRequestedEvent());
      },
    );
  }
}
