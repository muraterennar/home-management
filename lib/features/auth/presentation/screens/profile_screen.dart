import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management/core/constants/app_constants.dart';
import 'package:home_management/features/auth/domain/entities/user_entity.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  
  // Dummy user data
  final UserEntity _user = UserEntity(
    id: 'user1',
    name: 'Murat Eren',
    email: 'murat@example.com',
    role: UserRole.admin,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );
  
  void _logout() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Burada normalde auth provider'a logout isteği gönderilecek
      await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş işlem
      
      if (!mounted) return;
      
      // Başarılı çıkış sonrası giriş ekranına yönlendirme
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
              context.push('/main/settings');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
    );
  }
  
  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Profil resmi
        CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          child: Text(
            _user.name.substring(0, 1).toUpperCase(),
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
          _user.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        // Kullanıcı e-postası
        Text(
          _user.email,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        // Kullanıcı rolü
        Chip(
          label: Text(_user.role == UserRole.admin ? 'Aile Yöneticisi' : 'Aile Üyesi'),
          backgroundColor: _user.role == UserRole.admin
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          labelStyle: TextStyle(
            color: _user.role == UserRole.admin
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildProfileDetails() {
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
            _buildDetailRow('Ad Soyad', _user.name),
            const Divider(),
            _buildDetailRow('E-posta', _user.email),
            const Divider(),
            _buildDetailRow(
              'Rol',
              _user.role == UserRole.admin ? 'Aile Yöneticisi' : 'Aile Üyesi',
            ),
            const Divider(),
            _buildDetailRow(
              'Katılım Tarihi',
              '${_user.createdAt.day}/${_user.createdAt.month}/${_user.createdAt.year}',
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            context.push('/main/profile/edit');
          },
          icon: const Icon(Icons.edit),
          label: const Text('Profili Düzenle'),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        ElevatedButton.icon(
          onPressed: () {
            context.push('/main/profile/change-password');
          },
          icon: const Icon(Icons.lock_outline),
          label: const Text('Şifre Değiştir'),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        if (_user.role == UserRole.admin) ...[  
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        // Kodu panoya kopyala
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kod panoya kopyalandı')),
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
          content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
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
              child: const Text('Çıkış Yap'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }
}