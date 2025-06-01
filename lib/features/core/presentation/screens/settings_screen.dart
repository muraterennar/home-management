import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management/core/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isNotificationsEnabled = true;
  String _selectedLanguage = 'Türkçe';
  String _selectedCurrency = '₺ TRY';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Görünüm'),
            _buildDarkModeSwitch(),
            const Divider(),
            
            _buildSectionTitle('Bildirimler'),
            _buildNotificationsSwitch(),
            const Divider(),
            
            _buildSectionTitle('Bölgesel'),
            _buildLanguageSelector(),
            const SizedBox(height: AppConstants.smallPadding),
            _buildCurrencySelector(),
            const Divider(),
            
            _buildSectionTitle('Hesap'),
            _buildAccountOption(
              'Profil Bilgileri',
              Icons.person_outline,
              () => context.push('/profile'),
            ),
            _buildAccountOption(
              'Şifre Değiştir',
              Icons.lock_outline,
              () {
                // Şifre değiştirme ekranına git
              },
            ),
            _buildAccountOption(
              'Çıkış Yap',
              Icons.exit_to_app,
              _showLogoutConfirmation,
              isDestructive: true,
            ),
            const Divider(),
            
            _buildSectionTitle('Uygulama Hakkında'),
            _buildAboutOption(
              'Uygulama Versiyonu',
              '1.0.0',
            ),
            _buildAboutOption(
              'Gizlilik Politikası',
              '',
              onTap: () {
                // Gizlilik politikası sayfasına git
              },
            ),
            _buildAboutOption(
              'Kullanım Koşulları',
              '',
              onTap: () {
                // Kullanım koşulları sayfasına git
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildDarkModeSwitch() {
    return SwitchListTile(
      title: const Text('Karanlık Mod'),
      subtitle: const Text('Uygulamanın karanlık temasını kullan'),
      value: _isDarkMode,
      onChanged: (value) {
        setState(() {
          _isDarkMode = value;
        });
        // Tema değiştirme işlemi burada yapılacak
      },
    );
  }

  Widget _buildNotificationsSwitch() {
    return SwitchListTile(
      title: const Text('Bildirimler'),
      subtitle: const Text('Uygulama bildirimlerini al'),
      value: _isNotificationsEnabled,
      onChanged: (value) {
        setState(() {
          _isNotificationsEnabled = value;
        });
        // Bildirim ayarları burada kaydedilecek
      },
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      title: const Text('Dil'),
      subtitle: Text(_selectedLanguage),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showLanguageSelector();
      },
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Türkçe'),
              trailing: _selectedLanguage == 'Türkçe'
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'Türkçe';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: _selectedLanguage == 'English'
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'English';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrencySelector() {
    return ListTile(
      title: const Text('Para Birimi'),
      subtitle: Text(_selectedCurrency),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showCurrencySelector();
      },
    );
  }

  void _showCurrencySelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('₺ TRY'),
              trailing: _selectedCurrency == '₺ TRY'
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() {
                  _selectedCurrency = '₺ TRY';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('\$ USD'),
              trailing: _selectedCurrency == '\$ USD'
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() {
                  _selectedCurrency = '\$ USD';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('€ EUR'),
              trailing: _selectedCurrency == '€ EUR'
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() {
                  _selectedCurrency = '€ EUR';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountOption(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildAboutOption(
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : null,
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Çıkış işlemi burada yapılacak
              context.go('/login');
            },
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}