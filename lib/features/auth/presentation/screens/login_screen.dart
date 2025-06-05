import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management/core/constants/app_constants.dart';
import 'package:home_management/features/auth/data/datasources/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseAuth = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Animasyon kontrolcüsü
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animasyon kontrolcüsünü başlat
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Animasyonu başlat
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Burada normalde auth provider'a login isteği gönderilecek

        final loginUser = await _firebaseAuth.signInWithEmailAndPassword(
            _emailController.text, _passwordController.text);

        if (loginUser == null) {
          // Başarısız giriş sonrası snackbar göster
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kullanıcı bulunamadı'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        if (!mounted) return;

        // Başarılı giriş sonrası yönlendirme
        context.go('/dashboard');
      } catch (e) {
        // Hata durumunda snackbar göster
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo ve Başlık
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.home_rounded,
                            size: 60,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ailenizin finansal yönetimi için',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: AppConstants.largePadding),

                        // Email alanı
                        Card(
                          elevation: 0,
                          color: theme.colorScheme.surface,
                          margin: const EdgeInsets.only(
                              bottom: AppConstants.defaultPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'E-posta',
                                hintText: 'ornek@mail.com',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppConstants.emailRequired;
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return AppConstants.invalidEmail;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),

                        // Şifre alanı
                        Card(
                          elevation: 0,
                          color: theme.colorScheme.surface,
                          margin: const EdgeInsets.only(
                              bottom: AppConstants.smallPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Şifre',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppConstants.passwordRequired;
                                }
                                if (value.length < 6) {
                                  return AppConstants.passwordTooShort;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),

                        // Şifremi Unuttum
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.push('/forgot-password');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                            ),
                            child: const Text('Şifremi Unuttum'),
                          ),
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),

                        // Giriş Yap butonu
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Giriş Yap',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),

                        // Kayıt Ol yönlendirmesi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hesabınız yok mu?',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/register'),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                              ),
                              child: const Text(
                                'Kayıt Ol',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
