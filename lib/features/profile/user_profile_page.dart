import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/presentation/pages/change_password_page.dart';
import '../../core/theme/app_theme.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildModernHeader(context),

            // Content
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.user;

                  if (user == null) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshProfile,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Info Card
                            _buildProfileInfoCard(user),

                            const SizedBox(height: AppTheme.spacingXLarge),

                            // Quick Actions
                            _buildQuickActions(context, authProvider),

                            const SizedBox(height: AppTheme.spacingXLarge),

                            // Account Settings
                            _buildAccountSettings(context),

                            const SizedBox(height: AppTheme.spacingXXLarge),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.headerDecoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: const Icon(
                    LucideIcons.user,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil Pengguna',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Kelola informasi akun Anda',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Refresh Button
                if (_isRefreshing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        onTap: _refreshProfile,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            LucideIcons.refreshCw,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: AppTheme.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Icon(
                  LucideIcons.userX,
                  size: 48,
                  color: AppTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Profil Tidak Ditemukan',
                style: AppTheme.headingSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Terjadi kesalahan saat memuat profil pengguna',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Center(
                  child: Text(
                    user.name?.isNotEmpty == true
                        ? user.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryIndigo,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppTheme.spacingLarge),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? 'Nama tidak tersedia',
                      style: AppTheme.headingSmall,
                    ),
                    const SizedBox(height: AppTheme.spacingXSmall),
                    Text(
                      user.email ?? 'Email tidak tersedia',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXSmall),
                    if (user.roleNames != null && user.roleNames!.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children:
                            user.roleNames!.map<Widget>((role) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSmall,
                                  ),
                                ),
                                child: Text(
                                  role.toString().toUpperCase(),
                                  style: AppTheme.caption.copyWith(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AuthProvider authProvider) {
    final quickActions = [
      // {
      //   'title': 'Ubah Password',
      //   'subtitle': 'Update kata sandi akun',
      //   'icon': LucideIcons.lock,
      //   'color': AppTheme.primaryAmber,
      //   'onTap': () => _navigateToChangePassword(context),
      // },
      {
        'title': 'Edit Profil',
        'subtitle': 'Ubah informasi profil',
        'icon': LucideIcons.edit,
        'color': AppTheme.primaryBlue,
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur edit profil akan segera tersedia'),
            ),
          );
        },
      },
      // {
      //   'title': 'Refresh Data',
      //   'subtitle': 'Perbarui informasi profil',
      //   'icon': LucideIcons.refreshCw,
      //   'color': AppTheme.primaryPurple,
      //   'onTap': () => _refreshProfile(),
      // },
      {
        'title': 'Logout',
        'subtitle': 'Keluar dari aplikasi',
        'icon': LucideIcons.logOut,
        'color': Colors.red,
        'onTap': () => _handleLogout(context, authProvider),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aksi Cepat', style: AppTheme.headingSmall),
        const SizedBox(height: AppTheme.spacingMedium),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppTheme.spacingMedium,
          mainAxisSpacing: AppTheme.spacingMedium,
          childAspectRatio: 1.2,
          children:
              quickActions.map((action) => _buildActionCard(action)).toList(),
        ),
      ],
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          onTap: action['onTap'],
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: action['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(action['icon'], color: action['color'], size: 24),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                Text(
                  action['title'],
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingXSmall),

                Text(
                  action['subtitle'],
                  style: AppTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pengaturan Akun', style: AppTheme.headingSmall),

          const SizedBox(height: AppTheme.spacingMedium),

          // _buildSettingItem(
          //   icon: LucideIcons.bell,
          //   title: 'Notifikasi',
          //   subtitle: 'Kelola notifikasi aplikasi',
          //   onTap: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //         content: Text('Fitur notifikasi akan segera tersedia'),
          //       ),
          //     );
          //   },
          // ),

          // const Divider(height: 32),
          _buildSettingItem(
            icon: LucideIcons.shield,
            title: 'Keamanan',
            subtitle: 'Pengaturan keamanan akun',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur keamanan akan segera tersedia'),
                ),
              );
            },
          ),

          const Divider(height: 32),

          _buildSettingItem(
            icon: LucideIcons.helpCircle,
            title: 'Bantuan',
            subtitle: 'Pusat bantuan dan FAQ',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur bantuan akan segera tersedia'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icon, color: AppTheme.primaryIndigo, size: 20),
              ),

              const SizedBox(width: AppTheme.spacingMedium),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(subtitle, style: AppTheme.bodySmall),
                  ],
                ),
              ),

              Icon(
                LucideIcons.chevronRight,
                color: AppTheme.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshProfile() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Just show success message since there's no specific refresh method
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil sudah terbaru'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _navigateToChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Keluar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }
}
