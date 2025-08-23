import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to profile page
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.changePassword);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to settings page
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}
