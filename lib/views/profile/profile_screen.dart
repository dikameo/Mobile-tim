import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../config/supabase_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isAdmin = false;
  bool isCheckingRole = true;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    try {
      print('🔍 ========== ADMIN CHECK START ==========');
      print('🔍 Current Supabase user: ${SupabaseConfig.currentUser?.email}');
      print('🔍 Current Supabase user ID: ${SupabaseConfig.currentUser?.id}');

      if (SupabaseConfig.currentUser == null) {
        print('❌ NO SUPABASE SESSION! User not logged in via Supabase');
        setState(() {
          isAdmin = false;
          isCheckingRole = false;
        });
        return;
      }

      print('🔍 Fetching user role from database...');
      final role = await SupabaseConfig.getCurrentUserRole();
      print('🔍 User role from DB: "$role"');

      // IMPORTANT: Check if role is 'admin' (case sensitive!)
      final isAdminRole = role?.toLowerCase() == 'admin';
      print('🔍 Is admin role: $isAdminRole (role="$role")');

      setState(() {
        isAdmin = isAdminRole;
        isCheckingRole = false;
      });

      print('✅ Admin check completed. isAdmin = $isAdmin');
      print('🔍 ========== ADMIN CHECK END ==========');
    } catch (e, stackTrace) {
      print('❌ ========== ADMIN CHECK ERROR ==========');
      print('❌ Error: $e');
      print('❌ Stack trace: $stackTrace');
      print('❌ ========== END ERROR ==========');

      setState(() {
        isAdmin = false;
        isCheckingRole = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: theme.cardColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.secondaryOrange,
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.onPrimary,
                    ),
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

            // User Orders Section
            _MenuTile(
              icon: Icons.shopping_bag_outlined,
              title: 'Riwayat Pesanan',
              subtitle: 'Lihat pesanan dan status pengiriman',
              backgroundColor: theme.cardColor,
              onTap: () => Get.toNamed('/orders'),
            ),

            const SizedBox(height: 8),

            // Theme Toggle - Menggunakan SharedPreferences
            _ThemeToggleTile(),

            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.location_on_outlined,
              title: 'Alamat Saya',
              backgroundColor: theme.cardColor,
              onTap: () {},
            ),
            _MenuTile(
              icon: Icons.payment_outlined,
              title: 'Metode Pembayaran',
              backgroundColor: theme.cardColor,
              onTap: () {},
            ),
            _MenuTile(
              icon: Icons.rate_review_outlined,
              title: 'Ulasan Saya',
              backgroundColor: theme.cardColor,
              onTap: () {},
            ),
            _MenuTile(
              icon: Icons.notifications_outlined,
              title: 'Pengaturan Notifikasi',
              backgroundColor: theme.cardColor,
              onTap: () {},
            ),
            const SizedBox(height: 8),

            // Admin Panel Section
            if (isCheckingRole)
              Container(
                color: theme.cardColor,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Checking admin privileges...',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              )
            else if (isAdmin)
              Column(
                children: [
                  Container(
                    color: theme.brightness == Brightness.dark
                        ? Colors.orange[900]
                        : Colors.orange[50],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: theme.brightness == Brightness.dark
                              ? Colors.orange[300]
                              : Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ADMIN PANEL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? Colors.orange[300]
                                : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _MenuTile(
                    icon: Icons.inventory,
                    title: 'Manage Products',
                    subtitle: 'Kelola produk roasting machine',
                    backgroundColor: theme.cardColor,
                    onTap: () => Get.toNamed('/admin/products'),
                  ),
                  _MenuTile(
                    icon: Icons.shopping_bag,
                    title: 'Manage Orders',
                    subtitle: 'Kelola pesanan customer',
                    backgroundColor: theme.cardColor,
                    onTap: () => Get.toNamed('/admin/orders'),
                  ),
                  const SizedBox(height: 8),
                ],
              )
            else if (auth.isAuthenticated)
              Container(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Logged in as: ${auth.currentUser?.email ?? "unknown"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.logout,
              title: 'Logout',
              backgroundColor: theme.cardColor,
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

// Theme Toggle Widget with SharedPreferences
class _ThemeToggleTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);

    return Obx(
      () => Container(
        color: theme.cardColor,
        child: SwitchListTile(
          secondary: Icon(
            themeController.isDark ? Icons.dark_mode : Icons.light_mode,
            color: theme.iconTheme.color,
          ),
          title: Text('Dark Mode', style: theme.textTheme.titleMedium),
          subtitle: Text('Theme', style: theme.textTheme.bodySmall),
          value: themeController.isDark,
          activeColor: AppTheme.secondaryOrange,
          onChanged: (value) async {
            // Gunakan setTheme dengan value langsung dari switch
            await themeController.setTheme(value);
          },
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? backgroundColor;
  final bool isDestructive;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.backgroundColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        backgroundColor ?? (isDark ? Colors.grey[900] : Colors.white);

    return Container(
      color: bgColor,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : theme.iconTheme.color,
        ),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
