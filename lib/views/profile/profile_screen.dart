import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppTheme.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.secondaryOrange,
                    child: const Icon(Icons.person, color: AppTheme.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.currentUser?.name ?? 'Guest',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.currentUser?.email ?? '-',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          auth.currentUser?.phone ?? '-',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.location_on_outlined,
              title: 'Alamat Saya',
              onTap: () {},
            ),
            _MenuTile(
              icon: Icons.payment_outlined,
              title: 'Metode Pembayaran',
              onTap: () {},
            ),
            _MenuTile(
              icon: Icons.rate_review_outlined,
              title: 'Ulasan Saya',
              onTap: () {},
            ),
            _MenuTile(
              icon: Icons.notifications_outlined,
              title: 'Pengaturan Notifikasi',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.logout,
              title: 'Logout',
              isDestructive: true,
              onTap: () {
                auth.logout();
                Get.offAllNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : AppTheme.primaryCharcoal,
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
