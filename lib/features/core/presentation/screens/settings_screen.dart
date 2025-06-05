import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management/core/constants/app_constants.dart';
import 'package:home_management/features/core/services/notification_service.dart';

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
  String? _fcmToken; // FCM token için state

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadFCMToken(); // FCM token yükle
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isNotificationsEnabled = _notificationService.isNotificationsEnabled;
    });
  }

  Future<void> _loadFCMToken() async {
    try {
      await _notificationService.initFCM();
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

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
            _buildTestNotificationButton(),
            _buildFCMTokenInfo(), // FCM token bilgisi ekle
            const Divider(),

            // _buildSectionTitle('Bölgesel'),
            // _buildLanguageSelector(),
            // const SizedBox(height: AppConstants.smallPadding),
            // _buildCurrencySelector(),
            // const Divider(),

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
                context.push('/forgot-password');
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
                _showPrivacyPolicyDialog();
              },
            ),
            _buildAboutOption(
              'Kullanım Koşulları',
              '',
              onTap: () {
                _showTermsOfServiceDialog();
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
      onChanged: (value) async {
        setState(() {
          _isNotificationsEnabled = value;
        });

        await _notificationService.setNotificationsEnabled(value);

        // Show test notification
        if (value) {
          await _notificationService.showSuccess(
            title: 'Bildirimler Açıldı',
            message: 'Artık uygulama bildirimlerini alacaksınız.',
          );
        } else {
          // Show one last notification before turning off
          await _notificationService.showInfo(
            title: 'Bildirimler Kapatıldı',
            message: 'Artık uygulama bildirimleri gösterilmeyecek.',
          );
        }
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
      trailing:
          onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content:
            const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
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

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gizlilik Politikası'),
        content: const SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gizlilik Politikası',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  '1. Bilgi Toplama',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Ev Yönetimi uygulaması, size hizmet sunabilmek için aşağıdaki bilgileri toplar:\n'
                  '• Ad ve e-posta adresi\n'
                  '• Aile bilgileri ve bütçe verileri\n'
                  '• Uygulama kullanım istatistikleri',
                ),
                SizedBox(height: 16),
                Text(
                  '2. Bilgi Kullanımı',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Toplanan bilgiler yalnızca:\n'
                  '• Size hizmet sunmak\n'
                  '• Uygulamayı geliştirmek\n'
                  '• Güvenlik sağlamak\n'
                  'amacıyla kullanılır.',
                ),
                SizedBox(height: 16),
                Text(
                  '3. Bilgi Paylaşımı',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Kişisel bilgileriniz üçüncü taraflarla paylaşılmaz. Bilgileriniz yalnızca aile üyeleri arasında, izninizle paylaşılır.',
                ),
                SizedBox(height: 16),
                Text(
                  '4. Veri Güvenliği',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Verileriniz Firebase güvenlik standartları ile korunur ve şifrelenir.',
                ),
                SizedBox(height: 16),
                Text(
                  '5. İletişim',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Gizlilik politikası hakkında sorularınız için: support@evyonetimi.com',
                ),
                SizedBox(height: 16),
                Text(
                  'Son Güncelleme: Haziran 2025',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanım Koşulları'),
        content: const SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kullanım Koşulları',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  '1. Hizmet Kullanımı',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Ev Yönetimi uygulamasını kullanarak aşağıdaki koşulları kabul etmiş olursunuz:\n'
                  '• Uygulamayı yasal amaçlarla kullanacağınız\n'
                  '• Doğru bilgiler vereceğiniz\n'
                  '• Hesap güvenliğinizi koruyacağınız',
                ),
                SizedBox(height: 16),
                Text(
                  '2. Hesap Sorumluluğu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Hesabınızın güvenliği sizin sorumluluğunuzdadır. Şifrenizi güvenli tutun ve kimseyle paylaşmayın.',
                ),
                SizedBox(height: 16),
                Text(
                  '3. İçerik Politikası',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Uygulamaya yüklediğiniz içeriklerin yasal ve uygun olması gerekmektedir.',
                ),
                SizedBox(height: 16),
                Text(
                  '4. Hizmet Değişiklikleri',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Hizmet şartlarını önceden bildirimde bulunarak değiştirme hakkımız saklıdır.',
                ),
                SizedBox(height: 16),
                Text(
                  '5. Sorumluluk Reddi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Uygulama "olduğu gibi" sunulmaktadır. Hizmet kesintilerinden sorumlu değiliz.',
                ),
                SizedBox(height: 16),
                Text(
                  'Son Güncelleme: Haziran 2025',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    return ListTile(
      leading: const Icon(Icons.notifications_active),
      title: const Text('Test Bildirimi'),
      subtitle: const Text('Bildirim sistemini test et'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        if (_isNotificationsEnabled) {
          _showTestNotificationDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Önce bildirimleri açmanız gerekiyor!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void _showTestNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Bildirimi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hangi türde push bildirim test etmek istiyorsunuz?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ℹ️ iOS Simülatörde local bildirimler çalışır',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _notificationService.showSuccess(
                title: 'Başarılı!',
                message: 'Bu bir başarı bildirimidir. İşlem tamamlandı.',
              );
            },
            child: const Text('Başarı', style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _notificationService.showError(
                title: 'Hata!',
                message: 'Bu bir hata bildirimidir. Bir sorun oluştu.',
              );
            },
            child: const Text('Hata', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _notificationService.showWarning(
                title: 'Uyarı!',
                message: 'Bu bir uyarı bildirimidir. Dikkat edilmeli.',
              );
            },
            child: const Text('Uyarı', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _notificationService.showInfo(
                title: 'Bilgi',
                message:
                    'Bu bir bilgi bildirimidir. Bilmeniz gereken önemli bir durum.',
              );
            },
            child: const Text('Bilgi', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildFCMTokenInfo() {
    return ListTile(
      leading: const Icon(Icons.token),
      title: const Text('FCM Token'),
      subtitle: _fcmToken != null
          ? Text('${_fcmToken!.substring(0, 20)}...')
          : const Text('Token alınamadı'),
      trailing: _fcmToken != null
          ? IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                // Token'ı panoya kopyala
                Clipboard.setData(ClipboardData(text: _fcmToken!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('FCM Token panoya kopyalandı'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            )
          : IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadFCMToken,
            ),
      onTap: () {
        if (_fcmToken != null) {
          _showFCMTokenDialog();
        }
      },
    );
  }

  void _showFCMTokenDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FCM Token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Firebase Cloud Messaging Token:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _fcmToken ?? 'Token bulunamadı',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu token push bildirim göndermek için kullanılır.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_fcmToken != null) {
                Clipboard.setData(ClipboardData(text: _fcmToken!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Token panoya kopyalandı'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Kopyala'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
