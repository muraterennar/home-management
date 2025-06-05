import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management/core/constants/app_constants.dart';
import 'package:home_management/features/auth/data/datasources/auth_service.dart';
import 'package:home_management/features/core/data/datasource/data_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  bool _isLoadingUserData = true;

  final _authService = AuthService();
  final _dataService = DataService();
  String _currentUserId = '';
  Map<String, dynamic> _currentUserData = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  // Add this method to refresh data when returning from other screens
  void _refreshUserData() {
    setState(() {
      _isLoadingUserData = true;
    });
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    try {
      // Get current user from Firebase Auth
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        _currentUserId = currentUser.uid;

        // Get user data from Realtime Database using UID
        final userData = await _authService.getUserById(currentUser.uid);

        setState(() {
          _currentUserData = userData;
          _isLoadingUserData = false;
        });
      } else {
        // User not logged in, redirect to login
        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingUserData = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kullanıcı bilgileri yüklenemedi: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signOut();

      if (!mounted) return;

      context.go('/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Çıkış yapılırken hata: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: (_isLoading || _isLoadingUserData)
          ? const Center(child: CircularProgressIndicator())
          : _currentUserData.isEmpty
              ? const Center(
                  child: Text('Kullanıcı bilgileri bulunamadı'),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    _refreshUserData();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppConstants.defaultPadding),
                        _buildProfileHeader(),
                        const SizedBox(height: AppConstants.largePadding),
                        _buildProfileDetails(),
                        const SizedBox(height: AppConstants.largePadding),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    final userName = _currentUserData['name'] ?? 'User';
    final userEmail = _currentUserData['email'] ?? '';
    final userRole = _currentUserData['role'] ?? 'user';

    return Column(
      children: [
        // Profil resmi
        CircleAvatar(
          radius: 60,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.2),
          child: Text(
            userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Kullanıcı adı
        Text(
          userName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        // Kullanıcı e-postası
        Text(
          userEmail,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        // Kullanıcı rolü
        Chip(
          label: Text(userRole == 'admin' ? 'Aile Yöneticisi' : 'Aile Üyesi'),
          backgroundColor: userRole == 'admin'
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          labelStyle: TextStyle(
            color: userRole == 'admin'
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails() {
    final userName = _currentUserData['name'] ?? 'Bilinmiyor';
    final userEmail = _currentUserData['email'] ?? 'Bilinmiyor';
    final userRole = _currentUserData['role'] ?? 'user';
    final createdAt = _currentUserData['createdAt'];

    String formattedDate = 'Bilinmiyor';
    if (createdAt != null) {
      try {
        if (createdAt is String) {
          // If it's a string, try to parse it
          DateTime dateTime = DateTime.parse(createdAt);
          formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
        } else if (createdAt is int) {
          // If it's a timestamp
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(createdAt);
          formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
        }
      } catch (e) {
        formattedDate = 'Geçersiz tarih';
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hesap Bilgileri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Ad Soyad', userName),
            const Divider(),
            _buildDetailRow('E-posta', userEmail),
            const Divider(),
            _buildDetailRow(
              'Rol',
              userRole == 'admin' ? 'Aile Yöneticisi' : 'Aile Üyesi',
            ),
            const Divider(),
            _buildDetailRow('Katılım Tarihi', formattedDate),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final userRole = _currentUserData['role'] ?? 'user';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            // Wait for the result and refresh data when coming back
            await context.push('/profile/edit');
            _refreshUserData();
          },
          icon: const Icon(Icons.edit),
          label: const Text('Profili Düzenle'),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        ElevatedButton.icon(
          onPressed: () {
            context.push('/forgot-password');
          },
          icon: const Icon(Icons.lock_outline),
          label: const Text('Şifre Değiştir'),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        if (userRole == 'admin') ...[
          ElevatedButton.icon(
            onPressed: () {
              _showInviteDialog(context);
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Aile Üyesi Davet Et'),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
        ],
        OutlinedButton.icon(
          onPressed: () {
            _showLogoutConfirmation(context);
          },
          icon: const Icon(Icons.logout),
          label: const Text('Çıkış Yap'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aile Üyesi Davet Et'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Aşağıdaki kodu aile üyenizle paylaşın:'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ABC123XYZ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        // Kodu panoya kopyala
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Kod panoya kopyalandı')),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text(
              'Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }
}
